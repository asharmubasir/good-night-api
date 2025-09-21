# DEVELOPMENT
SHELL:=/bin/bash
SERVER="good-night-api"

start-local-dev:
	./start-local-env-with-docker.sh

stop-local-dev:
	docker compose stop

restart-local-dev: rm-rails-pid
	docker compose restart

reset-local-dev: remove-local-dev start-local-dev

remove-local-dev:
	docker compose down -v --remove-orphans

rm-rails-pid:
	@case "$$OSTYPE" in \
	linux*) sudo rm -rf tmp/pids/*.pid || true ;; \
	*) rm -rf tmp/pids/*.pid || true ;; \
	esac

bundle-install:
	docker compose run --rm $(SERVER) bash -c "bundle install --retry 5"
	make rm-rails-pid
	docker compose restart

migrate-local-dev:
	docker compose run --rm $(SERVER) bash -c "bundle exec rails db:migrate"

setup-test-db:
	docker compose run --rm $(SERVER) bash -c "RAILS_ENV=test bundle exec rails db:create db:schema:load"

rspec:
	docker compose run --rm $(SERVER) bash -c "RAILS_ENV=test bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))"

bash-local-dev:
	docker compose exec $(SERVER) bash