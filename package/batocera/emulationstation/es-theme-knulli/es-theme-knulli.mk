################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on December 01, 2024
ES_THEME_KNULLI_VERSION = 3aa11fb69342b01074f66f56a2912083954b72e5
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
