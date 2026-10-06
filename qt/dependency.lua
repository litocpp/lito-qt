local lito = require("@lito")

local dependency = {}

function dependency.require_qt(qt, context)
  local information = lito.external_dependency_info(qt)
  if information.provider ~= "cmake" or
      not lito.version_matches(information.version, ">=6.8.0, <7.0.0") then
    error(context .. " requires a Qt 6.8 or newer Qt 6 CMake dependency (got " ..
        (information.provider or "unknown") .. " " .. (information.version or "unknown") .. ")")
  end
  return information
end

return dependency
