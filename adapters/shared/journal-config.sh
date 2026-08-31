#!/usr/bin/env bash
#
# Resolve and store the user-level binding to a private journal repository.
#
# A private journal is per user, not per project: its location differs on every
# machine, so it must never be recorded in this toolkit or in a consuming
# project. This helper keeps it in one user-level file instead, written at
# adapter installation or on the first clock-in that finds none.
#
# Usage:
#   ./journal-config.sh get                     # resolved binding; exit 3 if unbound
#   ./journal-config.sh set --path <dir> [--clock-in <rel>] [--clock-out <rel>]
#   ./journal-config.sh disable                 # record "no private journal"
#   ./journal-config.sh forget                  # remove the binding, ask again
#   ./journal-config.sh config-path             # where the binding is stored
#
# Options:
#   --config <file>   use this file instead of the default location
#
# Resolution order for `get`:
#   1. ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL — a directory, or `off`.
#   2. ${XDG_CONFIG_HOME:-$HOME/.config}/architecture-knowledge-toolkit/journal.conf
#   3. Neither: exit 3, meaning "ask the user once, then store the answer".
#
# `disable` exists so that "I keep no private journal" is a stored answer. Without
# it, a user without one is asked again every session.
#
# The file is plain `key=value` so that a shell can read it without a JSON
# parser, and it is created with owner-only permissions because it names a
# private repository.

set -euo pipefail

CONFIG_FILE=""

default_config_file() {
  printf '%s/architecture-knowledge-toolkit/journal.conf' \
    "${XDG_CONFIG_HOME:-$HOME/.config}"
}

config_file() {
  if [ -n "$CONFIG_FILE" ]; then
    printf '%s' "$CONFIG_FILE"
  else
    default_config_file
  fi
}

die() {
  printf '%s\n' "$1" >&2
  exit "${2:-1}"
}

read_key() {
  local key="$1" file="$2" line
  [ -f "$file" ] || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      "#"*|"") continue ;;
      "$key="*) printf '%s' "${line#*=}"; return 0 ;;
    esac
  done <"$file"
  return 1
}

# Find a clock skill inside a journal checkout. Matches `clock-in` as well as a
# prefixed name such as `daily-clock-in`; an exact match wins over a prefixed one.
discover_skill() {
  local dir="$1" kind="$2" candidate exact=""
  for candidate in "$dir"/skills/*"$kind"/SKILL.md; do
    [ -f "$candidate" ] || continue
    if [ "$(basename "$(dirname "$candidate")")" = "$kind" ]; then
      exact="$candidate"
      break
    fi
    [ -n "$exact" ] || exact="$candidate"
  done
  [ -n "$exact" ] || return 1
  printf '%s' "${exact#"$dir"/}"
}

emit_enabled() {
  local path="$1" clock_in="$2" clock_out="$3" source="$4"
  printf 'enabled=true\npath=%s\nclock_in=%s\nclock_out=%s\nsource=%s\n' \
    "$path" "$clock_in" "$clock_out" "$source"
}

cmd_get() {
  local file env_value="${ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL:-}"
  file="$(config_file)"

  case "$env_value" in
    "") ;;
    off|none|false)
      printf 'enabled=false\nsource=env\n'
      return 0
      ;;
    *)
      [ -d "$env_value" ] || die "ARCHITECTURE_KNOWLEDGE_TOOLKIT_JOURNAL is not a directory: $env_value" 4
      local resolved clock_in clock_out
      resolved="$(cd "$env_value" && pwd -P)"
      clock_in="$(discover_skill "$resolved" clock-in)" \
        || die "no clock-in skill found in $resolved/skills" 4
      clock_out="$(discover_skill "$resolved" clock-out)" \
        || die "no clock-out skill found in $resolved/skills" 4
      emit_enabled "$resolved" "$clock_in" "$clock_out" env
      return 0
      ;;
  esac

  local enabled
  enabled="$(read_key enabled "$file")" || exit 3

  if [ "$enabled" != true ]; then
    printf 'enabled=false\nsource=config\n'
    return 0
  fi

  local path clock_in clock_out
  path="$(read_key path "$file")" || die "binding in $file has no path" 4
  clock_in="$(read_key clock_in "$file")" || die "binding in $file has no clock_in" 4
  clock_out="$(read_key clock_out "$file")" || die "binding in $file has no clock_out" 4
  emit_enabled "$path" "$clock_in" "$clock_out" config
  if [ ! -d "$path" ]; then
    printf 'unreachable: %s\n' "$path" >&2
  fi
}

write_config() {
  local file="$1" body="$2" dir
  dir="$(dirname "$file")"
  mkdir -p "$dir"
  printf '%s\n' "$body" >"$file"
  chmod 600 "$file"
}

cmd_set() {
  local dir="" clock_in="" clock_out=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --path) dir="${2:?--path requires a directory}"; shift ;;
      --clock-in) clock_in="${2:?--clock-in requires a path}"; shift ;;
      --clock-out) clock_out="${2:?--clock-out requires a path}"; shift ;;
      *) die "unknown argument: $1" 2 ;;
    esac
    shift
  done

  [ -n "$dir" ] || die "set requires --path <dir>" 2
  [ -d "$dir" ] || die "not a directory: $dir" 4
  dir="$(cd "$dir" && pwd -P)"

  if [ -z "$clock_in" ]; then
    clock_in="$(discover_skill "$dir" clock-in)" || die \
      "no clock-in skill found in $dir/skills; pass --clock-in <relative path>" 4
  fi
  if [ -z "$clock_out" ]; then
    clock_out="$(discover_skill "$dir" clock-out)" || die \
      "no clock-out skill found in $dir/skills; pass --clock-out <relative path>" 4
  fi
  [ -f "$dir/$clock_in" ] || die "no such file: $dir/$clock_in" 4
  [ -f "$dir/$clock_out" ] || die "no such file: $dir/$clock_out" 4

  local file
  file="$(config_file)"
  write_config "$file" "$(printf '%s\n' \
    '# architecture-knowledge-toolkit: private journal binding.' \
    '# Written by adapters/shared/journal-config.sh. Per user, never per project.' \
    'enabled=true' \
    "path=$dir" \
    "clock_in=$clock_in" \
    "clock_out=$clock_out")"
  printf 'bound private journal: %s\n' "$dir"
  printf 'stored in %s\n' "$file"
}

cmd_disable() {
  local file
  file="$(config_file)"
  write_config "$file" "$(printf '%s\n' \
    '# architecture-knowledge-toolkit: private journal binding.' \
    '# The user keeps no private journal. Recorded so that clock-in stops asking.' \
    'enabled=false')"
  printf 'recorded: no private journal\n'
  printf 'stored in %s\n' "$file"
}

cmd_forget() {
  local file
  file="$(config_file)"
  if [ -f "$file" ]; then
    rm -f "$file"
    printf 'removed %s\n' "$file"
  else
    printf 'nothing to remove at %s\n' "$file"
  fi
}

COMMAND="${1:-}"
[ $# -gt 0 ] && shift

ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --config) CONFIG_FILE="${2:?--config requires a file}"; shift ;;
    *) ARGS+=("$1") ;;
  esac
  shift
done
set -- ${ARGS+"${ARGS[@]}"}

case "$COMMAND" in
  get) cmd_get "$@" ;;
  set) cmd_set "$@" ;;
  disable) cmd_disable "$@" ;;
  forget) cmd_forget "$@" ;;
  config-path) config_file; printf '\n' ;;
  ""|-h|--help|help) sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' ;;
  *) die "unknown command: $COMMAND" 2 ;;
esac
