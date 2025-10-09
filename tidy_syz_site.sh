#!/usr/bin/env bash
# tidy_syz_site.sh — normalize assets & cleanup for syzygysys.github.io
# Usage:
#   ./tidy_syz_site.sh              # dry-run
#   ./tidy_syz_site.sh --apply      # perform changes

set -euo pipefail
APPLY=0
[[ "${1:-}" == "--apply" ]] && APPLY=1

root="${PWD}"
say() { echo "• $*"; }
do_mv() { if ((APPLY)); then ${GIT_MV} mv "$1" "$2"; else say "mv '$1' -> '$2'"; fi; }
do_rm() { if ((APPLY)); then rm -f "$@"; else say "rm $*"; fi; }

# Prefer git mv if repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_MV="git"
else
  GIT_MV=":"
fi

# 0) Sanity: ensure we’re at site root (look for known files)
for must in "assets" "docs" "index.html" "README.md"; do
  [[ -e "$must" ]] || { echo "ERR: Not at site root (missing $must)"; exit 1; }
done

say "=== DRY RUN === (add --apply to execute changes)" && ((APPLY)) && say "=== APPLY MODE ==="

# 1) Remove Windows Zone.Identifier streams and .lnk artifacts
say "1) Removing Zone.Identifier & .lnk"
mapfile -t zmeta < <(find assets -type f -name '*:Zone.Identifier' 2>/dev/null)
mapfile -t lnk   < <(find . -type f -name '*.lnk' 2>/dev/null)
((${#zmeta[@]})) && do_rm "${zmeta[@]}"
((${#lnk[@]}))   && do_rm "${lnk[@]}"

# 2) Move HTML that lives under css/ → templates/
say "2) Moving CSS-embedded HTML to templates/"
mkdir -p assets/templates
if [[ -f assets/css/syz_site_template.html ]]; then
  do_mv assets/css/syz_site_template.html assets/templates/syz_site_template.html
fi

# 3) Move markdown living under images/ to a docs/reports area
say "3) Relocating markdown from images/ to reports/"
mkdir -p docs/reports
if [[ -f assets/images/links.updated.md ]]; then
  do_mv assets/images/links.updated.md docs/reports/links.updated.md
fi

# 4) Consolidate brand SVGs under /assets/brand (update references)
say "4) Consolidating brand SVGs under assets/brand/"
mkdir -p assets/brand
declare -a BRAND=(syzygysys_logo_mark.svg syzygysys_logo_mark_rounded.svg syzygysys_logo_mark_whitebg.svg)
for f in "${BRAND[@]}"; do
  if [[ -f "assets/$f" && ! -f "assets/brand/$f" ]]; then
    do_mv "assets/$f" "assets/brand/$f"
  fi
done

# 4b) Update references from /assets/<file> → /assets/brand/<file>
say "4b) Rewriting references to brand assets"
for f in "${BRAND[@]}"; do
  from="/assets/$f"
  to="/assets/brand/$f"
  mapfile -t hits < <(grep -RIl --exclude-dir=.git -- "$from" . || true)
  if ((${#hits[@]})); then
    if ((APPLY)); then
      sed -i "s|$from|$to|g" "${hits[@]}"
    else
      printf "  would rewrite %s in:\n" "$from"
      printf "    %s\n" "${hits[@]}"
    fi
  fi
done

# 5) Fix obvious typos (REAME.md → README.md)
say "5) Fixing obvious typos"
if [[ -f terminology_fodder/REAME.md ]]; then
  do_mv terminology_fodder/REAME.md terminology_fodder/README.md
fi

# 6) Move staging/horked directories into archive/snapshots
say "6) Archiving horked directories"
mkdir -p archive/snapshots
for d in horked horked-2; do
  if [[ -d "$d" ]]; then
    do_mv "$d" "archive/snapshots/$d"
  fi
done

# 7) Clean duplicate brand files living at multiple paths (no-op if already moved)
say "7) Checking for duplicate brand assets"
for f in "${BRAND[@]}"; do
  [[ -f "assets/$f" && -f "assets/brand/$f" ]] && do_rm "assets/$f"
done

say "Done."
if ((APPLY==0)); then
  echo
  echo "Dry-run complete. Re-run with --apply to execute."
fi
