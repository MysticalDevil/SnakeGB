# Qt WebAssembly builds may ship Qt6CoreDependencies.cmake that still requests WrapRt.
# There is no librt on wasm, so provide a no-op imported target to satisfy dependency checks.

if(NOT TARGET WrapRt::WrapRt)
    add_library(WrapRt::WrapRt INTERFACE IMPORTED)
endif()

set(WrapRt_FOUND TRUE)
