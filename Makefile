SHELL := /bin/bash -euo pipefail
.PHONY: test

## ----------------------------------------------------------------------
## Makefile to run terragrunt commands to setup nodes for polkadot
## ----------------------------------------------------------------------

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

.PHONY: all test clean docs

help: ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

clear-cache:	                ## Clear the cache of files left by terragrunt
	@find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && \
	find . -type d -name ".terraform" -prune -exec rm -rf {} \; && echo 'cleared cache'

clear-configs:	                ## Clear the cache of files left by terragrunt
	@find . -type f -name "*.tfvars" -prune -exec rm {} \; && \
    find . -type f -name "global.yaml" -prune -exec rm {} \; && \
    find . -type f -name "secrets.yaml" -prune -exec rm {} \; && echo 'cleared configs'

clear-tackle-runs:	                ## Clear the cache of files left by terragrunt
	@find . -type f -name "*.rerun.yml" -prune -exec rm {} \; && \
    find . -type f -name "*.record.yaml" -prune -exec rm {} \;

docs: 							## generate Sphinx HTML documentation, including API docs
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

test:
	@ssh-keygen -q -t rsa -N '' -f /tmp/test-ssh-key <<<y 2>&1 >/dev/null
	python -m pytest tests
