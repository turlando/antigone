###############################################################################

.PHONY: all
all: upgrade


###############################################################################

NIX_CHANNEL := nix-channel
NIXOS_REBUILD := nixos-rebuild -I nixos-config=configuration.nix
NIX_COLLECT_GARBAGE := nix-collect-garbage


###############################################################################

SECRETS := /etc/secrets/initrd_ssh_host_rsa_key     \
           /etc/secrets/initrd_ssh_host_ed25519_key

/etc/secrets/initrd_ssh_host_rsa_key:
	@echo "==> $@ has to be regenerated"
	ssh-keygen -t rsa -b 4096 -N "" -f $@

/etc/secrets/initrd_ssh_host_ed25519_key:
	@echo "==> $@ has to be regenerated"
	ssh-keygen -t ed25519 -N "" -f $@


###############################################################################

.PHONY: update
update:
	$(NIX_CHANNEL) --update

.PHONY: switch
switch: $(SECRETS)
	$(NIXOS_REBUILD) switch

.PHONY: clean
clean:
	$(NIX_COLLECT_GARBAGE) -d

.PHONY: upgrade
upgrade: update switch


###############################################################################
