TARGET := iphone:clang:16.5:15.0
# TARGET = simulator:clang::12.0

FINAL_PACKAGE=1
THEOS_PACKAGE_SCHEME=rootless
PACKAGE_VERSION = 2.0

export ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LightningTime

LightningTime_FILES = Tweak.xm
LightningTime_CFLAGS = -fobjc-arc
LightningTime_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lightningprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
