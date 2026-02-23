#!/usr/bin/env bash
set -euo pipefail

# Build a print-ready PDF from the chapter markdown files.
# This script strips YAML frontmatter (Starlight-specific),
# promotes headings, and converts to a single PDF via Pandoc + LaTeX.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$REPO_ROOT/pdf/build"
OUTPUT="$REPO_ROOT/psoriasis-book.pdf"

mkdir -p "$BUILD_DIR"

# Part dividers: chapter file -> part title
declare -A PART_BEFORE
PART_BEFORE["src/content/docs/01-introduction.md"]="Part I: Foundation \\& Context"
PART_BEFORE["src/content/docs/04-immune-system.md"]="Part II: Understanding the Disease"
PART_BEFORE["src/content/docs/08-clinical-presentation.md"]="Part III: Clinical Practice"
PART_BEFORE["src/content/docs/12-lifestyle-diet.md"]="Part IV: Living with Psoriasis"
PART_BEFORE["src/content/docs/16-therapeutic-landscape.md"]="Part V: Treatment"
PART_BEFORE["src/content/docs/19-landmark-studies.md"]="Part VI: Research \\& Future"
PART_BEFORE["src/content/docs/22-registries.md"]="Appendices"

counter=0
while IFS= read -r chapter_file; do
  # Skip empty lines and comments
  [[ -z "$chapter_file" || "$chapter_file" == \#* ]] && continue

  full_path="$REPO_ROOT/$chapter_file"

  if [[ ! -f "$full_path" ]]; then
    echo "WARNING: $full_path not found, skipping" >&2
    continue
  fi

  # Insert part divider if this chapter starts a new part
  if [[ -n "${PART_BEFORE[$chapter_file]:-}" ]]; then
    part_file=$(printf "%s/%03d-part.md" "$BUILD_DIR" "$counter")
    printf '\n\\part{%s}\n\n' "${PART_BEFORE[$chapter_file]}" > "$part_file"
    counter=$((counter + 1))
  fi

  outfile=$(printf "%s/%03d.md" "$BUILD_DIR" "$counter")

  # Extract title from frontmatter for use as chapter heading
  title=$(awk '
    BEGIN { in_fm=0 }
    /^---$/ { if (!in_fm) { in_fm=1; next } else { exit } }
    in_fm && /^title:/ {
      sub(/^title:[[:space:]]*/, "")
      gsub(/^"/, ""); gsub(/"$/, "")
      gsub(/'\''/, "")
      print
    }
  ' "$full_path")

  # Strip YAML frontmatter, promote headings, replace emoji, add chapter title
  {
    # Add chapter title as H1
    echo "# $title"
    echo ""

    # Process the content
    awk '
      BEGIN { in_frontmatter=0; frontmatter_done=0 }
      /^---$/ && !frontmatter_done {
        if (in_frontmatter) { frontmatter_done=1; next }
        else { in_frontmatter=1; next }
      }
      in_frontmatter { next }
      { print }
    ' "$full_path"
  } | sed 's/^## /# /; s/^### /## /; s/^#### /### /' \
    | sed 's/📎/*/g; s/⚠/WARNING:/g' \
    > "$outfile"

  counter=$((counter + 1))
done < "$SCRIPT_DIR/chapter-order.txt"

# Collect all processed files in order
chapter_files=()
for f in "$BUILD_DIR"/*.md; do
  chapter_files+=("$f")
done

if [[ ${#chapter_files[@]} -eq 0 ]]; then
  echo "ERROR: No chapter files found in $BUILD_DIR" >&2
  exit 1
fi

echo "Building PDF from ${#chapter_files[@]} files..."

# Run Pandoc
pandoc \
  --metadata-file="$SCRIPT_DIR/metadata.yaml" \
  --pdf-engine=xelatex \
  --top-level-division=chapter \
  --toc \
  --toc-depth=2 \
  --resource-path="$REPO_ROOT" \
  -o "$OUTPUT" \
  "${chapter_files[@]}"

echo "PDF generated: $OUTPUT"

# Clean up
rm -rf "$BUILD_DIR"
