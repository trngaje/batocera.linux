################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on November 29, 2024
ES_THEME_KNULLI_VERSION = c921a4c2022f78e9234928e00445b4eecf6669a2
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
