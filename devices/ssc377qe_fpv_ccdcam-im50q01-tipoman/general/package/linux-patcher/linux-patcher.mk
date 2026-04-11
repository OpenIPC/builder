################################################################################
#
# linux-patcher
#
################################################################################

LINUX_PATCHER_DEPENDENCIES = linux
export UIMAGE_NAME = Linux-$(LINUX_VERSION_PROBED)-$(OPENIPC_SOC_MODEL)

# Exclude buildroot yylloc patches
LINUX_POST_PATCH_HOOKS = LINUX_APPLY_LOCAL_PATCHES

ifeq ($(BR2_PACKAGE_LINUX_PATCHER_ATHEROS),y)
define LINUX_PATCHER_CONFIG_ATHEROS
	$(call KCONFIG_ENABLE_OPT,CONFIG_FW_LOADER)
	$(call KCONFIG_ENABLE_OPT,CONFIG_WLAN)
	$(call KCONFIG_SET_OPT,CONFIG_MAC80211,m)
	$(call KCONFIG_SET_OPT,CONFIG_ATH9K,m)
	$(call KCONFIG_SET_OPT,CONFIG_ATH9K_HTC,m)
endef
endif

ifneq ($(BR2_PACKAGE_LINUX_PATCHER_SIGMASTAR_DTB),"")
define LINUX_PATCHER_CONFIG_SIGMASTAR_DTB
	$(call KCONFIG_SET_OPT,CONFIG_SS_DTB_NAME,$(BR2_PACKAGE_LINUX_PATCHER_SIGMASTAR_DTB))
endef
endif

define LINUX_PATCHER_LINUX_CONFIG_FIXUPS
	$(LINUX_PATCHER_CONFIG_ATHEROS)
	$(LINUX_PATCHER_CONFIG_SIGMASTAR_DTB)
endef

#Disable regdb signing so that it can be overwritten on the cam
define DISABLE_SIGNED_REGDB_IN_KCONFIG
	@echo "[force-nosign] Mangling net/wireless/Kconfig"
	# $(SED) already has -i -e; don't add extra -i/-e
	$(SED) '/^config CFG80211_REQUIRE_SIGNED_REGDB$$/,/^config /{ \
		s/^[[:space:]]*depends on .*/\tdepends on n/; \
		s/^[[:space:]]*default[[:space:]]*y/\tdefault n/; \
	}' $(LINUX_DIR)/net/wireless/Kconfig
	@echo "[force-nosign] Resulting Kconfig stanza:"
	@sed -n '/^config CFG80211_REQUIRE_SIGNED_REGDB$$/,/^config /p' \
		$(LINUX_DIR)/net/wireless/Kconfig
endef
LINUX_POST_PATCH_HOOKS += DISABLE_SIGNED_REGDB_IN_KCONFIG

# For some reasong cant enable this the simple way, always get removed
define FORCE_MAC80211_LEDS_IN_KCONFIG
	@echo "[force-mac80211-leds] Mangling net/mac80211/Kconfig"
	$(SED) '/^config MAC80211_LEDS$$/,/^config /{ \
		s/^[[:space:]]*depends on .*/\tdepends on y/; \
		s/^[[:space:]]*default[[:space:]]*n/\tdefault y/; \
	}' $(LINUX_DIR)/net/mac80211/Kconfig
	@echo "[force-mac80211-leds] Resulting Kconfig stanza:"
	@sed -n '/^config MAC80211_LEDS$$/,/^config /p' \
		$(LINUX_DIR)/net/mac80211/Kconfig
endef
LINUX_POST_PATCH_HOOKS += FORCE_MAC80211_LEDS_IN_KCONFIG



$(eval $(generic-package))
