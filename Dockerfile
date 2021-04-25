FROM ruby:2.4.1
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && apt-get update -qq && apt-get install -y nodejs
RUN curl https://cli-assets.heroku.com/install.sh | sh
RUN mkdir /wtracker
WORKDIR /wtracker
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
COPY . /wtracker
