FROM ruby:3.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Precompile assets for production
# ARG SECRET_KEY_BASE
# ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
RUN RAILS_ENV=production bundle exec rake assets:precompile

COPY config/master.key /app/config/master.key


# Expose port 3000 to the host
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
