################################################################################
#
# advanced_drastic
#
################################################################################

ADVANCED_DRASTIC_VERSION = 34b5f38d7124b614ada69cc14f284db57e78084b
ADVANCED_DRASTIC_SITE = $(call github,trngaje,advanced_drastic,$(ADVANCED_DRASTIC_VERSION))
ADVANCED_DRASTIC_DEPENDENCIES = drastic_layout sdl2_drastic

define ADVANCED_DRASTIC_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/advanced_drastic

	cp -r $(@D)/* $(TARGET_DIR)/usr/share/advanced_drastic
endef

$(eval $(generic-package))
