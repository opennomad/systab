# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`systab` is a single-file Bash script that provides a cron/at/batch-like interface for systemd user timers. It creates, manages, and cleans up systemd `.service` and `.timer` unit files in `~/.config/systemd/user/`. Managed units are tagged with a `# SYSTAB_MANAGED` marker comment. Unit filenames use a 6-char hex ID (e.g., `systab_a1b2c3.timer`) which doubles as the human-facing job identifier.

## Running

```bash
./systab [OPTIONS]
```

No build step. The script requires `bash`, `systemctl`, and optionally `notify-send` (for `-i`) and `sendmail`/`msmtp` (for `-m`).

## Architecture

The script has two modes controlled by CLI flags:

- **Job creation** (`-t <time> [-c <cmd> | -f <script> | stdin]`): Generates a systemd `.service` + `.timer` pair with a 6-char hex short ID, reloads the daemon, and enables/starts the timer. Time specs are parsed via `parse_time` which handles natural language (`every 5 minutes`), `date -d` relative/absolute times, and raw systemd OnCalendar values. One-time jobs get `Persistent=false` and `RemainAfterElapse=no` (auto-unload after firing). All jobs log stdout/stderr to the journal via `SyslogIdentifier`. Notifications (`-i` desktop, `-m` email, `-o <lines>` include output) use `ExecStopPost` so they fire on both success and failure with status-aware icons/messages. The `-o` flag fetches the last N lines of journal output (default 10) and includes them in the notification body. Notification flags are persisted in the service file as a `# SYSTAB_FLAGS=` comment.

- **Management** (`-P`, `-R`, `-E`, `-L`, `-S`, `-C` — mutually exclusive):
  - `-P <id>` / `-R <id>`: Pause (stop+disable) or resume (enable+start) a job's timer.
  - `-E`: Opens `$EDITOR` with a pipe-separated crontab (`ID[:FLAGS] | SCHEDULE | COMMAND`). Notification flags are appended to the ID with `:` (`i` = desktop, `e=addr` = email, `o` = output 10 lines, `o=N` = output N lines, comma-separated). On save, diffs against the original to apply creates (ID=`new`), deletes (removed lines), updates (changed schedule/command/flags), and pause/resume (comment/uncomment lines).
  - `-L [id] [filter]`: Query `journalctl` logs for managed jobs (both unit messages and command output). Optional job ID to filter to a single job.
  - `-S [id]`: Show timer status via `systemctl`, including short IDs and disabled state. Optional job ID to show a single job.
  - `-C`: Interactively clean up elapsed one-time timers (removes unit files from disk).

Key functions: `parse_time` (time spec → OnCalendar), `_write_unit_files` (shared service+timer creation), `create_job`/`create_job_from_edit` (thin wrappers), `edit_jobs` (crontab-style edit with diff-and-apply), `get_managed_units` (find tagged units by type), `clean_jobs` (remove elapsed one-time timers), `pause_job`/`resume_job` (disable/enable timers), `write_notify_lines` (append `ExecStopPost` notification lines), `build_flags_string`/`parse_flags` (convert between CLI options and flags format).

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
- Edit mode uses `|` as the field delimiter (not tabs or spaces) to allow multi-word schedules. Notification flags use `:` after the ID (e.g., `a1b2c3:i,o,e=user@host`).
- Notification flags are persisted as `# SYSTAB_FLAGS=...` comments in service files and as `ExecStopPost=` lines using `$SERVICE_RESULT`/`$EXIT_STATUS` for status-aware messages.
- Journal logs are queried with `USER_UNIT` OR `SYSLOG_IDENTIFIER` to capture both systemd messages and command output.
