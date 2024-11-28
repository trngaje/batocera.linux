################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on November 28, 2024
ES_THEME_KNULLI_VERSION = ff4b40f5b69013a3497fa9c13e664f8a7385537c
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
