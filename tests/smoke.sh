#!/bin/sh
set -eu

test "$#" -eq 1 || { echo 'usage: sh tests/smoke.sh /absolute/path/to/lito' >&2; exit 1; }
compiler=$1
package_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
run_root=$(mktemp -d /tmp/lito-qt-smoke.XXXXXX)
printf 'Qt smoke output: %s\n' "$run_root"
mkdir "$run_root/package"
cp -R "$package_root/lito.toml" "$package_root/lib.lua" "$package_root/qt" \
  "$package_root/tests" "$run_root/package/"
cd "$run_root/package/tests/smoke"

build() {
  if ! "$compiler" build --offline --profile release --build-dir "$run_root/build" \
      -j 4 --verbose > "$run_root/$1.log" 2>&1; then
    cat "$run_root/$1.log"
    exit 1
  fi
}

build first
grep -F '@lito.qt <- lito-qt (path+' "$run_root/first.log"
if grep -F 'builtin+' lito.lock; then
  echo 'Unexpected builtin dependency' >&2
  exit 1
fi
"$run_root/build/bin/fixture-qt-protobuf/fixture-qt-protobuf"
generated="$run_root/build/generated/fixture-qt-protobuf"
qml="$generated/lito-qml/Fixture/Ui"
grep -F 'module Fixture.Ui' "$qml/qmldir"
grep -F 'Main 1.0 qml/Main.qml' "$qml/qmldir"
if grep -F 'prefer ' "$qml/qmldir"; then exit 1; fi
grep -F 'prefer :/qt/qml/Fixture/Ui/' "$generated/lito-qml/Fixture/Ui.build/qmldir"
test -s "$qml/module.qmltypes"
cmp qml/Main.qml "$qml/qml/Main.qml"
cmp qml/icon.svg "$qml/qml/icon.svg"
test -s "$generated/protobuf/control/message.qpb.h"
grep -F -- '-Muri=fixture.control' \
  "$generated/protobuf/control/qml.build/moc_fixture_controlPlugin.cpp"
test -s "$generated/lito-translations/fixture_ui/fixture_zh_CN.qm"

build warm
# Generated include directory contents can invalidate the first set of receipts.
build settled
if grep -F '[build-tool-run] ' "$run_root/settled.log"; then
  echo 'Unexpected regeneration after cache stabilization' >&2
  exit 1
fi

printf '\n// Changed QML input.\n' >> qml/Main.qml
build changed
grep -F '[build-tool-run] ' "$run_root/changed.log"
cmp qml/Main.qml "$qml/qml/Main.qml"

"$compiler" install --offline --profile release --build-dir "$run_root/build" \
  --no-build --prefix "$run_root/install" > "$run_root/install.log" 2>&1
for file in qmldir module.qmltypes qml/Main.qml qml/icon.svg; do
  cmp "$qml/$file" "$run_root/install/share/qml/Fixture/Ui/$file"
done
test ! -e "$run_root/install/share/qml/Fixture/Ui/metatypes.json"
test ! -e "$run_root/install/share/qml/Fixture/Ui/imports.json"

mv "$run_root/package/qt/moc.lua" "$run_root/package/qt/moc.saved"
if "$compiler" build --offline --profile release --build-dir "$run_root/build" \
    > "$run_root/missing.log" 2>&1; then
  echo 'Missing external module unexpectedly succeeded' >&2
  exit 1
fi
grep -F 'qt/moc.lua' "$run_root/missing.log"
mv "$run_root/package/qt/moc.saved" "$run_root/package/qt/moc.lua"
build restored
printf 'External Qt smoke checks passed\n'
