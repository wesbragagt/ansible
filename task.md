# Arch Linux Support Implementation Plan

## Overview

This document outlines the plan to adapt the existing macOS-focused Ansible development environment automation tool to support Arch Linux. The implementation will maintain backward compatibility with macOS while adding comprehensive Arch Linux support.

## Project Analysis

### Current State
- **Platform**: macOS-only with Homebrew package manager
- **Tools**: Development environment setup with core tools, ZSH, Node.js, Neovim, fonts, etc.
- **Structure**: Modular task-based approach with separate YAML files for each component

### Target State
- **Platform**: Cross-platform (macOS + Arch Linux)
- **Package Managers**: Homebrew (macOS) + Pacman (Arch Linux) + AUR support
- **Compatibility**: Maintain existing macOS functionality while adding Arch Linux support

## Implementation Plan

### Phase 1: High Priority Changes

#### 1. OS Detection Mechanism
- **Task**: Create OS detection using `ansible_distribution` fact
- **Implementation**: Add conditional logic throughout playbooks
- **Pattern**: `when: ansible_distribution == "Archlinux"`
- **Files**: All task files in `tasks/` directory

#### 2. Package Manager Integration
- **Task**: Replace Homebrew with `community.general.pacman` module for Arch Linux
- **Requirements**: Ensure `community.general` collection is available
- **Syntax**: Replace `homebrew:` with `community.general.pacman:`
- **Files**: `tasks/core.yml`, `tasks/node.yml`, `tasks/zsh.yml`

#### 3. Core Package Updates
- **Task**: Update `tasks/core.yml` to use pacman
- **Changes**:
  - Add `update_cache: true` for cache refresh
  - Use proper package names for Arch Linux
  - Maintain existing package list functionality
- **Packages**: `fzf`, `ripgrep`, `bat`, `fd`, `wget`, `tmux`, `jq`, `git-delta`, `gh`, `zoxide`

#### 4. Node.js Environment Updates
- **Task**: Update `tasks/node.yml` for Arch Linux
- **Changes**:
  - Replace `node` with `nodejs` package name
  - Keep `npm` package name (same on both platforms)
  - Handle `fnm` via AUR (not in official repos)
- **Considerations**: Bun installation may need different approach

#### 5. ZSH Configuration Updates
- **Task**: Update `tasks/zsh.yml` for Arch Linux
- **Changes**:
  - Use pacman for ZSH installation
  - Fix shell path references
  - Update user home directory paths

### Phase 2: Medium Priority Changes

#### 6. Path Reference Corrections
- **Task**: Fix hardcoded macOS paths
- **Changes**:
  - Replace `/Users/` with `/home/` for Linux
  - Update home directory references in zsh.yml (lines 19, 35, 51)
  - Ensure cross-platform compatibility

#### 7. Package Name Mapping
- **Task**: Create variable mappings for package differences
- **Implementation**: Create OS-specific variable files
- **Mappings**:
  - `golang` → `go` (Arch Linux)
  - `node` → `nodejs` (Arch Linux)
  - Most other packages have same names

#### 8. Main Playbook Updates
- **Task**: Update `local.yml` for cross-platform support
- **Changes**:
  - Replace `brew update` with conditional OS-specific updates
  - Add pacman cache update for Arch Linux
  - Remove Homebrew-specific environment variables for Arch

#### 9. AUR Support Implementation
- **Task**: Add Arch User Repository support
- **Requirements**: Install `ansible-aur` module
- **Implementation**:
  - Create dedicated `aur_builder` user
  - Configure sudo permissions for pacman
  - Install AUR packages (e.g., `fnm`)

### Phase 3: Low Priority Changes

#### 10. Documentation Updates
- **Task**: Update `CLAUDE.md` and `Makefile`
- **Changes**:
  - Add Arch Linux installation instructions
  - Update command examples
  - Document OS-specific requirements

#### 11. Collection Dependencies
- **Task**: Add `requirements.yml` for Ansible collections
- **Content**: Ensure `community.general` collection availability
- **Purpose**: Guarantee `pacman` module availability

#### 12. Testing Infrastructure
- **Task**: Create Arch Linux testing environment
- **Implementation**: Update Docker setup or add Arch Linux container
- **Verification**: Test all components work correctly

## Technical Implementation Details

### OS Detection Pattern
```yaml
- name: Install packages (macOS)
  homebrew:
    name: ['fzf', 'ripgrep', 'bat', 'fd', 'wget']
  when: ansible_distribution == "MacOSX"

- name: Install packages (Arch Linux)
  community.general.pacman:
    name: ['fzf', 'ripgrep', 'bat', 'fd', 'wget']
    state: present
    update_cache: true
  when: ansible_distribution == "Archlinux"
```

### Package Name Mapping
```yaml
- name: Install Go (macOS)
  homebrew:
    name: golang
  when: ansible_distribution == "MacOSX"

- name: Install Go (Arch Linux)
  community.general.pacman:
    name: go
    state: present
  when: ansible_distribution == "Archlinux"
```

### AUR Package Installation
```yaml
- name: Create AUR builder user
  user:
    name: aur_builder
    system: yes
  when: ansible_distribution == "Archlinux"

- name: Configure AUR builder sudo permissions
  lineinfile:
    path: /etc/sudoers.d/aur_builder-allow-to-sudo-pacman
    state: present
    line: "aur_builder ALL=(ALL) NOPASSWD: /usr/bin/pacman"
    validate: /usr/sbin/visudo -cf %s
    create: yes
  when: ansible_distribution == "Archlinux"

- name: Install AUR packages
  become: yes
  become_user: aur_builder
  ansible.builtin.shell: |
    yay -S --noconfirm fnm
  when: ansible_distribution == "Archlinux"
```

### Path Handling
```yaml
- name: Set home directory variable
  set_fact:
    user_home: "{{ '/Users/' + ansible_user_id if ansible_distribution == 'MacOSX' else '/home/' + ansible_user_id }}"

- name: Create directory
  file:
    path: "{{ user_home }}/.config"
    state: directory
```

## File-Specific Changes

### `local.yml`
- Add OS detection logic
- Replace `brew update` with conditional updates
- Remove Homebrew environment variables for Arch

### `tasks/core.yml`
- Add pacman tasks parallel to homebrew tasks
- Use conditional execution based on OS
- Maintain existing tag structure

### `tasks/node.yml`
- Add nodejs/npm installation via pacman
- Handle fnm via AUR
- Update Bun installation for Arch

### `tasks/zsh.yml`
- Add ZSH installation via pacman
- Fix home directory path references
- Update shell configuration paths

### `tasks/homebrew.yml`
- Add conditional logic to skip on Arch Linux
- Consider renaming to `tasks/package-managers.yml`

### New Files
- `requirements.yml` - Ansible collection dependencies
- `vars/arch.yml` - Arch Linux specific variables
- `vars/macos.yml` - macOS specific variables

## Success Criteria

1. **Functionality**: All existing macOS functionality preserved
2. **Cross-platform**: Full feature parity on Arch Linux
3. **Maintainability**: Clean, readable conditional logic
4. **Testing**: Successful execution on both platforms
5. **Documentation**: Clear instructions for both platforms

## Risks and Mitigation

### Risks
- Package availability differences between platforms
- AUR package reliability and maintenance
- Path and permission differences between macOS and Linux

### Mitigation
- Comprehensive testing on both platforms
- Fallback mechanisms for failed package installations
- Clear error handling and user feedback
- Documentation of platform-specific requirements

## Dependencies

### Required Collections
- `community.general` (for pacman module)
- `ansible.builtin` (core modules)

### External Dependencies
- `ansible-aur` module for AUR support
- `yay` or similar AUR helper

## Conclusion

This plan provides a comprehensive approach to adding Arch Linux support while maintaining backward compatibility with macOS. The modular, conditional approach ensures clean separation of concerns and maintainable code structure.