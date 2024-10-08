#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=intel-microcode
PKG_VERSION:=20240531
PKG_RELEASE:=1

PKG_SOURCE:=intel-microcode_3.$(PKG_VERSION).1.tar.xz
PKG_SOURCE_URL:=@DEBIAN/pool/non-free-firmware/i/intel-microcode/
PKG_HASH:=808cbb57a790dab7060b59b31e70e54ac47d3798d75e9784ed57a65b9f951fc4
PKG_BUILD_DIR:=$(BUILD_DIR)/intel-microcode-3.$(PKG_VERSION).1
PKG_CPE_ID:=cpe:/a:intel:microcode

PKG_BUILD_DEPENDS:=iucode-tool/host

ifdef CONFIG_x86_64
	MICROCODE:="intel-microcode-64"
else
	MICROCODE:="intel-microcode"
endif

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Package/intel-microcode
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=@(x86_64||x86)
  TITLE:=Intel x86 CPU microcode
endef

define Build/Compile
	IUCODE_TOOL=$(STAGING_DIR)/../host/bin/iucode_tool $(MAKE) -C $(PKG_BUILD_DIR)
	mkdir $(PKG_BUILD_DIR)/intel-ucode-ipkg
	$(STAGING_DIR)/../host/bin/iucode_tool -q \
		--write-firmware=$(PKG_BUILD_DIR)/intel-ucode-ipkg $(PKG_BUILD_DIR)/$(MICROCODE).bin
endef

define Package/intel-microcode/install
	$(INSTALL_DIR) $(1)/lib/firmware/intel-ucode
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/intel-ucode-ipkg/* $(1)/lib/firmware/intel-ucode
endef

$(eval $(call BuildPackage,intel-microcode))
