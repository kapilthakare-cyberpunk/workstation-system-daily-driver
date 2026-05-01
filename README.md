# Workstation System Daily Driver

## About
A comprehensive system management and automation suite for Linux workstations, specifically optimized for Linux Mint (Zena) on hardware with limited resources. It provides a set of tools and configurations to ensure peak performance, organized file systems, and automated maintenance workflows.

## Features
- Boot Optimization: Targeted configurations to achieve sub-15s boot times.
- Memory Management: Optimized kernel and shell settings for 7.5GB RAM environments.
- Directory Standardization: Enforced organizational standards for Home, Projects, and Documents.
- Automated Organization: Background scripts for sorting downloads and cleaning temporary files.
- Maintenance Suite: Integrated health checks and daily synchronization routines.
- Development Scaffolding: Templates for rapid project initialization in Node.js, Python, and Go.
- AI Integration: Pre-configured rules and settings for Claude Code and local LLMs.

## Installation
To deploy the suite on a new workstation, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/kapilthakare-cyberpunk/workstation-system-daily-driver.git
   cd workstation-system-daily-driver
   ```

2. Execute the installation script:
   ```bash
   ./install.sh
   ```

3. Configure the shell:
   Compare your `~/.zshrc` with `configs/shell/zshrc.example` and merge required optimizations.

4. Initialize the crontab:
   ```bash
   crontab < crontab.example
   ```

## Usage
The suite provides several CLI utilities for daily workstation management:

- `system-health`: Generates a report on CPU, memory, disk, and thermal status.
- `daily-sync`: Performs configuration backups and temporary file cleanup.
- `downloads-organize`: Automatically sorts files in the Downloads folder by type.
- `project-new <name> <type>`: Scaffolds a new development project from predefined templates.

## Roadmap
- [x] Initial system health and sync scripts.
- [x] Standardized folder structure implementation.
- [ ] Automated backup rotation and retention policy.
- [ ] Further optimization of systemd startup services.
- [ ] Integration of AI tool telemetry for performance monitoring.

## License
Distributed under the MIT License. See `LICENSE` for more information.
