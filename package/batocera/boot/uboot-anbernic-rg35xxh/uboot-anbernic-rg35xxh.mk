################################################################################
#
# uboot files for Anbernic RG35XXH
#
################################################################################

UBOOT_ANBERNIC_RG35XXH_VERSION = 1.0
UBOOT_ANBERNIC_RG35XXH_SOURCE =

define UBOOT_ANBERNIC_RG35XXH_BUILD_CMDS
endef

define UBOOT_ANBERNIC_RG35XXH_INSTALL_TARGET_CMDS
	mkdir -p $(BINARIES_DIR)/partitions/
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/boot/uboot-anbernic-rg35xxh/partitions/*  $(BINARIES_DIR)/partitions/
endef

$(eval $(generic-package))
