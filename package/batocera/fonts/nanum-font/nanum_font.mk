################################################################################
#
# nanum-font
#
################################################################################

NANUM_FONT_VERSION = 33a5dec3cd6467979fed8ebfa64430d7cebdff9d
NANUM_FONT_SITE = $(call github,ujuc,nanum-font,$(NANUM_FONT_VERSION))

NANUM_FONT_TARGET_DIR=$(TARGET_DIR)/usr/share/fonts/truetype/nanum

define NANUM_FONT_INSTALL_TARGET_CMDS
	@mkdir -p $(NANUM_FONT_TARGET_DIR)
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/fonts/nanum-font/NanumMyeongjo.ttf $(NANUM_FONT_TARGET_DIR)
endef

$(eval $(generic-package))
