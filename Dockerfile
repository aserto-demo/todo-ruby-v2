FROM ruby:3.2.2

RUN apt-get update && apt-get install -y wget less groff
RUN apt-get update -qq && apt-get install -y build-essential libsnappy-dev libpq-dev cron libicu-dev git
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG RAILS_ENV=development
ENV APP_HOME=/ruby-app \
    SECRET_KEY_BASE=4bfb52e4baed7088644c248652dead123e12a67eeb7b279f0d390cc40c21327e36d09a1f670cdaf71bb124b1a9a753cc38d89c4fb4b8c698a53ca460c8cca723 \
    RAILS_ENV=$RAILS_ENV

RUN mkdir $APP_HOME
RUN mkdir /certs
WORKDIR $APP_HOME

ADD . $APP_HOME/
RUN bundle install --jobs 20 --retry 5

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3001
CMD bundle exec rails s -b 0.0.0.0 -p 3001
ENTRYPOINT ["entrypoint.sh"]
