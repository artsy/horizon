FROM ruby:2.6-alpine
ENV LANG C.UTF-8

WORKDIR /app

RUN apk update && apk --no-cache --quiet add --update \
    build-base \
    dumb-init \
    postgresql-dev \
    postgresql-client \
    python2-dev \
    py-pip \
    tzdata \
    yarn \
    git && \
    adduser -D -g '' deploy

# Switch to 3.9 alpine registry for node v10
RUN sed -i -e 's/v[[:digit:]]\..*\//v3.9\//g' /etc/apk/repositories && \
    cat /etc/alpine-release && \
    apk update && apk --no-cache --quiet add --update nodejs=~10

# support hokusai registry commands
RUN pip install --upgrade --no-cache-dir hokusai

# Set up gems and packages
RUN gem install bundler -v '<2' && \
    bundle config --global frozen 1
COPY Gemfile \
    Gemfile.lock \
    .ruby-version \
    package.json \
    yarn.lock ./
RUN bundle install -j4 && \
    yarn install --check-files

# Copy application code
COPY . ./

# Precompile Rails assets
RUN bundle exec rake assets:precompile && \
    chown -R deploy:deploy ./

# Switch to less privelidged user
USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
