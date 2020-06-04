FROM ruby:2.6.6-alpine
ENV LANG C.UTF-8
ENV PORT 3000
EXPOSE 3000

WORKDIR /app

RUN apk update && apk --no-cache --quiet add --update \
    build-base \
    dumb-init \
    nodejs \
    postgresql-dev \
    postgresql-client \
    python2-dev \
    py-pip \
    tzdata \
    yarn \
    git && \
    adduser -D -g '' deploy

# support hokusai registry commands
RUN pip install --upgrade --no-cache-dir hokusai

RUN gem install bundler -v '<2' && \
    bundle config --global frozen 1

# Set up gems
COPY Gemfile Gemfile.lock .ruby-version package.json yarn.lock ./
RUN bundle install -j4 && yarn install --no-cache


# Create directories for Puma/Nginx & give deploy user access
RUN mkdir -p /shared/pids /shared/sockets && \
    chown -R deploy:deploy /shared

# Copy application code
COPY . ./

# Precompile Rails assets
RUN bundle exec rake assets:precompile && \
    chown -R deploy:deploy ./

# Switch to less privelidged user
USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
