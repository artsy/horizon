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
    py2-setuptools \
    tzdata \
    yarn \
    git && \
    adduser -D -g '' deploy

# support hokusai registry commands
RUN ln -sf /usr/bin/easy_install-2.7 /usr/bin/easy_install
RUN easy_install pip
RUN pip install --upgrade pip
RUN pip install --upgrade --no-cache-dir hokusai

RUN gem install bundler -v '<2' && \
    bundle config --global frozen 1

# Set up gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install -j4

# Set up packages, empty cache to save space
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --quiet && \
    yarn cache clean --force

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
