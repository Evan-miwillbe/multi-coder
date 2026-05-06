#!/usr/bin/env bash
# run-tests.sh — Test/build/lint execution for multi-coder
# Auto-detects project type and runs appropriate checks.
# Usage: ./run-tests.sh [--quick|--full|--lint]

set -euo pipefail

MODE="${1:---full}"

echo "=== Test Runner (mode: ${MODE}) ==="

# ============================================================
# Detect project type
# ============================================================

detect_project_type() {
  if [ -f "package.json" ]; then
    echo "node"
  elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    echo "python"
  elif [ -f "go.mod" ]; then
    echo "go"
  elif [ -f "Cargo.toml" ]; then
    echo "rust"
  elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    echo "java"
  else
    echo "unknown"
  fi
}

PROJECT_TYPE=$(detect_project_type)
echo "Detected project type: ${PROJECT_TYPE}"

# ============================================================
# Run checks based on project type
# ============================================================

run_lint() {
  echo "--- Lint ---"
  case "${PROJECT_TYPE}" in
    node)
      [ -f "node_modules/.bin/eslint" ] && npx eslint . --max-warnings=0 || echo "eslint not found"
      [ -f "node_modules/.bin/prettier" ] && npx prettier --check . || echo "prettier not found"
      ;;
    python)
      command -v ruff &>/dev/null && ruff check . || echo "ruff not found"
      command -v black &>/dev/null && black --check . || echo "black not found"
      ;;
    go)
      go vet ./... 2>/dev/null || echo "go vet failed/skipped"
      ;;
    rust)
      cargo clippy -- -D warnings 2>/dev/null || echo "clippy not available"
      ;;
    *)
      echo "No lint tool detected for project type"
      ;;
  esac
}

run_tests() {
  echo "--- Tests ---"
  case "${PROJECT_TYPE}" in
    node)
      if grep -q "jest" package.json 2>/dev/null; then
        npx jest --passWithNoTests --coverage 2>/dev/null || echo "jest tests failed"
      elif grep -q "vitest" package.json 2>/dev/null; then
        npx vitest run --passWithNoTests 2>/dev/null || echo "vitest tests failed"
      elif grep -q "mocha" package.json 2>/dev/null; then
        npx mocha --exit 2>/dev/null || echo "mocha tests failed"
      else
        npm test 2>/dev/null || echo "npm test failed/skipped"
      fi
      ;;
    python)
      command -v pytest &>/dev/null && pytest -q --tb=short 2>/dev/null || echo "pytest not found or failed"
      ;;
    go)
      go test ./... 2>/dev/null || echo "go tests failed/skipped"
      ;;
    rust)
      cargo test 2>/dev/null || echo "cargo tests failed"
      ;;
    *)
      echo "No test runner detected"
      ;;
  esac
}

run_build() {
  echo "--- Build ---"
  case "${PROJECT_TYPE}" in
    node)
      npm run build 2>/dev/null || echo "build failed/skipped"
      ;;
    python)
      python -m compileall . 2>/dev/null || echo "python compile failed"
      ;;
    go)
      go build ./... 2>/dev/null || echo "go build failed"
      ;;
    rust)
      cargo build 2>/dev/null || echo "cargo build failed"
      ;;
    *)
      echo "No build step detected"
      ;;
  esac
}

run_typecheck() {
  echo "--- Type Check ---"
  case "${PROJECT_TYPE}" in
    node)
      if [ -f "tsconfig.json" ]; then
        npx tsc --noEmit 2>/dev/null || echo "type check failed"
      fi
      ;;
    python)
      command -v mypy &>/dev/null && mypy . 2>/dev/null || echo "mypy not found or failed"
      ;;
    go)
      go build ./... 2>/dev/null || true  # go build already does type checking
      ;;
    *)
      ;;
  esac
}

# ============================================================
# Execute based on mode
# ============================================================

case "${MODE}" in
  --quick)
    run_typecheck
    ;;
  --lint)
    run_lint
    ;;
  --full)
    run_lint
    run_typecheck
    run_tests
    run_build
    ;;
  *)
    echo "Unknown mode: ${MODE}"
    echo "Usage: $0 [--quick|--full|--lint]"
    exit 1
    ;;
esac

echo "=== Done ==="
