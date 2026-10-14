# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is for production. Build and run it by hand:
# docker build -f deploy/Dockerfile -t rounds .
# docker run -d -p 2300:2300 --name rounds \
#   -e DATABASE_URL=postgres://user:password@host/dbname \
#   -e SESSION_SECRET=<64 or more random characters> \
#   -e APP_URL=https://rounds.example.com \
#   -e MAIL_FROM=rounds@example.com \
#   rounds
#
# To create the first admin:
# docker exec -e ADMIN_EMAIL=you@example.com rounds bundle exec hanami db seed

# Make sure RUBY_VERSION matches the Ruby version used in development.
ARG RUBY_VERSION=4.0.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

# Install base packages. libpq is needed by the pg gem, the client by "hanami db create".
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libpq5 postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
# The app serves its own compiled assets, as there is no web server in front that does.
ENV HANAMI_ENV="production" \
    HANAMI_SERVE_ASSETS="true" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and compile assets
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev nodejs npm pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Install node packages
COPY package.json package-lock.json ./
RUN npm ci

# Copy application code
COPY . .

# Compile assets. The app reads its settings while booting, so give it dummy values.
RUN SESSION_SECRET=dummy-value-for-asset-compilation DATABASE_URL=postgres://dummy@localhost/dummy \
    bundle exec hanami assets compile && \
    rm -rf node_modules




# Final stage for app image
FROM base

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 hanami && \
    useradd hanami --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=hanami:hanami --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=hanami:hanami --from=build /app /app

# Entrypoint creates the database if needed and runs the migrations.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start Puma. This can be overwritten at runtime.
EXPOSE 2300
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
