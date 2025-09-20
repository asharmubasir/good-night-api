# DEVELOPMENT
SHELL:=/bin/bash

start-services-development:
	./start-local-env-with-docker.sh

stop-services-development:
	docker compose stop

restart-services-development: rm-rails-pid
	docker compose restart

reset-services-development: remove-services-development start-services-development

remove-services-development:
	docker compose down -v --remove-orphans

# -- common section --

rm-rails-pid:
	@case "$$OSTYPE" in \
	linux*) sudo rm -rf tmp/pids/*.pid || true ;; \
	*) rm -rf tmp/pids/*.pid || true ;; \
	esac
