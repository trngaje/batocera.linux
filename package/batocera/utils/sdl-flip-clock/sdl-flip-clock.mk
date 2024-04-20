################################################################################
#
# sdl-flip-clock
#
################################################################################

SDL_FLIP_CLOCK_VERSION = e61739700856bc70df0268e5198efd6ab0074300
SDL_FLIP_CLOCK_SITE = $(call github,JaeSeoKim,sdl-flip-clock,$(SDL_FLIP_CLOCK_VERSION))
SDL_FLIP_CLOCK_DEPENDENCIES = sdl2
SDL_FLIP_CLOCK_CONF_ENV += CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
                CC_FOR_BUILD="$(TARGET_CC)" GCC_FOR_BUILD="$(TARGET_CC)" \
                CXX_FOR_BUILD="$(TARGET_CXX)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                PREFIX="$(STAGING_DIR)"
				
define SDL_FLIP_CLOCK_BUILD_CMDS
  $(SDL_FLIP_CLOCK_CONF_ENV) $(MAKE) -C $(@D)
endef

define SDL_FLIP_CLOCK_INSTALL_TARGET_CMDS
	mkdir  -p $(TARGET_DIR)/usr/bin/
	cp -f $(@D)/flipClock $(TARGET_DIR)/usr/bin/
	cp -rf $(@D)/fonts $(TARGET_DIR)/usr/bin/
	
	mkdir -p $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports
	cp -f $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/sdl-flip-clock/sdl-flip-clock.sh $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/sdl-flip-clock/sdl-flip-clock.sh.keys $(TARGET_DIR)/usr/share/batocera/datainit/roms/ports
endef

$(eval $(generic-package))
