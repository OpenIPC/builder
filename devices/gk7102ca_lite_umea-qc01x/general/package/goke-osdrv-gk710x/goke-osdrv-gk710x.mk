################################################################################
#
# goke-osdrv-gk710x
#
################################################################################

GOKE_OSDRV_GK710X_VERSION =
GOKE_OSDRV_GK710X_SITE =
GOKE_OSDRV_GK710X_LICENSE = MIT
GOKE_OSDRV_GK710X_LICENSE_FILES = LICENSE

ifeq ($(OPENIPC_SOC_MODEL),gk7102)
	GOKE_OSDRV_GK710X_FIRMWARE = gk_fw_710x.bin
else ifeq ($(OPENIPC_SOC_MODEL),gk7102s)
	GOKE_OSDRV_GK710X_FIRMWARE = gk_fw_710xs.bin
else ifeq ($(OPENIPC_SOC_MODEL),gk7102c)
	GOKE_OSDRV_GK710X_FIRMWARE = gk_fw_7102c.bin
else ifeq ($(OPENIPC_SOC_MODEL),gk7102ca)
	GOKE_OSDRV_GK710X_FIRMWARE = gk_fw_7102c_a.bin
endif

define GOKE_OSDRV_GK710X_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -d $(TARGET_DIR)/etc/sensors
	# $(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/*.bin
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/color_matrix.bin
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/color_reg.bin
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/lens_shading.bin
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/mis2003.bin
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/mis2003_hw.bin
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/config/sensor_detect.bin

	$(INSTALL) -m 755 -d $(TARGET_DIR)/lib/firmware
	cp $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/fw/$(GOKE_OSDRV_GK710X_FIRMWARE) $(TARGET_DIR)/lib/firmware/gk_fw.bin

	$(INSTALL) -m 755 -d $(TARGET_DIR)/lib/modules/3.4.43-Goke/goke
	$(INSTALL) -m 644 -t $(TARGET_DIR)/lib/modules/3.4.43-Goke/goke $(GOKE_OSDRV_GK710X_PKGDIR)/files/kmod/*.ko
	# $(INSTALL) -m 644 -t $(TARGET_DIR)/lib/modules/3.4.43-Goke/goke $(GOKE_OSDRV_GK710X_PKGDIR)/files/sensor/*.ko

	$(INSTALL) -m 755 -d $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/bin $(GOKE_OSDRV_GK710X_PKGDIR)/files/script/load*

	$(INSTALL) -m 755 -d $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 644 -t $(TARGET_DIR)/usr/lib/ $(GOKE_OSDRV_GK710X_PKGDIR)/files/lib/*.so
endef

$(eval $(generic-package))
