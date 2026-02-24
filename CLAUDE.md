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

- **Job creation** (`-t <time> [-n <name>] [-c <cmd> | -f <script> | stdin]` or `-s [-n <name>] [-c <cmd> | -f <script> | stdin]`): Generates a systemd unit pair (or single unit for services) with a 6-char hex short ID, reloads the daemon, and enables/starts the unit. An optional `-n <name>` assigns a human-readable name that can be used interchangeably with hex IDs in all operations.
  - **Timer jobs** (`-t`): Creates a `.service` + `.timer` pair. Time specs are parsed via `parse_time` which handles natural language (`every 5 minutes`), `date -d` relative/absolute times, and raw systemd OnCalendar values. One-time jobs get `Persistent=false` and `RemainAfterElapse=no` (auto-unload after firing). Notifications (`-i` desktop, `-m` email, `-o` include output) use `ExecStopPost` so they fire on both success and failure with status-aware icons/messages. The `-o [N]` flag fetches the last N lines of journal output (default 10). Notification flags are persisted in the service file as a `# SYSTAB_FLAGS=` comment.
  - **Service jobs** (`-s`): Creates a single `.service` file with `Type=simple`, `Restart=on-failure`, and `WantedBy=default.target`. No `.timer` file is created. A `daemon-reload` runs before `enable`/`start` so systemd registers the unit first. Service jobs are tagged with `# SYSTAB_TYPE=service` in the service file. Mutually exclusive with `-t`, `-i`, `-m`, `-o`.

- **Management** (`-D`, `-E`, `-e`, `-L`, `-S`, `-C`, `-h` — mutually exclusive):
  - `-D <id|name>` / `-E <id|name>`: Disable (stop+disable) or enable (enable+start) a job's timer. Accepts hex ID or name.
  - `-e`: Opens `$EDITOR` with a pipe-separated crontab (`ID[:FLAGS] | SCHEDULE | COMMAND`). Flags are appended to the ID with `:` (`s` = service, `i` = desktop, `e=addr` = email, `o` = output 10 lines, `o=N` = output N lines, `n=name` = job name, comma-separated). Service jobs appear with `service` as the schedule column. On save, diffs against the original to apply creates (ID=`new`), deletes (removed lines), updates (changed schedule/command/flags), and disable/enable (comment/uncomment lines). The `service` schedule keyword skips `parse_time` validation and routes to `_write_unit_files` with `job_type=service`.
  - `-L [id|name] [filter]`: Query `journalctl` logs for managed jobs (both unit messages and command output). Optional job ID or name to filter to a single job.
  - `-S [id|name]`: Show timer status via `systemctl`, including short IDs, names, and disabled state. Optional job ID or name to show a single job.
  - `-C`: Interactively clean up elapsed one-time timers (removes unit files from disk).

Key functions: `parse_time` (time spec → OnCalendar), `_write_unit_files` (shared service+timer creation; 4th param `job_type` selects timer vs service path), `create_job`/`create_job_from_edit` (thin wrappers), `edit_jobs` (crontab-style edit with diff-and-apply), `get_managed_units` (find tagged units by type), `get_managed_service_jobs` (find service-only jobs by `# SYSTAB_TYPE=service` marker), `is_job_service` (detect service vs timer job), `clean_jobs` (remove elapsed one-time timers), `disable_job`/`enable_job` (stop+disable / enable+start, branching on `is_job_service`), `write_notify_lines` (append `ExecStopPost` notification lines), `build_flags_string`/`parse_flags` (convert between CLI options and flags format, including `s` flag), `resolve_job_id` (resolve hex ID or name to hex ID, accepts service-only jobs).

## Testing

```bash
./test.sh
```

Runs 81 tests against real systemd user timers and services covering job creation, service creation, job names, status, logs, disable/enable, notifications, time format parsing, error cases, and cleanup. All test jobs are cleaned up automatically via trap.

Tests require a real systemd user session (`systemctl --user`) and cannot run in containers. CI runs ShellCheck only; tests are enforced locally via a pre-commit hook that also updates `badges/tests.json`.

After cloning, enable the hooks: `git config core.hooksPath .githooks`

## Notes

- ShellCheck can be used for linting: `shellcheck systab`.
- Edit mode uses `|` as the field delimiter (not tabs or spaces) to allow multi-word schedules. Flags use `:` after the ID (e.g., `a1b2c3:n=backup,i,o,e=user@host`). Service jobs use the literal string `service` as the schedule column.
- Flags (`s` = service, `i` = desktop, `o`/`o=N` = include output, `e=addr` = email, `n=name` = job name) are persisted as `# SYSTAB_FLAGS=...` comments in service files. Names are additionally stored as `# SYSTAB_NAME=...` comments. Service jobs are additionally tagged with `# SYSTAB_TYPE=service`. `ExecStopPost=` lines use `$SERVICE_RESULT`/`$EXIT_STATUS` for status-aware messages. Unit file `printf` format strings must use `%%s` (not `%s`) since systemd expands `%s` as a specifier before the shell runs.
- Journal logs are queried with `USER_UNIT` OR `SYSLOG_IDENTIFIER` to capture both systemd messages and command output.
- `show_status` uses `systemctl show -p ActiveState,SubState` (not `is-active`) for service jobs to correctly report states like `activating` that `is-active` would misreport as inactive.
- `daemon-reload` must run before `enable`/`start` for new service units; it is called inside `_write_unit_files` for the service path.
