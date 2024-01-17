SHELL := /bin/bash
.PHONY: container-init container-remove

container-init:
	@chmod +x ./bin/gene_docker_compose_env.sh
	@chmod +x ./bin/setup_docker_environment.sh
	@./bin/setup_docker_environment.sh

container-remove:
	@chmod +x ./bin/reset_docker_environment.sh
	@sudo ./bin/reset_docker_environment.sh