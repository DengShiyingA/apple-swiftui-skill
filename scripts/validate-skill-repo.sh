#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$repo_root/SKILL.md"
readme_file="$repo_root/README.md"

description_line_number="$(grep -n '^description:' "$skill_file" | head -n1 | cut -d: -f1)"

if [[ -z "${description_line_number:-}" ]]; then
  echo "SKILL.md frontmatter is missing a description field"
  exit 1
fi

description_block="$(sed -n "${description_line_number},/^---$/p" "$skill_file" | sed '1d;$d')"
normalized_description="$(printf '%s\n' "$description_block" | tr '\n' ' ' | sed 's/^[[:space:]]*//; s/[[:space:]]\+/ /g')"

if [[ "$normalized_description" != Use\ when* ]]; then
  echo "SKILL.md description should start with 'Use when' for skill discovery"
  exit 1
fi

if ! grep -q '^## 快速导航$' "$skill_file"; then
  echo "SKILL.md should include a quick navigation section near the top"
  exit 1
fi

missing_paths=()

while IFS= read -r path; do
  trimmed_path="${path%%#*}"
  trimmed_path="${trimmed_path%"${trimmed_path##*[![:space:]]}"}"
  trimmed_path="${trimmed_path#"${trimmed_path%%[![:space:]]*}"}"
  [[ -z "$trimmed_path" ]] && continue

  repo_path="$repo_root/$trimmed_path"
  if [[ ! -e "$repo_path" ]]; then
    missing_paths+=("$trimmed_path")
  fi
done < <(
  awk '
    /^## 文件说明$/ { in_tree_section = 1; next }
    in_tree_section && /^```$/ {
      in_block = !in_block
      if (!in_block) {
        exit
      }
      next
    }
    !in_block { next }
    /──/ {
      line = $0
      indent = match(line, /[^ ]/) - 1
      sub(/^.*── /, "", line)
      sub(/[[:space:]]+#.*$/, "", line)

      if (indent > 0 && parent_dir != "") {
        print parent_dir line
      } else {
        print line
      }

      if (line ~ /\/$/) {
        parent_dir = line
      } else if (indent == 0) {
        parent_dir = ""
      }
    }
  ' "$readme_file"
)

if (( ${#missing_paths[@]} > 0 )); then
  printf 'README.md references missing repository paths:\n'
  printf ' - %s\n' "${missing_paths[@]}"
  exit 1
fi

echo "Skill repository validation passed."
