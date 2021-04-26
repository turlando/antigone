.PHONY: all
all: /etc/nixos/configuration.nix             \
     /etc/nixos/hardware-configuration.nix    \
     /etc/secrets/initrd_ssh_host_rsa_key     \
     /etc/secrets/initrd_ssh_host_ed25519_key \
     /etc/nixos/ssh-keys/boot.pub             \
     /etc/nixos/ssh-keys/tancredi.pub

/etc/nixos/%.nix: %.nix
	install -o root -g root -m 0644 $< $@

/etc/secrets/initrd_ssh_host_rsa_key:
	ssh-keygen -t rsa -b 4096 -N "" -f $@

/etc/secrets/initrd_ssh_host_ed25519_key:
	ssh-keygen -t ed25519 -N "" -f $@

/etc/nixos/ssh-keys/%.pub: ssh-keys/%.pub
	install -D -o root -g root -m 0644 $< $@

.PHONY: switch
switch:
	nixos-rebuild switch

.PHONY: update
update:
	nix-channel --update

.PHONY: clean
clean:
	nix-collect-garbage -d
