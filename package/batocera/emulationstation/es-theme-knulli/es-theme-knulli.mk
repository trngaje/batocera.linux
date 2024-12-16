################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on December 09, 2024
ES_THEME_KNULLI_VERSION = 8cfabf681dfdfae117e02257310ce76a8198ac14
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
