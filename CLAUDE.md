# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`systab` is a single-file Bash script that provides a cron/at/batch-like interface for systemd user timers. It creates, manages, and cleans up systemd `.service` and `.timer` unit files in `~/.config/systemd/user/`. Managed units are tagged with a `# SYSTAB_MANAGED` marker comment. Unit filenames use a 6-char hex ID (e.g., `systab_a1b2c3.timer`) which doubles as the human-facing job identifier.

## Running

```bash
./systab [OPTIONS]
```

No build step. The script requires `bash`, `systemctl`, and optionally `notify-send` (for `-i`) and `mail` (for `-m`).

## Architecture

The script has two modes controlled by CLI flags:

- **Job creation** (`-t <time> [-c <cmd> | -f <script> | stdin]`): Generates a systemd `.service` + `.timer` pair with a 6-char hex short ID, reloads the daemon, and enables/starts the timer. Time specs are parsed via `parse_time` which handles natural language (`every 5 minutes`), `date -d` relative/absolute times, and raw systemd OnCalendar values. One-time jobs get `Persistent=false` and `RemainAfterElapse=no` (auto-unload after firing). All jobs log stdout/stderr to the journal via `SyslogIdentifier`.

- **Management** (`-P`, `-R`, `-E`, `-L`, `-S`, `-C` — mutually exclusive):
  - `-P <id>` / `-R <id>`: Pause (stop+disable) or resume (enable+start) a job's timer.
  - `-E`: Opens `$EDITOR` with a pipe-separated crontab (`ID | SCHEDULE | COMMAND`). On save, diffs against the original to apply creates (ID=`new`), deletes (removed lines), updates (changed schedule/command), and pause/resume (comment/uncomment lines).
  - `-L [filter]`: Query `journalctl` logs for managed jobs (both unit messages and command output).
  - `-S`: Show timer status via `systemctl`, including short IDs and disabled state.
  - `-C`: Interactively clean up elapsed one-time timers (removes unit files from disk).

Key functions: `parse_time` (time spec → OnCalendar), `create_job` (generates unit files), `edit_jobs` (crontab-style edit with diff-and-apply), `get_managed_services`/`get_managed_timers` (find tagged units), `clean_jobs` (remove elapsed one-time timers), `pause_job`/`resume_job` (disable/enable timers).

## Testing

There are no automated tests. Test manually with systemd user timers:
```bash
./systab -t "every 5 minutes" -c "echo test"
./systab -S
./systab -L
./systab -P <id>
./systab -R <id>
./systab -C
```

## Notes

- ShellCheck can be used for linting: `shellcheck systab`.
- Edit mode uses `|` as the field delimiter (not tabs or spaces) to allow multi-word schedules.
- Journal logs are queried with `USER_UNIT` OR `SYSLOG_IDENTIFIER` to capture both systemd messages and command output.
