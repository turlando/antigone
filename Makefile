###############################################################################

NIX_CHANNEL := nix-channel
NIXOS_REBUILD := nixos-rebuild -I nixos-config=configuration.nix
NIX_COLLECT_GARBAGE := nix-collect-garbage
NIX_REPL := nix repl -I nixos-config=configuration.nix
NIXOS_GENERATE_CONFIG := nixos-generate-config

###############################################################################

.PHONY: update
update:
	$(NIX_CHANNEL) --update

.PHONY: switch
switch:
	$(NIXOS_REBUILD) switch

.PHONY: test
test:
	$(NIXOS_REBUILD) test

.PHONY: clean
clean:
	$(NIX_COLLECT_GARBAGE) -d

.PHONY: upgrade
upgrade: update switch

.PHONY: generate-hardware-config
generate-hardware-config: hardware-configuration.nix

.PHONY: repl
repl:
	$(NIX_REPL) '<nixpkgs/nixos>'

###############################################################################

hardware-configuration.nix: .FORCE
	$(NIXOS_GENERATE_CONFIG) --no-filesystems --show-hardware-config > $@

###############################################################################

.PHONY: .FORCE
.FORCE:

###############################################################################
