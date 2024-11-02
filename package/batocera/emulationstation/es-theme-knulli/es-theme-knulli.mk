################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on November 02, 2024
ES_THEME_KNULLI_VERSION = 63c3e7ece059a0c88430c21c4c5a4885fc68fe10
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
