FROM ruby:2.6.0-alpine
ENV LANG C.UTF-8

# Set up nginx
RUN rm -v /etc/nginx/nginx.conf
ADD config/nginx.conf /etc/nginx/
ADD config/app.conf /etc/nginx/conf.d/
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /app

RUN apk update && apk --no-cache --quiet add \
    build-base \
    dumb-init \
    nodejs \
    nginx \
    postgresql-dev \
    postgresql-client \
    python2-dev \
    py-pip \
    tzdata \
    yarn && \
    adduser -D -g '' deploy

# support hokusai registry commands
RUN pip install --upgrade --no-cache-dir hokusai

RUN gem install bundler -v '<2' && \
    bundle config --global frozen 1

# Set up gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install -j4

# Copy application code
COPY . ./

# Precompile Rails assets
RUN bundle exec rake assets:precompile && \
    chown -R deploy:deploy ./

# Switch to less privelidged user
USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD nginx && bundle exec puma -C config/puma.rb
