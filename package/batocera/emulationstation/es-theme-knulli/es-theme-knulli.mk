################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on December 20, 2024
ES_THEME_KNULLI_VERSION = 475530aa189a07937a7a312ca3fb713cc2353f65
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
