################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on November 07, 2024
ES_THEME_KNULLI_VERSION = 35e7feff944e895b6077486c786a92a3032f5b3d
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
