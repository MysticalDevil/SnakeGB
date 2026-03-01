.PHONY: help debug release dev android wasm test tidy fmt clean

BUILD_ROOT ?= build
DEBUG_DIR := $(BUILD_ROOT)/debug
RELEASE_DIR := $(BUILD_ROOT)/release
DEV_DIR := $(BUILD_ROOT)/dev
ANDROID_DIR := $(BUILD_ROOT)/android
WASM_DIR := $(BUILD_ROOT)/wasm

help:
	@echo "Targets:"
	@echo "  debug     Configure + build Debug in $(DEBUG_DIR)"
	@echo "  release   Configure + build Release in $(RELEASE_DIR)"
	@echo "  dev       Configure + build RelWithDebInfo in $(DEV_DIR)"
	@echo "  test      Run ctest from $(DEBUG_DIR)"
	@echo "  tidy      Run cached clang-tidy on changed files (uses $(DEBUG_DIR))"
	@echo "  fmt       Run clang-format on changed C/C++ files"
	@echo "  android   Run scripts/deploy/android.sh with BUILD_DIR=$(ANDROID_DIR)"
	@echo "  wasm      Run scripts/deploy/wasm.sh with BUILD_DIR=$(WASM_DIR)"
	@echo "  clean     Remove $(BUILD_ROOT)"

debug:
	cmake -S . -B $(DEBUG_DIR) -G Ninja -DCMAKE_BUILD_TYPE=Debug
	cmake --build $(DEBUG_DIR) --parallel

release:
	cmake -S . -B $(RELEASE_DIR) -G Ninja -DCMAKE_BUILD_TYPE=Release
	cmake --build $(RELEASE_DIR) --parallel

dev:
	cmake -S . -B $(DEV_DIR) -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
	cmake --build $(DEV_DIR) --parallel

test:
	cd $(DEBUG_DIR) && ctest --output-on-failure

tidy:
	./scripts/dev/clang_tidy.sh $(DEBUG_DIR)

fmt:
	@files="$$(git diff --name-only -- '*.cpp' '*.cc' '*.cxx' '*.h' '*.hpp')"; \
	if [ -z "$$files" ]; then \
		echo "[format] no changed C/C++ files"; \
	else \
		echo "$$files" | xargs clang-format -i; \
	fi

android:
	BUILD_DIR=$(ANDROID_DIR) ./scripts/deploy/android.sh

wasm:
	BUILD_DIR=$(WASM_DIR) ./scripts/deploy/wasm.sh

clean:
	rm -rf $(BUILD_ROOT)
