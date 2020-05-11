.PHONY: all
all: /etc/nixos/configuration.nix          \
     /etc/nixos/hardware-configuration.nix

/etc/nixos/%.nix: %.nix
	install -o root -g root -m 0644 $< $@
