# Ansible Setup

My automated development. Includes installation of the following tools:

- homebrew
- zsh
- stow
- nodejs
- npm
- yarn
- neovim
- vimplug
- fzf
- tmux
- fd
- bat
- rg(ripgrep)

## Getting Started

1. Authorize utility scripts -> ```sudo chmod -R +x scripts/```

2. Make sure to have homebrew or linux brew installed ```bash scripts/homebrew.sh```

3. Make sure to have ansible installed ```bash scripts/ansible.sh```

4. ansible-playbook local.yml --ask-become-pass
