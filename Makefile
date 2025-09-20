# DEVELOPMENT
SHELL:=/bin/bash
SERVER="good-night-api"

start-services-development:
	./start-local-env-with-docker.sh

stop-services-development:
	docker compose stop

restart-services-development: rm-rails-pid
	docker compose restart

reset-services-development: remove-services-development start-services-development

remove-services-development:
	docker compose down -v --remove-orphans

rm-rails-pid:
	@case "$$OSTYPE" in \
	linux*) sudo rm -rf tmp/pids/*.pid || true ;; \
	*) rm -rf tmp/pids/*.pid || true ;; \
	esac

rspec:
	docker compose run --rm $(SERVER) bash -c "bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))"

bundle-install:
	docker compose run --rm $(SERVER) bash -c "bundle install --retry 5"
	make rm-rails-pid
	docker compose restart
