################################################################################
#
# m8c
#
################################################################################
M8C_VERSION = fa044685c437e97e846b59681abd1933b35a456e
M8C_SITE =  $(call github,laamaa,m8c,$(M8C_VERSION))
M8C_LICENSE = MIT
M8C_INSTALL_STAGING = YES

define M8C_INSTALL_STAGING_CMDS
    $(MAKE) PREFIX="$(STAGING_DIR)/usr" $(TARGET_CONFIGURE_OPTS) -C $(@D) install
endef

define M8C_INSTALL_TARGET_CMDS
    $(MAKE) PREFIX="$(TARGET_DIR)/usr" $(TARGET_CONFIGURE_OPTS) -C $(@D) install
endef

$(eval $(cmake-package))
#$(eval $(generic-package))
