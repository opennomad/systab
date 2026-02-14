# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`systab` is a single-file Bash script that provides a cron/at/batch-like interface for systemd user timers. It creates, manages, and cleans up systemd `.service` and `.timer` unit files in `~/.config/systemd/user/`. Managed units are tagged with a `# SYSTAB_MANAGED` marker comment and a `# SYSTAB_ID=<hex>` short ID for human-friendly identification.

## Running

```bash
./systab [OPTIONS]
```

No build step. The script requires `bash`, `systemctl`, and optionally `notify-send` (for `-i`) and `mail` (for `-m`).

## Architecture

The script has two modes controlled by CLI flags:

- **Job creation** (`-t <time> [-c <cmd> | -f <script> | stdin]`): Generates a systemd `.service` + `.timer` pair with a 6-char hex short ID, reloads the daemon, and enables/starts the timer. Time specs are parsed via `date -d` or passed through as systemd OnCalendar values. One-time jobs get `Persistent=false` and `RemainAfterElapse=no` (auto-unload after firing).

- **Management** (`-E`, `-L`, `-S`, `-C` — mutually exclusive):
  - `-E`: Opens `$EDITOR` with a tab-separated crontab (`ID  SCHEDULE  COMMAND`). On save, diffs against the original to apply creates (ID=`new`), deletes (removed lines), and updates (changed schedule/command). Legacy jobs without IDs get one auto-assigned.
  - `-L [filter]`: Query `journalctl` logs for managed jobs.
  - `-S`: Show timer status via `systemctl`, including short IDs.
  - `-C`: Interactively clean up elapsed one-time timers (removes unit files from disk).

Key functions: `parse_time` (time spec → OnCalendar), `create_job` (generates unit files), `edit_jobs` (crontab-style edit with diff-and-apply), `get_managed_services`/`get_managed_timers` (find tagged units), `ensure_job_id` (auto-assign IDs to legacy jobs), `clean_jobs` (remove elapsed one-time timers).

## Testing

There are no automated tests. Test manually with systemd user timers:
```bash
./systab -t "in 1 minute" -c "echo test"
./systab -S
./systab -C
```

## Notes

- ShellCheck can be used for linting: `shellcheck systab`.
