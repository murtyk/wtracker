FROM ruby:2.5.9
RUN apt-get update -qq && apt-get install -y --force-yes nodejs
RUN apt install -y --force-yes  nodejs npm
# RUN npm install -g phantomjs
RUN mkdir /wtracker
WORKDIR /wtracker
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
COPY . /wtracker
