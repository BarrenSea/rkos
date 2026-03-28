PROJECT_NAME := rkos
TARGET := x86_64-unknown-none
BUILD_MODE := release
KERNEL_BIN := target/$(TARGET)/$(BUILD_MODE)/$(PROJECT_NAME)

QEMU := qemu-system-x86_64
QEMU_FLAGS := -machine q35 -kernel $(KERNEL_BIN) -serial stdio

CARGO := cargo
CARGO_FLAGS := --target $(TARGET)
ifeq ($(BUILD_MODE), release)
    CARGO_FLAGS += --release
endif

.PHONY: all build run clean check help

all: build

build:
	@echo "Building $(PROJECT_NAME) in $(BUILD_MODE) mode..."
	$(CARGO) build $(CARGO_FLAGS)
clippy:
	@echo "Clippy $(PROJECT_NAME) in $(BUILD_MODE) mode..."
	$(CARGO) clippy $(CARGO_FLAGS) --bins --lib -- -D warnings
run: build
	@echo "Starting QEMU..."
	@$(QEMU) $(QEMU_FLAGS)
clean:
	@echo "Cleaning project..."
	@$(CARGO) clean
	@rm -f build.log

check:
	@$(CARGO) check $(CARGO_FLAGS)

.DEFAULT_GOAL := check
