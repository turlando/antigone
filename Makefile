###############################################################################

NIXOS_CONFIG    := configuration.nix
HARDWARE_CONFIG := hardware-configuration.nix

NIX_PATH_OPTS := -I nixos-config=$(NIXOS_CONFIG)

NIXOS_GENERATE_CONFIG := nixos-generate-config
NIX_CHANNEL           := nix-channel
NIXOS_REBUILD         := nixos-rebuild
NIX_COLLECT_GARBAGE   := nix-collect-garbage
NIX_REPL              := nix repl

###############################################################################

.PHONY: update
update:
	$(NIX_CHANNEL) --update

.PHONY: switch
switch:
	$(NIXOS_REBUILD) $(NIX_PATH_OPTS) switch

.PHONY: test
test:
	$(NIXOS_REBUILD) $(NIX_PATH_OPTS) test

.PHONY: clean
clean:
	$(NIX_COLLECT_GARBAGE) -d

.PHONY: upgrade
upgrade: update switch

.PHONY: generate-hardware-config
generate-hardware-config: $(HARDWARE_CONFIG)

.PHONY: repl
repl:
	$(NIX_REPL) $(NIX_PATH_OPTS) '<nixpkgs/nixos>'

###############################################################################

$(HARDWARE_CONFIG): .FORCE
	$(NIXOS_GENERATE_CONFIG) --no-filesystems --show-hardware-config > $@

###############################################################################

.PHONY: .FORCE
.FORCE:

###############################################################################
