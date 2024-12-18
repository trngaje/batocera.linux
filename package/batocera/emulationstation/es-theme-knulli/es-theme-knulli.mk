################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on December 18, 2024
ES_THEME_KNULLI_VERSION = b611122d467be992935066b833a6d6976dcff7d8
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
