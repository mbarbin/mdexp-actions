# SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT

.PHONY: check
check: shellcheck ## Run all checks

.PHONY: shellcheck
shellcheck: ## Lint shell scripts with shellcheck
	@script/shellcheck.sh

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'
