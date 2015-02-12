NAME=uefi-boottools
VERSION=0.1
 
INSTALL_SCRIPTS=`find scripts -type f 2>/dev/null`
INSTALL_KERNELHOOK=kernel-hook/zz-update-uefi
INSTALL_ETCDEF=etc-default/uefi-boot

PKG_DIR=uefi-boottools
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
   
PREFIX?=/usr

info:
	@echo "missing argument, no default target"
    
pkg:
	mkdir -p $(PKG_DIR)
		 
$(PKG): pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD
		 
build: $(PKG)
	 
clean:
	rm -f $(PKG)

distclean:
	rm -rf $(PKG_DIR)
		 
all: $(PKG)
	 
tag:
	git tag v$(VERSION)
	git push --tags
			 
release: $(PKG) tag
	 
install:
	# install tools
	for f in $(INSTALL_SCRIPTS); do \
	       	cp $$f $(PREFIX)/sbin/`basename $$f` ; \
		chown root.root $(PREFIX)/sbin/`basename $$f` ; \
		chmod 755 $(PREFIX)/sbin/`basename $$f` ; done

	# install kernel post install/update hook
	find /etc/kernel -name 'post*.d' -type d | xargs ls -d -p | xargs -n 1 cp $(INSTALL_KERNELHOOK)

	# install /etc/default/ config file
	cp -b $(INSTALL_ETCDEF) /etc/default/
					 
uninstall:
	# uninstall tools
	for file in $(INSTALL_SCRIPTS); do rm -f $(PREFIX)/sbin/`basename $$file` ; done
	# uninstall kernel post install/update hook
	find /etc/kernel -path \*/post*.d/`basename $(INSTALL_KERNELHOOK)` | xargs rm -f
	# uninstall /etc/default/ config file
	rm -f /etc/default/`basename $(INSTALL_ETCDEF)`
			 
.PHONY: info build clean distclean tag release install uninstall all
