#!/usr/bin/env bats

# ShellCheck tests for all shell scripts in the project

setup() {
    # Get the project root directory
    export BATS_TEST_DIRNAME="${BATS_TEST_DIRNAME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
    export PROJECT_ROOT
    PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "shellcheck is available" {
    command -v shellcheck >/dev/null 2>&1 || skip "ShellCheck not installed"
    run shellcheck --version
    [ "$status" -eq 0 ]
}

@test "install.sh passes ShellCheck" {
    command -v shellcheck >/dev/null 2>&1 || skip "ShellCheck not installed"
    run shellcheck -x "$PROJECT_ROOT/install.sh"
    if [ "$status" -ne 0 ]; then
        echo "ShellCheck output:" >&2
        echo "$output" >&2
    fi
    [ "$status" -eq 0 ]
}

@test "bump-version.sh passes ShellCheck" {
    command -v shellcheck >/dev/null 2>&1 || skip "ShellCheck not installed"
    run shellcheck -x "$PROJECT_ROOT/scripts/bump-version.sh"
    if [ "$status" -ne 0 ]; then
        echo "ShellCheck output:" >&2
        echo "$output" >&2
    fi
    [ "$status" -eq 0 ]
}

@test "run_bats_tests.sh passes ShellCheck" {
    command -v shellcheck >/dev/null 2>&1 || skip "ShellCheck not installed"
    run shellcheck -x "$PROJECT_ROOT/tests/run_bats_tests.sh"
    if [ "$status" -ne 0 ]; then
        echo "ShellCheck output:" >&2
        echo "$output" >&2
    fi
    [ "$status" -eq 0 ]
}

@test "all BATS test files pass ShellCheck" {
    command -v shellcheck >/dev/null 2>&1 || skip "ShellCheck not installed"

    # Find all .bats files and check them with appropriate exclusions
    local failed=0
    while IFS= read -r -d '' bats_file; do
        # Run ShellCheck with BATS-specific exclusions
        if ! shellcheck -x \
            -e SC2030,SC2031 \
            -e SC2317 \
            -e SC2164 \
            "$bats_file" >/dev/null 2>&1; then
            echo "ShellCheck failed for: $bats_file" >&2
            shellcheck -x -e SC2030,SC2031 -e SC2317 -e SC2164 "$bats_file" >&2
            ((failed++))
        fi
    done < <(find "$PROJECT_ROOT/tests" -name "*.bats" -type f -print0)

    [ "$failed" -eq 0 ]
}

@test "all shell scripts have proper shebang" {
    local failed=0

    # Check main scripts
    for script in "$PROJECT_ROOT/install.sh" "$PROJECT_ROOT/scripts/bump-version.sh" "$PROJECT_ROOT/tests/run_bats_tests.sh"; do
        if [[ -f "$script" ]]; then
            first_line=$(head -n1 "$script")
            if [[ ! "$first_line" =~ ^#!/(usr/)?bin/(env )?bash ]]; then
                echo "Missing or incorrect shebang in: $script" >&2
                echo "Found: $first_line" >&2
                ((failed++))
            fi
        fi
    done

    [ "$failed" -eq 0 ]
}

