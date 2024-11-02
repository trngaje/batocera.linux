################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on November 01, 2024
ES_THEME_KNULLI_VERSION = 2ca6b991a570f95ddf817513a457bcedf3d62e54
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
