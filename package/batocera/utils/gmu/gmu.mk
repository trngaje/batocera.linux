################################################################################
#
# gmu
#
################################################################################

GMU_VERSION = 99175d492b54eba514ec6d3f8b88591d74aedcc4
GMU_SITE = $(call github,trngaje,gmu,$(GMU_VERSION))
GMU_DEPENDENCIES = sdl2 opus mpg123 libvorbis flac speex
GMU_CONF_ENV += LDFLAGS="$(LDFLAGS) -lreadline -lncursesw -ltinfow" \
			TARGET_CFLAGS="${TARGET_CFLAGS} -fcommon -I $(STAGING_DIR)/usr/include" \
			SDL2CONFIG="$(STAGING_DIR)/usr/bin/sdl2-config" \
                CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
                CC_FOR_BUILD="$(TARGET_CC)" GCC_FOR_BUILD="$(TARGET_CC)" \
                CXX_FOR_BUILD="$(TARGET_CXX)" \
                CROSS_COMPILE="$(STAGING_DIR)/usr/bin/" \
                PREFIX="$(TARGET_DIR)/usr/"
				
define GMU_BUILD_CMDS
  cd $(@D) && $(GMU_CONF_ENV) ./configure --enable=medialib
  
  $(GMU_CONF_ENV) $(MAKE) -C $(@D) install
endef

define GMU_INSTALL_TARGET_CMDS
  mkdir -p $(TARGET_DIR)/usr/share/gmu/
  cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/gmu/gmu.conf $(TARGET_DIR)/usr/share/gmu/
  cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/gmu/gmuinput.conf $(TARGET_DIR)/usr/share/gmu/
  cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/gmu/rg35xxh.keymap $(TARGET_DIR)/usr/share/gmu/

  mkdir -p $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports
  cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/gmu/start_gmu.sh $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports

endef

$(eval $(generic-package))
