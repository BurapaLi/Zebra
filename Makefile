include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/null.mk

all::
	xcodebuild CODE_SIGN_IDENTITY="" AD_HOC_CODE_SIGNING_ALLOWED=YES -scheme Zebra archive -archivePath Zebra.xcarchive PACKAGE_VERSION='@\"$(THEOS_PACKAGE_VERSION)\"' | xcpretty && exit ${PIPESTATUS[0]}

after-stage::
	mv Zebra.xcarchive/Products/Applications $(THEOS_STAGING_DIR)/Applications
	rm -rf Zebra.xcarchive
	$(MAKE) -C Supersling LEAN_AND_MEAN=1
	mkdir -p $(THEOS_STAGING_DIR)/usr/libexec/zebra
	mv $(THEOS_OBJ_DIR)/supersling $(THEOS_STAGING_DIR)/usr/libexec/zebra
	rm -rf $(THEOS_STAGING_DIR)/Applications/Zebra.app/embedded.mobileprovision
	rm -rf $(THEOS_STAGING_DIR)/Applications/Zebra.app/Installed.pack
	ldid -S $(THEOS_STAGING_DIR)/Applications/Zebra.app/Zebra
	ldid -S $(THEOS_STAGING_DIR)/Applications/Zebra.app/Frameworks/SDWebImage.framework/SDWebImage
	ldid -S $(THEOS_STAGING_DIR)/Applications/Zebra.app/Frameworks/LNPopupController.framework/LNPopupController
	ldid -SZebra/Zebra.entitlements $(THEOS_STAGING_DIR)/Applications/Zebra.app/Zebra

ipa::
	make all
	mkdir -p $(THEOS_STAGING_DIR)/Payload
	mv Zebra.xcarchive/Products/Applications/Zebra.app $(THEOS_STAGING_DIR)/Payload/Zebra.app
	rm -rf Zebra.xcarchive
	rm -rf $(THEOS_STAGING_DIR)/Applications/Zebra.app/embedded.mobileprovision
	cd $(THEOS_STAGING_DIR) && zip -r Zebra.zip Payload
	rm -rf $(THEOS_STAGING_DIR)/Payload
	mkdir -p ipas
	mv $(THEOS_STAGING_DIR)/Zebra.zip ipas/Zebra-$(THEOS_PACKAGE_VERSION).ipa

after-install::
	install.exec "killall \"Zebra\" || true"
