#!/usr/bin/env bash
set -euo pipefail

die() { echo "compile.sh: $*" >&2; exit 1; }

if [ "$#" -ne 1 ]; then
  echo "Использование: $0 <файл.tex>" >&2
  exit 2
fi

src=$1
[ -f "$src" ] || die "файл не найден: $src"

self=$(realpath "$0")

if [ "${VKR_ENV:-}" != "1" ]; then
  command -v nix >/dev/null 2>&1 || die "нет nix: окружение из flake.nix не собрать"
  exec nix develop "$(dirname "$self")" --command bash "$self" "$@"
fi

cd "$(dirname "$src")"
base=$(basename "$src")

latexmk -xelatex -interaction=nonstopmode -halt-on-error "$base"

pdf="${base%.tex}.pdf"
[ -f "$pdf" ] || die "PDF не создан: $pdf"
echo "PDF: $(pwd)/$pdf"
