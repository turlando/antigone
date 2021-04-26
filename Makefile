.PHONY: all
all: /etc/nixos/configuration.nix          \
     /etc/nixos/hardware-configuration.nix \
     /etc/secrets/dropbear_host_rsa_key    \
     /etc/nixos/ssh-keys/boot.pub

/etc/nixos/%.nix: %.nix
	install -o root -g root -m 0644 $< $@

/etc/secrets/dropbear_host_rsa_key:
	nix-shell -p dropbear --command "dropbearkey -t rsa -s 4096 -f $@"

/etc/nixos/ssh-keys/boot.pub: ssh-keys/boot.pub
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
