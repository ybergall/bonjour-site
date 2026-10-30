#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

canonical_file="$repo_root/publichandlers/QRCodeInfo.ashx_QRkey=2AC0738C7AC95539B504D57849070A23&matricule=000458908/index_files/ulb_BUop_041s.jpg"
shared_dir="$repo_root/publichandlers/shared"
mkdir -p "$shared_dir"

if [[ ! -f "$canonical_file" ]]; then
  echo "Canonical image not found: $canonical_file" >&2
  exit 1
fi

cp "$canonical_file" "$shared_dir/ulb-logo.jpg"

# Rewrite each generated page to reuse the same image instead of keeping one copy per folder.
find "$repo_root/publichandlers" -path '*/index.html' -type f | while IFS= read -r file; do
  if [[ "$file" == "$shared_dir"/* ]]; then
    continue
  fi

  perl -0pi -e 's#src="[^"]*ulb_[^"]*\.jpg"#src="../shared/ulb-logo.jpg"#g' "$file"
  perl -0pi -e 's#src="[^"]*ulb_[^"]*\.jpg"#src="../shared/ulb-logo.jpg"#g' "$file"
done

echo "Shared logo installed at $shared_dir/ulb-logo.jpg"
echo "All generated pages now point to the shared asset."
