local qt = require("@lito.qt")
local target = lito.target({ kind = "bin", name = "qt-moc-smoke" })
qt.moc({
  target = target,
  qt = lito.external_dependency(target, "qt6"),
  files = {{ source = "counter.hpp", mode = "separate", output = "moc_counter.cpp" }},
})
