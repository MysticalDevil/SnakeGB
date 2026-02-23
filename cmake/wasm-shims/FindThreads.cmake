# Provide a no-op Threads package for WebAssembly cross builds where host pthread probing is not valid.

if(NOT TARGET Threads::Threads)
    add_library(Threads::Threads INTERFACE IMPORTED)
endif()

set(Threads_FOUND TRUE)
set(CMAKE_THREAD_LIBS_INIT "")
