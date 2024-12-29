################################################################################
#
# drastic_layout
#
################################################################################

DRASTIC_LAYOUT_VERSION = 1a87174d451c5141ef99220e7174d4f6b227635c
DRASTIC_LAYOUT_SITE = $(call github,trngaje,drastic_layout,$(DRASTIC_LAYOUT_VERSION))
DRASTIC_LAYOUT_DEPENDENCIES =

define DRASTIC_LAYOUT_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/advanced_drastic/resources/

	cp -r $(@D)/bg $(TARGET_DIR)/usr/share/advanced_drastic/resources/
endef

$(eval $(generic-package))
