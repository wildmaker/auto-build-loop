#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") --target <ABS_TARGET_DIR> [--source <ABS_SOURCE_DIR>] [--dry-run]

Behavior:
  - Copy all files from source skills dir to target dir
  - Overwrite same-name files/dirs in target
  - DO NOT delete extra files existing only in target

Defaults:
  --source defaults to <repo_root>/codex/skills based on script location
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_SOURCE="$(cd "$SKILL_DIR/../../.." && pwd)/codex/skills"

TARGET=""
SOURCE="$DEFAULT_SOURCE"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --source)
      SOURCE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Error: --target is required" >&2
  usage
  exit 2
fi

if [[ "${TARGET:0:1}" != "/" ]]; then
  echo "Error: --target must be an absolute path" >&2
  exit 2
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "Error: source dir not found: $SOURCE" >&2
  exit 2
fi

mkdir -p "$TARGET"

RSYNC_FLAGS=(-a --itemize-changes --exclude ".DS_Store")
if [[ $DRY_RUN -eq 1 ]]; then
  RSYNC_FLAGS+=(--dry-run)
fi

echo "[sync] source: $SOURCE"
echo "[sync] target: $TARGET"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "[sync] mode: dry-run"
else
  echo "[sync] mode: apply"
fi

rsync "${RSYNC_FLAGS[@]}" "$SOURCE/" "$TARGET/"

# Verification: all source files must exist in target after sync.
# In dry-run mode, report counts only and skip hard existence checks.
src_list="$(mktemp)"
dst_list="$(mktemp)"
trap 'rm -f "$src_list" "$dst_list"' EXIT

(cd "$SOURCE" && find . -type f ! -name ".DS_Store" | sort) > "$src_list"
(cd "$TARGET" && find . -type f ! -name ".DS_Store" | sort) > "$dst_list"

missing="$(comm -23 "$src_list" "$dst_list" || true)"
extra_count="$(comm -13 "$src_list" "$dst_list" | wc -l | tr -d ' ')"
src_count="$(wc -l < "$src_list" | tr -d ' ')"
dst_count="$(wc -l < "$dst_list" | tr -d ' ')"

echo "[verify] source_file_count=$src_count"
echo "[verify] target_file_count=$dst_count"
echo "[verify] target_extra_file_count=$extra_count"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[verify] dry-run: skipped strict missing-file check."
  exit 0
fi

if [[ -n "$missing" ]]; then
  echo "[verify] missing files in target:" >&2
  echo "$missing" >&2
  exit 1
fi

echo "[verify] OK: all source files are present in target."
