# User Customization

This Nix flake setup is now multi-user compatible. Here's how to customize it for different users:

## Quick Setup

The setup automatically detects the current user (`ansible_user_id`) and uses these defaults:
- **Git name**: Current username
- **Git email**: `{username}@example.com` 
- **Home directory**: Auto-detected based on OS

## Customizing Your Configuration

### Option 1: Command Line Override
```bash
# For names with spaces, use JSON format
ansible-playbook local.yml --extra-vars '{"git_user_name":"Your Full Name","git_user_email":"your.email@domain.com"}'

# For simple names without spaces
ansible-playbook local.yml -e git_user_name="YourName" -e git_user_email="your.email@domain.com"
```

### Option 2: Host-Specific Variables
Create `host_vars/localhost.yml`:
```yaml
---
git_user_name: "Your Real Name"
git_user_email: "your.actual@email.com"
nix_user_name: "{{ ansible_user_id }}"  # Usually not needed to change
```

### Option 3: Edit Global Defaults
Modify `group_vars/all.yml`:
```yaml
---
git_user_name: "Default Name"
git_user_email: "default@company.com"
```

## How It Works

1. **In-Place Customization**: Ansible directly modifies the existing `flake.nix` file
2. **Pattern Replacement**: Uses `ansible.builtin.replace` to substitute hardcoded values with user-specific ones
3. **Dynamic Configurations**: Home configurations are customized for current user and platform
4. **Cross-Platform**: Works on macOS (`/Users/username`) and Linux (`/home/username`)
5. **No Template Files**: Single source of truth - the `flake.nix` file remains readable and maintainable

## Available Variables

- `nix_user_name`: Nix username (defaults to `ansible_user_id`)
- `nix_user_email`: Email for Nix git config (defaults to `git_user_email`)
- `git_user_name`: Git global username
- `git_user_email`: Git global email
- `nix_home_directory`: Auto-detected home path

## What Gets Replaced

The Ansible task automatically replaces these hardcoded values in `flake.nix`:

```nix
# Original values (in the repo)
userName = "wesbragagt";
userEmail = "wesbragagt@gmail.com";
"wesbragagt@linux-x86_64"
username = "wesbragagt";
homeDirectory = "/Users/wesbragagt";

# Becomes (for user 'alice')
userName = "Alice Smith";
userEmail = "alice@company.com";
"alice@linux-x86_64"
username = "alice";
homeDirectory = "/home/alice";
```

This happens automatically during the `make nix` step, no manual editing required.

## For Team Usage

1. **Fork/Clone** this repository
2. **Customize** `group_vars/all.yml` with team defaults
3. **Create** `host_vars/{hostname}.yml` for per-machine config
4. **Run** standard setup: `make all`

The generated `flake.nix` will be customized for each user automatically.
