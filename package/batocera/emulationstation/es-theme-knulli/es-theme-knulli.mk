################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on October 20, 2024
ES_THEME_CARBON_VERSION = e7d6ca05c9b3b88a162c2f16bd0ba799a43e740a
ES_THEME_CARBON_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
