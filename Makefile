.DEFAULT_GOAL := usage

.PHONY: install
install: ## Install development environment
	@brew install --quiet pre-commit && pre-commit install --hook-type commit-msg --overwrite

.PHONY: usage
usage: ## Prints available commands
	@# Use `##` to denote command descriptions (eg previous line)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'
