#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shared_dir="$repo_root/publichandlers/shared"
mkdir -p "$shared_dir"

# Keep a single canonical logo in one shared folder instead of one copy per generated page.
canonical_file="$(find "$repo_root/publichandlers" -type f -iname 'ulb_*.jpg' ! -path "$shared_dir/*" | sort | head -n 1)"
if [[ -z "$canonical_file" ]]; then
  echo "No logo image found under $repo_root/publichandlers" >&2
  exit 1
fi

cp "$canonical_file" "$shared_dir/ulb-logo.jpg"

# Rewrite every generated page to use the same shared asset.
find "$repo_root/publichandlers" -path '*/index.html' -type f ! -path "$shared_dir/*" -print0 | while IFS= read -r -d '' file; do
  perl -0pi -e 's#src="[^"]*ulb_[^"]*\.jpg"#src="../shared/ulb-logo.jpg"#g' "$file"
  perl -0pi -e 's#src="[^"]*ulb_[^"]*\.jpg"#src="../shared/ulb-logo.jpg"#g' "$file"
done

# Remove the duplicate JPG files after all pages point to the shared one.
find "$repo_root/publichandlers" -type f -iname '*.jpg' ! -path "$shared_dir/*" -delete
find "$repo_root/publichandlers" -type d \( -name '*_files' -o -name 'index_files' \) -empty -delete

# Best-effort cleanup: if any leftover page still references a local JPG, strip it.
find "$repo_root/publichandlers" -path '*/index.html' -type f ! -path "$shared_dir/*" -print0 | while IFS= read -r -d '' file; do
  perl -0pi -e 's#src="[^"]*\.jpg"#src="../shared/ulb-logo.jpg"#g' "$file"
done

printf 'Shared logo installed at %s\n' "$shared_dir/ulb-logo.jpg"
printf 'Duplicate JPG files removed from generated pages.\n'
