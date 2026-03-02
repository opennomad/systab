# systab task runner — `just` to list all recipes

# List available recipes
default:
    @just --list

# Run ShellCheck linter
lint:
    shellcheck systab

# Run unit tests
test:
    ./test.sh

# Run demo tape command tests (no VHS required)
tape-test:
    ./demo/test-tapes.sh

# Run all checks: lint + unit tests + tape tests
check: lint test tape-test

# Record demo GIFs with VHS
record:
    vhs demo/quickstart.tape
    vhs demo/all-features.tape
