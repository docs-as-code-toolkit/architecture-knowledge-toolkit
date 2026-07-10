#!/usr/bin/env sh
set -eu

# Unified task runner for the architecture-knowledge-toolkit.
#
# By default every task runs inside the docs-as-code-toolkit `docs-toolbox`
# container image, so local runs and CI use the same reproducible toolchain
# (Ruby, Node.js, Asciidoctor, PlantUML, Graphviz). When no container engine is
# available the task runs locally instead. Each task maps to a documented local
# command; see the README for the local equivalents.

COMMAND="${1:-build}"
if [ "$#" -gt 0 ]; then
  shift
fi

DOCS_TOOLBOX_IMAGE="${DOCS_TOOLBOX_IMAGE:-ghcr.io/docs-as-code-toolkit/docs-toolbox:v1.3.1}"
BUILD_DIR="${BUILD_DIR:-build/architecture}"
SOURCE_DOC="${SOURCE_DOC:-src/docs/doc-001-arc42.adoc}"

usage() {
  cat <<'USAGE'
Usage: ./build.sh <task> [args]

Tasks:
  validate         Validate architecture artifact metadata and relations.
  generate         Validate, then generate derived AsciiDoc fragments/indexes.
  test             Run all tests (Ruby units, Ruby CLI, JS adapter generator).
  test-ruby        Run the Ruby validator/generator unit and CLI tests.
  test-js          Run the JS adapter generator tests (node --test).
  adapters         Regenerate the agent adapters from skills/**/SKILL.md.
  check-adapters   Fail if the generated agent adapters are out of date.
  build            Generate fragments and render the architecture HTML.
  presentation     Render an AsciiDoc slide deck (args: <slides.adoc> [out-dir]).
  all              Run validate, test, check-adapters, and build.
  clean            Remove local architecture build output.
  help             Show this help.

Every task runs inside the docs-toolbox container image when Docker or Podman is
available, and falls back to local execution otherwise. Override the image with
DOCS_TOOLBOX_IMAGE.
USAGE
}

find_engine() {
  if command -v podman >/dev/null 2>&1 && podman info >/dev/null 2>&1; then
    printf '%s\n' "podman"
  elif command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    printf '%s\n' "docker"
  else
    printf '%s\n' ""
  fi
}

run_local_validate() {
  ruby scripts/validate-metamodel.rb
}

run_local_generate() {
  ruby scripts/validate-metamodel.rb --generate
}

run_local_test_ruby() {
  ruby -Itest test/validate_metamodel_test.rb
  ruby -Itest test/validate_metamodel_cli_test.rb
}

run_local_test_js() {
  node --test test/build-agent-adapters.test.mjs
}

run_local_test() {
  run_local_test_ruby
  run_local_test_js
}

run_local_adapters() {
  node scripts/build-agent-adapters.js
}

run_local_check_adapters() {
  node scripts/check-agent-adapters.js
}

run_local_build() {
  run_local_generate
  mkdir -p "$BUILD_DIR"
  asciidoctor \
    -r asciidoctor-diagram \
    -r asciidoctor-diagram/plantuml \
    --failure-level=ERROR \
    -a skip-front-matter \
    -a toc=left \
    -a sectanchors \
    -a icons=font \
    -a imagesdir=. \
    -a imagesoutdir="$BUILD_DIR" \
    -D "$BUILD_DIR" \
    -o index.html \
    "$SOURCE_DOC"
  echo "Built architecture HTML: $BUILD_DIR/index.html"
}

run_local_presentation() {
  sh scripts/render-presentation.sh "$@"
}

run_local_all() {
  run_local_validate
  run_local_test
  run_local_check_adapters
  run_local_build
}

run_local() {
  case "$COMMAND" in
    validate) run_local_validate ;;
    generate) run_local_generate ;;
    test) run_local_test ;;
    test-ruby) run_local_test_ruby ;;
    test-js) run_local_test_js ;;
    adapters) run_local_adapters ;;
    check-adapters) run_local_check_adapters ;;
    build) run_local_build ;;
    presentation) run_local_presentation "$@" ;;
    all) run_local_all ;;
    clean)
      rm -rf "$BUILD_DIR"
      echo "Removed $BUILD_DIR"
      ;;
    help|-h|--help) usage ;;
    *)
      usage
      exit 2
      ;;
  esac
}

run_in_container() {
  ENGINE="$1"
  shift

  "$ENGINE" run --rm \
    -e ARCHITECTURE_KNOWLEDGE_TOOLKIT_IN_CONTAINER=1 \
    -e BUILD_DIR="$BUILD_DIR" \
    -e SOURCE_DOC="$SOURCE_DOC" \
    -v "$PWD":/app \
    -w /app \
    "$DOCS_TOOLBOX_IMAGE" \
    sh ./build.sh "$COMMAND" "$@"
}

# Inside the container: always run locally.
if [ "${ARCHITECTURE_KNOWLEDGE_TOOLKIT_IN_CONTAINER:-}" = "1" ]; then
  run_local "$@"
  exit 0
fi

case "$COMMAND" in
  clean|help|-h|--help)
    run_local "$@"
    ;;
  validate|generate|test|test-ruby|test-js|adapters|check-adapters|build|presentation|all)
    ENGINE="$(find_engine)"
    if [ -n "$ENGINE" ]; then
      run_in_container "$ENGINE" "$@"
    else
      echo "No container engine found. Running '$COMMAND' locally." >&2
      run_local "$@"
    fi
    ;;
  *)
    usage
    exit 2
    ;;
esac
