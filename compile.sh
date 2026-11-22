#!/usr/bin/env bash
set -euo pipefail

die() { echo "compile.sh: $*" >&2; exit 1; }

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <file.tex>" >&2
  exit 2
fi

src=$1
[ -f "$src" ] || die "file not found: $src"

self=$(realpath "$0")

if [ "${VKR_ENV:-}" != "1" ]; then
  command -v nix >/dev/null 2>&1 || die "nix not found: cannot build the environment from flake.nix"
  exec nix develop "$(dirname "$self")" --command bash "$self" "$@"
fi

cd "$(dirname "$src")"
base=$(basename "$src")

latexmk -xelatex -interaction=nonstopmode -halt-on-error "$base"

pdf="${base%.tex}.pdf"
[ -f "$pdf" ] || die "PDF was not created: $pdf"
echo "PDF: $(pwd)/$pdf"
