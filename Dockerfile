FROM ruby:2.5.9
RUN apt-get update -qq && apt-get install -y --force-yes nodejs
RUN apt install -y --force-yes  nodejs npm

#chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install ./google-chrome-stable_current_amd64.deb -y

#chrome driver
RUN wget http://chromedriver.storage.googleapis.com/111.0.5563.64/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN mv chromedriver /usr/local/bin
RUN chmod +x /usr/local/bin/chromedriver


# RUN npm install -g phantomjs
RUN mkdir /wtracker
WORKDIR /wtracker
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install
COPY . /wtracker
