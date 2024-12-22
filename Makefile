TARGET := iphone:clang:16.5:15.0
export ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
FINAL_PACKAGE=1
THEOS_PACKAGE_SCHEME=rootless
PACKAGE_VERSION = 0.3


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LSTimeLightning

LSTimeLightning_FILES = Tweak.xm
LSTimeLightning_CFLAGS = -fobjc-arc
LSTimeLightning_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
