# lighthouse-runner

A ridiculously simple, cross-platform CLI wrapper for Google Lighthouse.

**lighthouse-runner** strips away the configuration noise of the standard Lighthouse CLI. It automatically handles OS-specific file locks, standardizes output directories, sanitizes URL-based filenames, and generates clean, clickable local report URIs. Built for developers who want zero-friction performance auditing directly from the terminal.

## Why this exists
The native Lighthouse CLI is incredibly powerful but requires verbose flags for everyday local use, and frequently crashes on Windows during temporary file cleanup. This wrapper adheres to the "Keep It Simple, Stupid" (KISS) paradigm:
* **Frictionless:** Defaults to standard settings with zero configuration required.
* **Cross-Platform:** Works seamlessly across Windows (CMD & Git Bash), Mac (Zsh), and Linux.
* **Safe Sandboxing:** Automatically isolates Chrome user data to bypass Windows `EPERM` lock crashes.
* **Smart Output:** Auto-generates timestamped HTML reports in a dedicated directory with a clickable terminal link.

## Prerequisites
* Node.js installed on your system.
* The official Lighthouse CLI installed globally:
  ```bash
  npm install -g lighthouse
  ```

## Installation

### Mac / Linux / Git Bash (Windows)
1. Download `lh.sh` and move it to a safe binary location in your path (e.g., `~/bin` or `/usr/local/bin`).
2. Make the script executable:
   ```bash
   chmod +x ~/bin/lh.sh
   ```
3. Add the alias to either one of your profie/terminal start script `~/.zprofile`, `~/.zshrc`, `~/.bash_profile`, `~/.bashrc`:
   ```bash
   alias lh='~/bin/lh.sh'
   ```
   *(Note for Git Bash users: Adjust the alias path to match your specific bin location, e.g., `alias lh='/c/_bin/lh.sh'`)*

### Windows (Native Command Prompt)
1. Download `lh.cmd` and place it in your dedicated scripts folder (e.g., `C:\usr\bin`).
2. Ensure `C:\usr\bin` is added to your Windows System `PATH` environment variable.

## Usage
Simply pass a URL to the command. By default, it runs a **desktop** evaluation and saves the HTML report to `~/LightHouseReports` (or `C:\LightHouseReports` on Windows).

```bash
# Basic usage (defaults to desktop)
lh [https://example.com](https://example.com)

lh [https://example.com](https://example.com) -d

lh [https://example.com](https://example.com) --desktop

# Run a mobile audit
lh [https://example.com](https://example.com) -m
# or
lh [https://example.com](https://example.com) --mobile

# Specify a custom output directory
lh [https://example.com](https://example.com) -o=/path/to/save
```

## Known Issues
**Windows `EPERM` Error on Cleanup:** If you check the console output on Windows natively (CMD) or Git Bash (Windows), you might see an `EPERM` stack trace at the very end of the run regarding `fs.rmSync`. This is a known issue with the underlying `chrome-launcher` node module attempting to delete a temporary folder before Windows background processes release the file lock.

**This error is completely harmless.** The audit has already finished, and your HTML report has been successfully generated before this cleanup step occurs. It does not affect Mac or Linux users.

## License
MIT