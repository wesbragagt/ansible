test:
	docker compose down && docker compose up --build -d && docker compose exec new_computer bash

all:
	ansible-playbook local.yml --ask-become-pass

zsh:
	ansible-playbook local.yml -t zsh --ask-become-pass

node:
	ansible-playbook local.yml -t node --ask-become-pass

dotfiles:
	ansible-playbook local.yml -t dotfiles --ask-become-pass

neovim:
	ansible-playbook local.yml -t neovim --ask-become-pass

productivity:
	ansible-playbook local.yml -t productivity --ask-become-pass

fonts:
	ansible-playbook local.yml -t fonts --ask-become-pass
