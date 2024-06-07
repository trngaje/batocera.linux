################################################################################
#
# drastic_steward
#
################################################################################

#https://github.com/steward-fu/nds 
DRASTIC_STEWARD_VERSION = 4f3b14faa3325474d9fedd82733985e8ad1ef64c
DRASTIC_STEWARD_SITE = $(call github,steward-fu/,nds,$(DRASTIC_STEWARD_VERSION))

DRASTIC_STEWARD_CONF_ENV += $(TARGET_CONFIGURE_OPTS) \
                CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
                CC_FOR_BUILD="$(TARGET_CC)" GCC_FOR_BUILD="$(TARGET_CC)" \
                CXX_FOR_BUILD="$(TARGET_CXX)" \
                CROSS_COMPILE="$(STAGING_DIR)/usr/bin/" \
                CROSS="$(TARGET_CROSS)" \
                PREFIX="$(STAGING_DIR)" \
                PKG_CONFIG="$(STAGING_DIR)/usr/bin/pkg-config" \
                PATH="$(HOST_DIR)/bin:$(HOST_DIR)/sbin:$(PATH):$(STAGING_DIR)/usr/bin" \
                LD_FOR_BUILD="$(TARGET_CROSS)ld" \
		COMPILER=${CXX}
				
define DRASTIC_STEWARD_BUILD_CMDS
	rm $(@D)/drastic/libs/*
	rm $(@D)/drastic/*.pdf
	rm $(@D)/drastic/*.raw
	rm $(@D)/drastic/png2raw
	rm $(@D)/drastic/icon.png
	#rm $(@D)/drastic/show_hotkeys
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/drastic_steward/BinggraeMelona.ttf $(@D)/drastic/resources/font/font.ttf
	
	sed -i "s#-I/%SDL2%#-I$(STAGING_DIR)/usr/include/SDL2#" $(@D)/sdl2/configure.ac

	cd $(@D) && $(DRASTIC_STEWARD_CONF_ENV) $(MAKE) -f Makefile.mk cfg MOD=rg35xxh HOST=arm-buildroot-linux-gnueabihf
	cd $(@D) && $(DRASTIC_STEWARD_CONF_ENV) $(MAKE) -f Makefile.mk MOD=rg35xxh HOST=arm-buildroot-linux-gnueabihf
endef

define DRASTIC_STEWARD_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/drastic_steward
	cp -rv $(@D)/drastic/* $(TARGET_DIR)/usr/share/drastic_steward/
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/drastic_steward/launch.sh $(TARGET_DIR)/usr/share/drastic_steward/
	chmod a+x $(TARGET_DIR)/usr/share/drastic_steward/launch.sh

	#ln -s -f /userdata/saves/nds/drastic/backup $(TARGET_DIR)/usr/share/drastic_steward/backup
	#ln -s -f /userdata/saves/nds/drastic/savestates  $(TARGET_DIR)/usr/share/drastic_steward/savestates
	#mkdir -p $(TARGET_DIR)/usr/share/evmapy

	# evmap config
	#cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/drastic_steward/nds.drastic_steward.keys $(TARGET_DIR)/usr/share/evmapy
endef

$(eval $(generic-package))
