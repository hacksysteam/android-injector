LOCAL_PATH := $(call my-dir)

#
# Frida core dependency
#

include $(CLEAR_VARS)
LOCAL_MODULE := frida-core
LOCAL_EXPORT_C_INCLUDES := $(FRIDA_EXT_PATH)/android-$(TARGET_ARCH)
LOCAL_SRC_FILES := $(FRIDA_EXT_PATH)/android-$(TARGET_ARCH)/libfrida-core.a
include $(PREBUILT_STATIC_LIBRARY)


#
# Build the injector
#

include $(CLEAR_VARS)
LOCAL_MODULE := injector-$(TARGET_ARCH)
LOCAL_SRC_FILES := injector.c
LOCAL_C_INCLUDES += $(FRIDA_EXT_PATH)/android-$(TARGET_ARCH)
LOCAL_STATIC_LIBRARIES := frida-core
include $(BUILD_EXECUTABLE)


#
# Build the victim
#

include $(CLEAR_VARS)
LOCAL_MODULE := victim-$(TARGET_ARCH)
LOCAL_SRC_FILES := victim.c
include $(BUILD_EXECUTABLE)


#
# Build the agent
#

include $(CLEAR_VARS)
LOCAL_MODULE := agent-$(TARGET_ARCH)
LOCAL_SRC_FILES := agent.c
include $(BUILD_SHARED_LIBRARY)
