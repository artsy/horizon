# ---------------------------------------------------------
# Base Image
# ---------------------------------------------------------
FROM artsy/ruby:3.0.2-node-14-yarn as base

RUN apk update && apk --no-cache --quiet add --update \
    git \
    postgresql-dev \
    tzdata \
    && adduser -D -g '' deploy

# support hokusai registry commands
# horizon needs to compare production/staging envs of projects
RUN apk update && apk --no-cache --quiet add --update \
    build-base \
    openssl-dev \
    python3-dev \
    py3-pip

RUN pip3 install --upgrade --no-cache-dir pip \
    && pip3 install --upgrade --no-cache-dir hokusai --ignore-installed

# ---------------------------------------------------------
# Build Image
# ---------------------------------------------------------
FROM base AS builder
ENV LANG C.UTF-8
ENV PORT 3000
EXPOSE 3000

RUN apk update && apk --no-cache --quiet add --update \
    build-base \
    postgresql-client

RUN gem install bundler -v '<2' && \
    bundle config --global frozen 1

WORKDIR /app

RUN chown deploy:deploy $(pwd)
RUN chown -R deploy:deploy /usr/local
USER deploy

# Set up gems
# TODO: look into buildkit to prevent re-installing node modules after changing gems
COPY --chown=deploy:deploy Gemfile Gemfile.lock ./
# RUN bundle install -j4 --path /usr/local/bundle-prod --without development test && \
RUN bundle install -j4 --path /usr/local/bundle
# bundle clean

# Set up packages, empty cache to save space
COPY --chown=deploy:deploy package.json yarn.lock ./
RUN yarn install --frozen-lockfile --quiet && \
    yarn cache clean --force

# Copy application code
COPY --chown=deploy:deploy . ./

# Precompile Rails assets
RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# ---------------------------------------------------------
# Production Image
# ---------------------------------------------------------
FROM base AS production
ENV PORT 3000
EXPOSE 3000
WORKDIR /app

RUN apk update && apk --no-cache --quiet add --update \
    dumb-init

# copy app files
COPY --chown=deploy:deploy --from=builder /app .
# copy gems
COPY --chown=deploy:deploy --from=builder /usr/local/bundle /usr/local/bundle

# Create directories for Puma/Nginx & give deploy user access
RUN mkdir -p /shared/pids /shared/sockets && \
    chown -R deploy:deploy /shared

# Create directories for cron.
RUN mkdir /home/deploy/data && \
    chown -R deploy:deploy /home/deploy/data

# TODO: dump dev bundle
RUN rm -rf node_modules

USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
