local qt = require("@lito.qt")
local target = lito.target({
  kind = "bin",
  name = "fixture-qt-protobuf",
})
local qt6 = lito.external_dependency(target, "qt6")
local schema = lito.external_source(target, "schema")
qt.protobuf({
  target = target,
  qt = qt6,
  source = schema,
  proto_files = { "message.proto" },
  output = "protobuf/control",
  qml_uri = "fixture.control",
})
qt.qml_module({
  target = target,
  qt = qt6,
  uri = "Fixture.Ui",
  version = "1.0",
  qml_files = { "qml/Main.qml" },
  resources = { "qml/icon.svg" },
  moc_files = {{source = "backend.hpp", mode = "separate", output = "moc_backend.cpp"}},
  prefer_resources = false,
  plugin = "none",
})
local valid, message = pcall(qt.qml_module, {
  target = target, qt = qt6, uri = "Invalid.Ui", qml_files = { "qml/Main.qml" },
  prefer_resources = "false",
})
assert(not valid and message:find("prefer_resources must be boolean", 1, true))
qt.translations({
  target = target,
  qt = qt6,
  name = "fixture_ui",
  ts_files = { "i18n/fixture_zh_CN.ts" },
})
