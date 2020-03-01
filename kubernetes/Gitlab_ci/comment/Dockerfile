FROM ruby:2.2

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

RUN apt-get update -qq \
    && apt-get install -y build-essential \
    && bundle install

ADD . $APP_HOME

CMD ["puma"]
