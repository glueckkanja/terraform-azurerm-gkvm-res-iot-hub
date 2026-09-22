SHELL := /bin/bash

$(shell curl -H 'Cache-Control: no-cache, no-store' -sSL "https://raw.githubusercontent.com/Azure/tfmod-scaffold/main/avmmakefile" -o avmmakefile)
-include avmmakefile

# Override the upstream conftest target: the scaffold script relies on
# `conftest --update git::...`, which breaks with conftest >= v0.70.0 because the
# policy library contains symlinks. See scripts/conftest.sh for details.
.PHONY: conftest
conftest:
	@./scripts/conftest.sh
