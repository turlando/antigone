.PHONY: all
all: /etc/nixos/configuration.nix          \
     /etc/nixos/hardware-configuration.nix \
     /etc/secrets/dropbear_host_rsa_key

/etc/nixos/%.nix: %.nix
	install -o root -g root -m 0644 $< $@

/etc/secrets/dropbear_host_rsa_key:
	nix-shell -p dropbear --command "dropbearkey -t rsa -s 4096 -f $@"

.PHONY: switch
switch:
	nixos-rebuild switch

.PHONY: clean
clean:
	nix-collect-garbage -d
