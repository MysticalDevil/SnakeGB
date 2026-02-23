# Qt WebAssembly packages can carry GLESv2 dependency markers.
# Provide a no-op imported target to avoid host GL probing.

if(NOT TARGET GLESv2::GLESv2)
    add_library(GLESv2::GLESv2 INTERFACE IMPORTED)
endif()

set(GLESv2_FOUND TRUE)
