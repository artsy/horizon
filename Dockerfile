FROM ruby:2.6.6-alpine AS ruby-with-node

# Install Node + Yarn
ENV NODE_VERSION 12.20.1
ENV YARN_VERSION 1.22.5

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache libstdc++ \
    && apk add --no-cache --virtual .build-deps curl \
    && curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64-musl.tar.xz" \
    && tar -xJf "node-v$NODE_VERSION-linux-x64-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && rm -f "node-v$NODE_VERSION-linux-x64-musl.tar.xz" \
    && apk del .build-deps

RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && apk del .build-deps-yarn

FROM ruby-with-node as base

RUN apk update && apk --no-cache --quiet add --update \
    git \
    postgresql-dev \
    py2-setuptools \
    python2-dev \
    tzdata \
    && adduser -D -g '' deploy

# support hokusai registry commands
# horizon needs to compare production/staging envs of projects
RUN ln -sf /usr/bin/easy_install-2.7 /usr/bin/easy_install && \
    easy_install pip && \
    pip install --upgrade pip && \
    pip install --upgrade --no-cache-dir hokusai

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
COPY --chown=deploy:deploy Gemfile Gemfile.lock .ruby-version ./
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

# TODO: dump dev bundle
RUN rm -rf node_modules

USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
