# ADDYWEATHER

This is a Ruby on Rails 7 application.

## Getting Started

These instructions will help you get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following installed:

- Ruby `>= 3.0.0`
- Rails `>= 7.0.0`
- Node.js `>= 18`
- Yarn `>= 1.22`
- PostgreSQL
- Redis (`redis-server`)

### Installation

1. Enable credentials:

   Obtain `config/master.key` from project administrator.

2. Use `bin/setup` to load dependencies.

3. Run `bin/dev`, which will also kick up the Redis process.

4. Browse to http://127.0.0.1:3000/


### Production

For review, the app is currently deployed on Heroku at:

```
https://addyweather-ca876e1ae5dc.herokuapp.com/
```

## Tests

`bundle exec rspec`
