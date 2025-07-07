# Fedora DNF Support Implementation Tasks

## Overview
This document outlines the tasks required to add Fedora DNF package manager support to the existing Ansible-based development environment automation tool. The implementation will extend the current cross-platform support (macOS Homebrew + Arch Linux Pacman) to include Fedora DNF.

## Architecture Analysis
The current project uses a clean OS detection pattern with `ansible_facts['distribution']` and loads OS-specific variables from `vars/os_{{ ansible_facts['distribution'] }}.yml` files. Each OS has its own package mappings and installation methods.

## Task Breakdown

### Phase 1: Core Infrastructure Setup

#### Task 1.1: Create Fedora Variable Configuration
**Goal**: Create OS-specific variables file for Fedora DNF support
**Priority**: High
**Dependencies**: None
**Estimated Time**: 30 minutes

**Sub-tasks**:
1. Create `vars/os_Fedora.yml` file
2. Define package manager configuration:
   - `package_manager: dnf`
   - `package_manager_module: ansible.builtin.dnf`
   - `package_manager_state: present`
   - `package_manager_update_cache: true`
   - `become_user_needed: false`
3. Map core packages to Fedora package names
4. Map ZSH packages to Fedora equivalents
5. Map Node.js packages to Fedora equivalents
6. Define Neovim build dependencies for Fedora
7. Set installation methods for third-party tools
8. Define system shell path

**Expected Deliverables**:
- `/vars/os_Fedora.yml` file with complete package mappings
- Documentation of any package name differences from other platforms

#### Task 1.2: Update Main Playbook for Fedora Support
**Goal**: Add Fedora-specific package cache update to main playbook
**Priority**: High
**Dependencies**: Task 1.1
**Estimated Time**: 15 minutes

**Sub-tasks**:
1. Add DNF cache update task to `local.yml`
2. Use condition `when: ansible_distribution == "Fedora"`
3. Use `ansible.builtin.dnf` module with `update_cache: true`
4. Add proper privilege escalation with `become: true`

**Expected Deliverables**:
- Updated `local.yml` with Fedora package cache update
- Consistent formatting with existing macOS/Arch sections

### Phase 2: Package Mapping and Testing

#### Task 2.1: Research and Map Package Names
**Goal**: Identify correct Fedora package names for all tools
**Priority**: High
**Dependencies**: None
**Estimated Time**: 45 minutes

**Sub-tasks**:
1. Research Fedora package names for core tools:
   - fzf, ripgrep, bat, fd-find, wget, tmux, jq, git-delta, gh, zoxide, golang
2. Identify Node.js related packages (nodejs, npm)
3. Research Neovim build dependencies (development tools, cmake, ninja, curl)
4. Document any packages requiring different repositories (RPM Fusion, EPEL)
5. Note any packages requiring alternative installation methods

**Expected Deliverables**:
- Comprehensive package mapping document
- Notes on repository requirements
- Alternative installation strategies for unavailable packages

#### Task 2.2: Handle Package Repository Requirements
**Goal**: Add support for enabling additional repositories if needed
**Priority**: Medium
**Dependencies**: Task 2.1
**Estimated Time**: 30 minutes

**Sub-tasks**:
1. Identify if RPM Fusion or EPEL repositories are needed
2. Add repository enablement tasks to appropriate task files
3. Use `ansible.builtin.dnf` module with `enablerepo` parameter
4. Add conditional logic for repository setup

**Expected Deliverables**:
- Repository enablement logic in relevant task files
- Documentation of repository requirements

### Phase 3: Testing Infrastructure

#### Task 3.1: Create Fedora Docker Test Environment
**Goal**: Add Fedora container to testing infrastructure
**Priority**: High
**Dependencies**: Task 1.1, 1.2
**Estimated Time**: 60 minutes

**Sub-tasks**:
1. Create `Dockerfile.fedora` based on official Fedora image
2. Install Ansible and required dependencies
3. Set up test user and environment
4. Add Fedora service to `docker-compose.yml`
5. Update `test-both.sh` to include Fedora testing
6. Create `test-fedora.sh` script for Fedora-specific testing

**Expected Deliverables**:
- `Dockerfile.fedora` with complete test environment
- Updated `docker-compose.yml` with Fedora service
- `test-fedora.sh` script with validation capabilities
- Updated `test-both.sh` to test all three platforms

#### Task 3.2: Update Testing Scripts
**Goal**: Extend testing infrastructure for three-platform support
**Priority**: High
**Dependencies**: Task 3.1
**Estimated Time**: 30 minutes

**Sub-tasks**:
1. Update `test-both.sh` to test Ubuntu, Arch, and Fedora
2. Add Fedora-specific validation checks
3. Update script help text and documentation
4. Add environment validation for Fedora container

**Expected Deliverables**:
- Updated testing scripts supporting three platforms
- Comprehensive validation checks for Fedora environment

### Phase 4: Makefile and Documentation Updates

#### Task 4.1: Update Makefile Targets
**Goal**: Add Fedora-specific testing targets to Makefile
**Priority**: Medium
**Dependencies**: Task 3.1, 3.2
**Estimated Time**: 15 minutes

**Sub-tasks**:
1. Add `test-fedora` target to Makefile
2. Add `test-all` target for comprehensive testing
3. Update existing targets to maintain consistency
4. Add help text for new targets

**Expected Deliverables**:
- Updated Makefile with Fedora testing targets
- Consistent target naming and documentation

#### Task 4.2: Update Documentation
**Goal**: Update project documentation for Fedora support
**Priority**: Medium
**Dependencies**: All previous tasks
**Estimated Time**: 30 minutes

**Sub-tasks**:
1. Update `CLAUDE.md` with Fedora support information
2. Add Fedora prerequisites section
3. Update testing infrastructure documentation
4. Add Fedora-specific notes and considerations
5. Update architecture documentation

**Expected Deliverables**:
- Updated `CLAUDE.md` with comprehensive Fedora documentation
- Clear instructions for Fedora setup and testing

### Phase 5: Package-Specific Customizations

#### Task 5.1: Handle Fedora-Specific Package Differences
**Goal**: Address any packages requiring special handling on Fedora
**Priority**: Medium
**Dependencies**: Task 2.1, 2.2
**Estimated Time**: 45 minutes

**Sub-tasks**:
1. Handle packages with different names (e.g., `fd-find` vs `fd`)
2. Address packages requiring alternative installation methods
3. Handle packages requiring different configuration
4. Update task files with Fedora-specific logic where needed

**Expected Deliverables**:
- Updated task files with Fedora-specific handling
- Documentation of special cases and workarounds

#### Task 5.2: Third-Party Tool Installation
**Goal**: Ensure third-party tools work correctly on Fedora
**Priority**: Medium
**Dependencies**: Task 1.1, 5.1
**Estimated Time**: 30 minutes

**Sub-tasks**:
1. Test starship installation on Fedora
2. Test bun installation on Fedora
3. Test fnm installation on Fedora
4. Update installation commands if needed for Fedora dependencies

**Expected Deliverables**:
- Verified third-party tool installation methods
- Updated installation commands for Fedora compatibility

### Phase 6: Integration and Validation

#### Task 6.1: End-to-End Testing
**Goal**: Perform comprehensive testing of Fedora implementation
**Priority**: High
**Dependencies**: All previous tasks
**Estimated Time**: 60 minutes

**Sub-tasks**:
1. Run full playbook in Fedora test environment
2. Validate all core packages are installed correctly
3. Test ZSH configuration and setup
4. Test Node.js ecosystem setup
5. Test dotfiles deployment
6. Test Neovim installation and configuration
7. Validate all CLI tools are functional

**Expected Deliverables**:
- Complete test results for Fedora environment
- Documentation of any issues and resolutions
- Validation that all functionality works on Fedora

#### Task 6.2: Cross-Platform Validation
**Goal**: Ensure Fedora support doesn't break existing functionality
**Priority**: High
**Dependencies**: Task 6.1
**Estimated Time**: 45 minutes

**Sub-tasks**:
1. Run tests on all three platforms (macOS sim, Arch, Fedora)
2. Validate that existing macOS and Arch functionality still works
3. Test OS detection logic works correctly
4. Validate package manager selection logic
5. Test cross-platform consistency

**Expected Deliverables**:
- Comprehensive cross-platform test results
- Confirmation that existing functionality remains intact
- Documentation of any platform-specific differences

## Implementation Notes

### Critical Considerations
1. **Package Name Mapping**: Fedora may use different package names than other distributions
2. **Repository Requirements**: Some packages may require RPM Fusion or EPEL repositories
3. **DNF vs YUM**: Modern Fedora uses DNF, but some older documentation may reference YUM
4. **Privilege Escalation**: DNF operations require sudo/root privileges
5. **Package Groups**: Some functionality may be provided by package groups rather than individual packages

### Risk Mitigation
1. **Testing**: Comprehensive Docker-based testing before production use
2. **Fallback**: Maintain compatibility with existing platforms
3. **Documentation**: Clear documentation of Fedora-specific requirements
4. **Validation**: Automated validation of package installation and functionality

### Success Criteria
1. All core packages install successfully on Fedora
2. All functionality works consistently across macOS, Arch Linux, and Fedora
3. Testing infrastructure supports all three platforms
4. Documentation accurately reflects Fedora support
5. No regression in existing platform support

## Estimated Total Time
- **Phase 1**: 45 minutes
- **Phase 2**: 75 minutes  
- **Phase 3**: 90 minutes
- **Phase 4**: 45 minutes
- **Phase 5**: 75 minutes
- **Phase 6**: 105 minutes

**Total Estimated Time**: 7.25 hours

## Dependencies
- Access to Fedora system or container for testing
- Ansible 2.9+ with DNF module support
- Docker for containerized testing
- Understanding of Fedora package management and repositories