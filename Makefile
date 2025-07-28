# Cross-platform Ansible automation tool for macOS, Arch Linux, and Fedora
# All commands work on all platforms with automatic OS detection

DEFAULT_FLAGS="--ask-become-pass"
VAULT_FLAG="--ask-vault-pass"

.PHONY: test all nix zsh ssh git-setup dotfiles home-manager-switch home-manager-reload

test:
	./test/test-nix.sh

all:
	ansible-playbook local.yml $(DEFAULT_FLAGS) $(VAULT_FLAG)

nix:
	ansible-playbook local.yml -t nix $(DEFAULT_FLAGS)

zsh:
	ansible-playbook local.yml -t zsh $(DEFAULT_FLAGS)

ssh: 
	ansible-playbook local.yml -t ssh $(DEFAULT_FLAGS) $(VAULT_FLAG)

git-setup: 
	ansible-playbook local.yml -t git-setup

dotfiles:
	ansible-playbook local.yml -t dotfiles $(DEFAULT_FLAGS) $(VAULT_FLAG)

# Home-manager commands for package management
reload:
	home-manager switch --flake .
