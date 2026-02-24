#!/bin/sh
set -eu

# Build a print-ready PDF from the chapter markdown files.
# This script strips YAML frontmatter (Starlight-specific),
# promotes headings, and converts to a single PDF via Pandoc + LaTeX.
# Written in POSIX sh for compatibility with Alpine-based containers.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$REPO_ROOT/pdf/build"
OUTPUT="$REPO_ROOT/psoriasis-book.pdf"

mkdir -p "$BUILD_DIR"

# Part dividers: return part title for a chapter file, empty if none
get_part_title() {
  case "$1" in
    "src/content/docs/01-introduction.md")        echo "Part I: Foundation \\& Context" ;;
    "src/content/docs/04-immune-system.md")        echo "Part II: Understanding the Disease" ;;
    "src/content/docs/08-clinical-presentation.md") echo "Part III: Clinical Practice" ;;
    "src/content/docs/12-lifestyle-diet.md")       echo "Part IV: Living with Psoriasis" ;;
    "src/content/docs/16-therapeutic-landscape.md") echo "Part V: Treatment" ;;
    "src/content/docs/19-landmark-studies.md")      echo "Part VI: Research \\& Future" ;;
    "src/content/docs/22-registries.md")           echo "Appendices" ;;
    *) ;;
  esac
}

counter=0
while IFS= read -r chapter_file; do
  # Skip empty lines and comments
  case "$chapter_file" in
    ""|\#*) continue ;;
  esac

  full_path="$REPO_ROOT/$chapter_file"

  if [ ! -f "$full_path" ]; then
    echo "WARNING: $full_path not found, skipping" >&2
    continue
  fi

  # Insert part divider if this chapter starts a new part
  part_title=$(get_part_title "$chapter_file")
  if [ -n "$part_title" ]; then
    part_file=$(printf "%s/%03d-part.md" "$BUILD_DIR" "$counter")
    printf '\n\\part{%s}\n\n' "$part_title" > "$part_file"
    counter=$((counter + 1))
  fi

  outfile=$(printf "%s/%03d.md" "$BUILD_DIR" "$counter")

  # Extract title from frontmatter for use as chapter heading
  title=$(awk '
    BEGIN { in_fm=0 }
    /^---$/ {
      if (in_fm == 0) { in_fm=1; next }
      else { exit }
    }
    in_fm == 1 && /^title:/ {
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
      BEGIN { in_fm=0; fm_done=0 }
      /^---$/ {
        if (fm_done == 0) {
          if (in_fm == 0) { in_fm=1; next }
          else { fm_done=1; in_fm=0; next }
        }
      }
      in_fm == 1 { next }
      { print }
    ' "$full_path"
  } | sed 's/^## /# /; s/^### /## /; s/^#### /### /' \
    | sed 's/📎/*/g; s/⚠/WARNING:/g' \
    > "$outfile"

  counter=$((counter + 1))
done < "$SCRIPT_DIR/chapter-order.txt"

# Collect all processed files in order (space-separated, no arrays needed)
file_count=0
chapter_files=""
for f in "$BUILD_DIR"/*.md; do
  chapter_files="$chapter_files $f"
  file_count=$((file_count + 1))
done

if [ "$file_count" -eq 0 ]; then
  echo "ERROR: No chapter files found in $BUILD_DIR" >&2
  exit 1
fi

echo "Building PDF from $file_count files..."

# Run Pandoc
# shellcheck disable=SC2086
pandoc \
  --metadata-file="$SCRIPT_DIR/metadata.yaml" \
  --pdf-engine=xelatex \
  --top-level-division=chapter \
  --toc \
  --toc-depth=2 \
  --resource-path="$REPO_ROOT" \
  -o "$OUTPUT" \
  $chapter_files

echo "PDF generated: $OUTPUT"

# Clean up
rm -rf "$BUILD_DIR"
