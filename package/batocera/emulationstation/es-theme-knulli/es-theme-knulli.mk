################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on December 07, 2024
ES_THEME_KNULLI_VERSION = 022333fa02324b60985d02c1c210ed2fad67cfa1
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
