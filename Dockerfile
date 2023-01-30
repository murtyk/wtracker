FROM ruby:2.4.1
RUN apt-get update -qq && apt-get install -y --force-yes nodejs
RUN mkdir /wtracker
WORKDIR /wtracker
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
COPY . /wtracker
