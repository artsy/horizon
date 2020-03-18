FROM ruby:2.6.0
ENV LANG C.UTF-8

# Needed to install npm/yarn
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash

RUN apt-get update -qq && \
    apt-get install -y nodejs nginx python-pip dumb-init && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# support hokusai registry commands
RUN pip install --no-cache-dir hokusai

RUN npm install -g yarn

# Set up nginx
RUN rm -v /etc/nginx/nginx.conf
ADD config/nginx.conf /etc/nginx/
ADD config/app.conf /etc/nginx/conf.d/

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN gem install bundler -v '<2'

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Set up working directory
RUN mkdir /app

# Set up gems and packages
WORKDIR /tmp
COPY Gemfile \
    Gemfile.lock \
    .ruby-version \
    package.json \
    yarn.lock ./
RUN bundle install -j4 && \
    yarn install --check-files

# Finally, add the rest of our app's code
# (this is done at the end so that changes to our app's code
# don't bust Docker's cache)
ADD . /app
WORKDIR /app

# Precompile Rails assets
RUN bundle exec rake assets:precompile

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD nginx && bundle exec puma -C config/puma.rb
