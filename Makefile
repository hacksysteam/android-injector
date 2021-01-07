#
# Makefile to build injector, victim and agent
#

FRIDA_VERSION := 12.11.8
FRIDA_EXT_PATH := $(abspath ./ext/frida-core)
OUTPUT_BIN_DIR := $(abspath ./bin)
BUILD_DIR := $(abspath ./build)

default: all

.PHONY: all deploy clean

all: build-injector-x86 build-injector-x86_64 build-injector-arm build-injector-arm64


build-injector-x86: $(FRIDA_EXT_PATH)/android-x86/.stamp
	@echo [+] Building Injector - x86
	@ndk-build -B NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk NDK_APP_DST_DIR=$(OUTPUT_BIN_DIR) NDK_APP_OUT=$(BUILD_DIR) APP_BUILD_SCRIPT=./Android.mk FRIDA_EXT_PATH=$(FRIDA_EXT_PATH) APP_ABI=x86


build-injector-x86_64: $(FRIDA_EXT_PATH)/android-x86_64/.stamp
	@echo [+] Building Injector - x86_64
	@ndk-build -B NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk NDK_APP_DST_DIR=$(OUTPUT_BIN_DIR) NDK_APP_OUT=$(BUILD_DIR) APP_BUILD_SCRIPT=./Android.mk FRIDA_EXT_PATH=$(FRIDA_EXT_PATH) APP_ABI=x86_64


build-injector-arm: $(FRIDA_EXT_PATH)/android-arm/.stamp
	@echo [+] Building Injector - armeabi-v7a
	@ndk-build -B NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk NDK_APP_DST_DIR=$(OUTPUT_BIN_DIR) NDK_APP_OUT=$(BUILD_DIR) APP_BUILD_SCRIPT=./Android.mk FRIDA_EXT_PATH=$(FRIDA_EXT_PATH) APP_ABI=armeabi-v7a


build-injector-arm64: $(FRIDA_EXT_PATH)/android-arm64/.stamp
	@echo [+] Building Injector - arm64-v8a
	@ndk-build -B NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk NDK_APP_DST_DIR=$(OUTPUT_BIN_DIR) NDK_APP_OUT=$(BUILD_DIR) APP_BUILD_SCRIPT=./Android.mk FRIDA_EXT_PATH=$(FRIDA_EXT_PATH) APP_ABI=arm64-v8a


$(FRIDA_EXT_PATH)/android-x86/.stamp:
	$(eval FRIDA_CORE_DEVKIT_URL := https://github.com/frida/frida/releases/download/$(FRIDA_VERSION)/frida-core-devkit-$(FRIDA_VERSION)-android-x86.tar.xz)
	@echo [+] Fetching Frida DevKit for x86: $(FRIDA_CORE_DEVKIT_URL)
	@mkdir -p $(@D)
	@rm -f $(@D)/*
	@curl -Ls $(FRIDA_CORE_DEVKIT_URL) | xz -d | tar -C $(@D) -xf -
	@touch $@


$(FRIDA_EXT_PATH)/android-x86_64/.stamp:
	$(eval FRIDA_CORE_DEVKIT_URL := https://github.com/frida/frida/releases/download/$(FRIDA_VERSION)/frida-core-devkit-$(FRIDA_VERSION)-android-x86_64.tar.xz)
	@echo [+] Fetching Frida DevKit for x86_64: $(FRIDA_CORE_DEVKIT_URL)
	@mkdir -p $(@D)
	@rm -f $(@D)/*
	@curl -Ls $(FRIDA_CORE_DEVKIT_URL) | xz -d | tar -C $(@D) -xf -
	@touch $@


$(FRIDA_EXT_PATH)/android-arm/.stamp:
	$(eval FRIDA_CORE_DEVKIT_URL := https://github.com/frida/frida/releases/download/$(FRIDA_VERSION)/frida-core-devkit-$(FRIDA_VERSION)-android-arm.tar.xz)
	@echo [+] Fetching Frida DevKit for arm: $(FRIDA_CORE_DEVKIT_URL)
	@mkdir -p $(@D)
	@rm -f $(@D)/*
	@curl -Ls $(FRIDA_CORE_DEVKIT_URL) | xz -d | tar -C $(@D) -xf -
	@touch $@


$(FRIDA_EXT_PATH)/android-arm64/.stamp:
	$(eval FRIDA_CORE_DEVKIT_URL := https://github.com/frida/frida/releases/download/$(FRIDA_VERSION)/frida-core-devkit-$(FRIDA_VERSION)-android-arm64.tar.xz)
	@echo [+] Fetching Frida DevKit for arm64: $(FRIDA_CORE_DEVKIT_URL)
	@mkdir -p $(@D)
	@rm -f $(@D)/*
	@curl -Ls $(FRIDA_CORE_DEVKIT_URL) | xz -d | tar -C $(@D) -xf -
	@touch $@


clean:
	@echo Removing build dir: $(abspath ./build)
	@rm -rf $(abspath ./build)
	@echo Removing bin dir: $(abspath ./bin)
	@rm -rf $(abspath ./bin)


deploy:
	@adb shell "rm -rf /data/local/tmp/injection"
	@adb shell "mkdir /data/local/tmp/injection"
	@adb push $(abspath ./bin)/* /data/local/tmp/injection
