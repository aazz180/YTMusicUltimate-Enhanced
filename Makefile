ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME = rootless
else ifeq ($(ROOTHIDE),1)
THEOS_PACKAGE_SCHEME = roothide
endif

ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTubeMusic
TARGET = iphone:clang:16.5:13.0
PACKAGE_VERSION = 2.3.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate

$(TWEAK_NAME)_FILES = $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-vla-cxx-extension -Wno-vla -DTWEAK_VERSION=$(PACKAGE_VERSION)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AudioToolbox VideoToolbox
$(TWEAK_NAME)_OBJ_FILES = $(shell find Source/Utils/lib -name '*.a')
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z
ifeq ($(SIDELOADING),1)
$(TWEAK_NAME)_FILES += Sideloading.xm
endif

include $(THEOS_MAKE_PATH)/tweak.mk

# Custom target to build and create IPA
.PHONY: ipa
ipa: package-sideload
	@echo "🎯 Creating IPA file directly in IPA directory..."
	@export PATH="$$HOME/Library/Python/3.9/bin:$$HOME/.local/bin:$$PATH" && \
	cyan -i IPA/com.google.ios.youtubemusic-8.32-Decrypted.ipa \
		-o IPA/YTMusicUltimate-v$(PACKAGE_VERSION).ipa \
		-uwsf packages/com.ginsu.ytmusicultimate_$(PACKAGE_VERSION)_iphoneos-arm.deb \
		-n "YouTube Music" \
		-b com.google.ios.youtubemusic
	@echo "🚀 IPA created directly in IPA directory: YTMusicUltimate-v$(PACKAGE_VERSION).ipa"

# Sideloading package target
.PHONY: package-sideload
package-sideload:
	@echo "🔧 Building package with SIDELOADING=1..."
	@export THEOS=~/theos && make package SIDELOADING=1

# Full IPA target
.PHONY: full-ipa
full-ipa: package-sideload
	@echo "🎯 Building full IPA with tweak..."
	@export PATH="$$HOME/Library/Python/3.9/bin:$$HOME/.local/bin:$$PATH" && \
	cyan -i IPA/com.google.ios.youtubemusic-8.32-Decrypted.ipa \
		-o IPA/YTMusicUltimate-v$(PACKAGE_VERSION).ipa \
		-uwsf packages/com.ginsu.ytmusicultimate_$(PACKAGE_VERSION)_iphoneos-arm.deb \
		-n "YouTube Music" \
		-b com.google.ios.youtubemusic
	@echo "🚀 Full IPA created: YTMusicUltimate-v$(PACKAGE_VERSION).ipa"
