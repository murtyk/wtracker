FROM ruby:2.4.1-slim

RUN apt-get update -qq && apt-get install -y build-essential

# some tools
RUN apt-get install -y sudo wget curl

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y --force-yes nodejs

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get install -y apt-transport-https && sudo apt-get -y update && sudo apt-get -y install yarn

# for git pulls
RUN apt-get install -y git

# for htop goodness
RUN apt-get install -y htop

# Allows htop and nano to run
ENV TERM xterm-256color

RUN alias ls='ls --color'

RUN curl https://cli-assets.heroku.com/install.sh | sh
RUN mkdir /wtracker
WORKDIR /wtracker
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
COPY . /wtracker
