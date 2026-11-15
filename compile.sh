#!/usr/bin/env bash
# Сборка PDF из указанного .tex-файла: compile.sh <файл.tex>
#
# Внутри `nix develop` скрипт работает напрямую (VKR_ENV=1 выставляет
# shellHook). Вне оболочки он один раз перезапускается через `nix develop`,
# поэтому активировать окружение вручную не нужно.
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

# latexmk запускается из каталога файла: рабочие файлы и PDF лягут рядом с ним.
cd "$(dirname "$src")"
base=$(basename "$src")

latexmk -xelatex -interaction=nonstopmode -halt-on-error "$base"

pdf="${base%.tex}.pdf"
[ -f "$pdf" ] || die "PDF не создан: $pdf"
echo "PDF: $(pwd)/$pdf"
