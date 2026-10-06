#!/bin/sh
set -eu

test "$#" -eq 1 || { echo 'usage: sh tests/moc.sh /absolute/path/to/lito' >&2; exit 1; }
compiler=$1
package_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$package_root/build"
run_root=$(mktemp -d "$package_root/build/moc.XXXXXX")
printf 'Qt moc output: %s\n' "$run_root"
mkdir "$run_root/package"
cp -R "$package_root/lito.toml" "$package_root/lib.lua" "$package_root/qt" \
  "$package_root/tests" "$run_root/package/"
cd "$run_root/package/tests/moc"

for pass in first warm; do
  if ! "$compiler" build --offline --profile release --build-dir "$run_root/build" \
      -j 4 --verbose > "$run_root/$pass.log" 2>&1; then
    cat "$run_root/$pass.log"
    exit 1
  fi
  "$run_root/build/bin/qt-moc-smoke/qt-moc-smoke"
done
grep -F '@lito.qt <- lito-qt (path+' "$run_root/first.log"
if grep -F '[build-tool-run] ' "$run_root/warm.log"; then
  echo 'Unexpected moc regeneration in warm build' >&2
  exit 1
fi
printf 'External Qt moc checks passed\n'
