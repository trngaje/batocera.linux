################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on November 30, 2024
ES_THEME_KNULLI_VERSION = 8ed80a9bb1e57df2c4c11a8380ecd0f407189bea
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
