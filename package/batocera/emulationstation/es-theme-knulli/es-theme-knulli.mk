################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on December 07, 2024
ES_THEME_KNULLI_VERSION = bd5f654951050f8905afda8c91cbb63fd79a30e3
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
