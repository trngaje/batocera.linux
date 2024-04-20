################################################################################
#
# libretro-snes9x2005
#
################################################################################
# Version: Commits on Jul 25, 2022
LIBRETRO_SNES9X2005_VERSION = fd45b0e055bce6cff3acde77414558784e93e7d0
LIBRETRO_SNES9X2005_SITE = $(call github,libretro,snes9x2005,$(LIBRETRO_SNES9X2005_VERSION))
LIBRETRO_SNES9X2005_LICENSE = Non-commercial

LIBRETRO_SNES9X2005_PLATFORM = $(LIBRETRO_PLATFORM)

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RG35XXH),y)
LIBRETRO_SNES9X2005_PLATFORM = armv_neon
endif

define LIBRETRO_SNES9X2005_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
    -C $(@D)/ -f Makefile platform="$(LIBRETRO_SNES9X2005_PLATFORM)" \
        GIT_VERSION="-$(shell echo $(LIBRETRO_SNES9X2005_VERSION) | cut -c 1-7)"
endef

define LIBRETRO_SNES9X2005_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/snes9x2005_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/snes9x2005_libretro.so
endef

$(eval $(generic-package))
