SHELL := /bin/bash

help:
	# shellcheck disable=SC2046
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$|(^#--)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m %-43s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m #-- /[33m/'

.PHONY: help
.DEFAULT_GOAL := help


#-- Application
init: ## init the app
	rm -rf .git
	docker-compose up -d
	symfony new app
	cp -r app/ .
	cp docs/.env.local .
	rm -rf app

clean: ## clean up the symfony project files
	rm -rf bin config public src var vendor .env .env.local .gitignore composer.* symfony.lock

#-- Database & Migration
db-clean: ## clean the db
	docker-compose exec php bin/console doctrine:database:drop --if-exists -n --force
	docker-compose exec php bin/console doctrine:database:create --if-not-exists -n

db-migrate: ## doctrine migrate
	docker-compose exec php bin/console doctrine:migrations:migrate -n

#-- Docker Resource
docker-clean: ## clean up all docker resource
	docker-compose stop
	docker container prune -f
	docker image prune -f
	docker volume prune -f
	docker network prune -f
