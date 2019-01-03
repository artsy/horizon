FROM ruby:2.5.1
ENV LANG C.UTF-8

# Set up dumb-init
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

RUN apt-get update -qq && \
    apt-get install -y nodejs nginx python-pip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# support hokusai registry commands
RUN pip install --no-cache-dir hokusai

# Set up nginx
RUN rm -v /etc/nginx/nginx.conf
ADD config/nginx.conf /etc/nginx/
ADD config/app.conf /etc/nginx/conf.d/

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN gem update --system
RUN gem install bundler

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Set up working directory
RUN mkdir /app

# Set up gems
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install -j4

# Finally, add the rest of our app's code
# (this is done at the end so that changes to our app's code
# don't bust Docker's cache)
ADD . /app
WORKDIR /app

# Precompile Rails assets
RUN bundle exec rake assets:precompile

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD nginx && bundle exec puma -C config/puma.rb
