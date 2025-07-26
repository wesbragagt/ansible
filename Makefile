# Cross-platform Ansible automation tool for macOS, Arch Linux, and Fedora
# All commands work on all platforms with automatic OS detection

DEFAULT_FLAGS="--ask-become-pass"
VAULT_FLAG="--ask-vault-pass"

test:
	docker compose down && docker compose up --build -d && docker compose exec new_computer bash

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

