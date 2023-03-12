FROM ruby:2.7.1

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    nano

RUN gem install aws-sdk

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

EXPOSE 4567

CMD ["ruby", "app.rb", "-o", "0.0.0.0"]
