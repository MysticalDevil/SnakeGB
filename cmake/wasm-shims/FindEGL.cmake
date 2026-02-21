# Qt WebAssembly static packages should not require host EGL.
# Provide a no-op imported target when Qt dependency metadata requests EGL.

if(NOT TARGET EGL::EGL)
    add_library(EGL::EGL INTERFACE IMPORTED)
endif()

set(EGL_FOUND TRUE)
set(HAVE_EGL TRUE)
