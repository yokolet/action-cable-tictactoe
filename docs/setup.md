### Rails App Creation and Setup

#### Create a Rails app
1. Install the latest Ruby
    - version: 3.3.5
    - Create .ruby-version file
    ```bash
    # .ruby-version
    ruby-3.3.5
    ```
2. Create a Rails application
    - `$ bundle exec rails new . --rc=../.railsrc-tictactoe`
    ```bash
    # .railsrc-tictactoe
    --skip-docker
    --skip-action-mailer
    --skip-action-mailbox
    --skip-action-text
    --skip-active-record
    --skip-active-job
    --skip-active-storage
    -J
    -T
    ```
3. Verify Rail starts
    ```bash
    $ bundle exec rails s
    ```
    Then, open http://localhost:3000

#### Setup Testing Environment
1. Update Gemfile
    ```ruby
    # Gemfile
    # ...
    group :development, :test do
      #...
      gem "webmock", "~> 3.24"
      gem "pry", "~> 0.14.2"
      gem "rspec-rails", "~> 7.0"
      gem "faker", "~> 3.4"
    end
    ```
2. Install gems and initialize RSpec
    ```bash
    $ bundle install
    $ bundle exec rails g rspec:install
    ```
3. Update configuration
    Add require statement to `spec/rails_helper.rb`
    ```ruby
    # spec/rails_helper.rb
    #...
    require 'webmock/rspec'
    #...
    ```
