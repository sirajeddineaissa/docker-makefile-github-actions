APP_NAME = cypress

# Another way to use variables: https://pawamoy.github.io/posts/pass-makefile-args-as-typed-in-command-line/

log = (echo "$1")
log_success = (echo "\x1B[32m>> $1\x1B[39m")
log_error = (>&2 echo "\x1B[31m>> $1\x1B[39m" && exit 1)

# This will output the help for each task thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html.
# See also: https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build
build: ## Builds the docker image
	@echo "Building image ..."
	@docker build -t ${APP_NAME} .

.PHONY: tag
tag: ## Tags the docker image
	@echo "Tagging image ..."
	@docker image tag ${APP_NAME} sirajeddineaissa/${APP_NAME}

.PHONY: push
push: ## Pushes the docker image
	@echo "Pushing image ..."
	@docker push sirajeddineaissa/${APP_NAME}