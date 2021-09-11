## Complect Web App

### Setup project locally

1. If you don't have ruby `2.5.7` on your computer:

    * install rvm http://rvm.io/

    * `rvm install 2.5.7`
    * `rvm use --default 2.5.7`

    * `gem install bundler`
  
2. If you don't have postgress on your computer:

    * [Install Postgres](https://www.postgresql.org/download/)

    * Check postgres version: `pg_config --version`

3. App needs postgis.control (example for install `postgis` for postgres 13)

    * Check if you have postgis.control extension: `find /usr -name postgis.control`
    
    * Install: `sudo apt install postgis postgresql-13-postgis-3`

4. Check if you have `node 14.17.3`

    * node -v

    * install node: `nvm install 14.17.3`


5. `git clone git@github.com:complectco/complect.git`
6. `cd complect`
7. `rbenv local 2.5.7`
8. `bundle`
9. Run `overcommit --install && overcommit --sign`
10. Ask about `.env` and `env.local` files
11. Check `POSTGRES_USER` and `POSTGRES_PASSWORD` in `.env` file
12. `rake db:create`
13. `rake db:migrate`
14. `rake db:seed`
15. Run `rails s` in one tab of terminal
16. Open second tab and run commands:

    * `nvm use 14.17.3`

    * `npm install`

    *  `./bin/webpack-dev-server`

17. [http://localhost:3000/](http://localhost:3000/)

### Tests
- Prepare for testing: `rake db:test:prepare`
- Run tests: `rspec spec/`
- You can check tests coverage. Open file in browser: `coverage/index.html`

### Configuration

Everything is configured using environment variables so we have it all on one place.

- `.env` contains all the variables used by the application.
- `.env.development` houses settings that can be shared between developers.
- `.env.test` contains settings for the test environment
- `.env.production` this file belongs on the server; we set here all the variables (or use Heroku's variables)
- `.env.local` is ".gitignore'd" so each dev can override any setting

### Database

Using PostgreSQL via a `DATABASE_URL` environment variable.

### Asset Management

Using bower at `vendor/assets/components`.

### Docker on Heroku
* `heroku container:push web worker -a <Heroku App ID>`
* `heroku container:release web worker -a <Heroku App ID>`



## Running project with Docker Compose
1. Ask about `.env` and `env.local` files
2. Create empty `postgres` dir in root
3. Run: `docker-compose -f docker-compose-dev.yml up`
4. SSH to Complect App container and run:
	* `rake db:create`
	* `rake db:migrate`
	* `rake db:seed`
5. Navigate to localhost:81 in browser, wait for build (1-3 mins).
