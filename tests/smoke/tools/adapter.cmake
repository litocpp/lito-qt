add_library(Qt6::Protobuf INTERFACE IMPORTED GLOBAL)
add_library(Qt6::ProtobufQuick INTERFACE IMPORTED GLOBAL)
foreach(_tool IN ITEMS moc qmltyperegistrar rcc qmlimportscanner qmlcachegen lrelease qtprotobufgen)
  add_executable(Qt6::${_tool} IMPORTED GLOBAL)
  set_property(TARGET Qt6::${_tool} PROPERTY IMPORTED_LOCATION
               "${CMAKE_CURRENT_LIST_DIR}/fixture-tool")
endforeach()
add_executable(WrapProtoc::WrapProtoc IMPORTED GLOBAL)
set_property(TARGET WrapProtoc::WrapProtoc PROPERTY IMPORTED_LOCATION
             "${CMAKE_CURRENT_LIST_DIR}/fixture-tool")
file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/version.txt" Qt6_VERSION)
