TARGET := iphone:clang:latest:15.0
ARCHS = arm64

INSTALL_TARGET_PROCESSES = Wormix

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WormixTweak

WormixTweak_FILES = Tweak.x
WormixTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
