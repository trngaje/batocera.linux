################################################################################
#
# advancemame
#
################################################################################

ADVANCEMAME_BIN_VERSION = f1cbe29af2f42dbc478e44563a58393d1ada85f5
ADVANCEMAME_BIN_SOURCE =
ADVANCEMAME_BIN_LICENSE = MAME

define ADVANCEMAME_BIN_BUILD_CMDS
endef

define ADVANCEMAME_BIN_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/advance
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/advancemame-bin/advance/*.tar.gz $(TARGET_DIR)/usr/share/advance

	mkdir -p $(TARGET_DIR)/usr/share/runcommand
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/advancemame-bin/runcommand/*.tar.gz $(TARGET_DIR)/usr/share/runcommand

	mkdir -p $(TARGET_DIR)/usr/bin
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/advancemame-bin/bin/* $(TARGET_DIR)/usr/bin/

	mkdir -p $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/advancemame-bin/advmenu.sh $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports/
endef

$(eval $(generic-package))
