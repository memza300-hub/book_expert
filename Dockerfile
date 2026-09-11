# syntax=docker/dockerfile:1
# BookExpert — production image (Ruby 3.3 + Rails 8 + PostgreSQL client)
FROM ruby:3.3-slim

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev postgresql-client curl git && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN chmod +x docker/entrypoint.sh && \
    useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails /rails
USER rails

ENTRYPOINT ["/rails/docker/entrypoint.sh"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
