# Cross-platform Ansible automation tool for macOS and Arch Linux
# All commands work on both platforms with automatic OS detection

DEFAULT_FLAGS="--ask-become-pass"
VAULT_FLAG="--ask-vault-pass"

test:
	docker compose down && docker compose up --build -d && docker compose exec new_computer bash

all:
	ansible-playbook local.yml $(DEFAULT_FLAGS) $(VAULT_FLAG)

core:
	ansible-playbook local.yml -t core $(DEFAULT_FLAGS)


zsh:
	ansible-playbook local.yml -t zsh $(DEFAULT_FLAGS)

node:
	ansible-playbook local.yml -t node $(DEFAULT_FLAGS)

ssh: 
	ansible-playbook local.yml -t ssh $(DEFAULT_FLAGS) $(VAULT_FLAG)

git-setup: 
	ansible-playbook local.yml -t git-setup

dotfiles:
	ansible-playbook local.yml -t dotfiles $(DEFAULT_FLAGS) $(VAULT_FLAG)

neovim:
	ansible-playbook local.yml -t neovim $(DEFAULT_FLAGS)

productivity:
	ansible-playbook local.yml -t productivity $(DEFAULT_FLAGS)

fonts:
	ansible-playbook local.yml -t fonts $(DEFAULT_FLAGS)

