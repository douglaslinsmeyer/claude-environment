.PHONY: help test lint install validate clean check-deps setup release-dry-run

# Default target
help:
	@echo "Claude Environment - Available targets:"
	@echo "  make test        - Run all BATS tests"
	@echo "  make lint        - Run ShellCheck on all shell scripts"
	@echo "  make validate    - Run all validation checks"
	@echo "  make install     - Install Claude Environment (global)"
	@echo "  make clean       - Clean test artifacts"
	@echo "  make setup       - Install development dependencies"
	@echo "  make check-deps  - Check if all dependencies are installed"
	@echo "  make release-dry-run - Test semantic release without publishing"

# Check dependencies
check-deps:
	@echo "Checking dependencies..."
	@command -v bats >/dev/null 2>&1 || { echo "❌ BATS not installed"; exit 1; }
	@command -v shellcheck >/dev/null 2>&1 || { echo "❌ ShellCheck not installed"; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "❌ jq not installed"; exit 1; }
	@echo "✅ All dependencies installed"

# Setup development environment
setup:
	@echo "Setting up development environment..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		brew install bats-core shellcheck jq node; \
	elif [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y bats shellcheck jq nodejs npm; \
	else \
		echo "Please install: bats, shellcheck, jq, node manually"; \
		exit 1; \
	fi
	@npm install -g @commitlint/cli @commitlint/config-conventional semantic-release
	@echo "✅ Development environment ready"

# Run all tests
test: check-deps
	@echo "Running test suite..."
	@chmod +x tests/*.sh tests/*.bats
	@bash tests/run_bats_tests.sh

# Lint shell scripts
lint:
	@echo "Running ShellCheck..."
	@find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*" | xargs shellcheck -x
	@echo "✅ Linting passed"

# Validate project files
validate:
	@echo "Validating project files..."
	@echo "  Checking for empty markdown files..."
	@find . -name "*.md" -type f -empty -print -exec false {} +
	@echo "  Validating manifest.json..."
	@jq empty manifest.json
	@echo "  Checking file permissions..."
	@test -x install.sh || { echo "❌ install.sh not executable"; exit 1; }
	@test -x scripts/bump-version.sh || { echo "❌ bump-version.sh not executable"; exit 1; }
	@echo "✅ Validation passed"

# Install Claude Environment
install:
	@./install.sh --force

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf test-results/
	@rm -rf coverage/
	@rm -rf .bats-tmp/
	@find . -name "*.log" -delete
	@echo "✅ Cleaned"

# Run semantic-release in dry-run mode
release-dry-run:
	@echo "Running semantic-release in dry-run mode..."
	@npx semantic-release --dry-run