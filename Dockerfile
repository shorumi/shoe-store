FROM ruby:3.1.3-slim

# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    libpq-dev \
    websocketd \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=$(nproc) \
  BUNDLE_RETRY=5

# Upgrade RubyGEMS and install required Bundler version
RUN gem update --system && \
    gem install bundler

COPY Gemfile .

RUN mkdir /app
WORKDIR /app
