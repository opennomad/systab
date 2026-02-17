# systab

[![ShellCheck](https://code.opennomad.com/opennomad/systab/actions/workflows/ci.yml/badge.svg)](https://code.opennomad.com/opennomad/systab/actions?workflow=ci.yml)
[![Tests](https://img.shields.io/endpoint?url=https://code.opennomad.com/opennomad/systab/raw/branch/main/badges/tests.json)](badges/tests.json)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE)

A cron/at-like interface for systemd user timers. Create, manage, and monitor scheduled jobs without writing unit files by hand.

Because you want to use systemd, but miss the ease of ~crontab~`systab -e`!

- 🚀 create one-time or recurring jobs with one command
- ✏️ use your $EDITOR to manage `systab` timers in a single line format
- 📊 quickly see the status of your timers
- 📋 access the logs of timers
- 💪 enable and disable timers

<table>
<tr>
<td width="33%"><img src="demo/quickstart.gif" alt="Quick start demo"></td>
<td width="33%"><img src="demo/editmode.gif" alt="Edit mode demo"></td>
<td width="33%"><img src="demo/notifications.gif" alt="Notifications demo"></td>
</tr>
<tr>
<td align="center"><b>Quick start</b></td>
<td align="center"><b>Edit mode</b></td>
<td align="center"><b>Notifications</b></td>
</tr>
</table>

## Install

Copy the `systab` script somewhere on your `$PATH`:

```bash
cp systab ~/.local/bin/
```

Requires `bash`, `systemctl`, and optionally `notify-send` (for `-i`) and `sendmail`/`msmtp` (for `-m`).

## Quick start

```bash
# Run a command every 5 minutes (with a name for easy reference)
systab -t "every 5 minutes" -n healthcheck -c "curl -s https://example.com/health"

# Run a backup script every day at 2am
systab -t "every day at 2am" -n backup -f ~/backup.sh

# Run a one-time command in 30 minutes
systab -t "in 30 minutes" -c "echo reminder"

# Check status of all jobs
systab -S

# View logs
systab -L
```

## Time formats

systab accepts several time formats:

| Format | Example | Type |
|--------|---------|------|
| Natural recurring | `every 5 minutes` | Recurring |
| Natural recurring | `every 2 hours` | Recurring |
| Natural recurring | `every 30 seconds` | Recurring |
| Natural recurring | `every day at 2am` | Recurring |
| Natural recurring | `every monday at 9am` | Recurring |
| Natural recurring | `every month` | Recurring |
| Relative | `in 5 minutes` | One-time |
| Relative | `tomorrow` | One-time |
| Absolute | `2025-06-15 14:30` | One-time |
| Absolute | `next tuesday at 9am` | One-time |
| Systemd keyword | `hourly`, `daily`, `weekly`, `monthly` | Recurring |
| Systemd OnCalendar | `*:0/15` (every 15 min) | Recurring |
| Systemd OnCalendar | `*-*-* 02:00:00` (daily at 2am) | Recurring |
| Systemd OnCalendar | `Mon *-*-* 09:00` (Mondays at 9am) | Recurring |

Relative and absolute formats are parsed by `date -d`. Systemd OnCalendar values are passed through directly.

Note: `date -d` does not technically like "*in* 5 minutes" or "*at*" between day and time. `systab` strips "in" and "at" before passing to `date -d`.

## Usage

### Creating jobs

```bash
# Command string (with optional name)
systab -t "every 5 minutes" -n ping -c "echo hello"

# Script file
systab -t "every day at 2am" -n backup -f ~/backup.sh

# From stdin
echo "ls -la /tmp" | systab -t daily

# With desktop notification (success/failure with status icon)
systab -t "in 1 hour" -c "make build" -i

# With email notification (via sendmail)
systab -t "every day at 6am" -c "df -h" -m user@example.com

# Include last 10 lines of output in notification
systab -t "every day at 6am" -c "df -h" -i -o
```

### Managing jobs

```bash
# Edit all jobs in your $EDITOR (crontab-style)
systab -e

# Show status of all jobs
systab -S

# Show status of a specific job (by ID or name)
systab -S a1b2c3
systab -S backup

# View logs (all jobs)
systab -L

# View logs for a specific job (by ID or name)
systab -L a1b2c3
systab -L backup

# View logs (filtered)
systab -L error

# Disable/enable a job (by ID or name)
systab -D backup
systab -E backup

# Clean up completed one-time jobs
systab -C
```

### Edit mode

`systab -e` opens your editor with a pipe-delimited job list:

```
a1b2c3:n=backup | daily | /home/user/backup.sh
d4e5f6:i | *:0/15 | curl -s https://example.com
g7h8i9:n=weekly-backup,e=user@host | weekly | ~/backup.sh
# aabbcc | hourly | echo "this job is disabled"
```

- Edit the schedule or command to update a job
- Delete a line to remove a job
- Add a line with `new` as the ID to create a job: `new | every 5 minutes | echo hello`
- Comment out a line (`#`) to disable, uncomment to enable
- Append flags after the ID with `:` — `n=name` for naming, `i` for desktop notification, `e=addr` for email, `o` for output (default 10 lines), `o=N` for custom count, comma-separated (e.g., `a1b2c3:n=backup,i,o,e=user@host`)

### Job IDs and names

Each job gets a 6-character hex ID (e.g., `a1b2c3`) displayed on creation and in status output. You can also assign a human-readable name with `-n` at creation time. Names can be used interchangeably with hex IDs in `-D`, `-E`, `-S`, and `-L`. Names must be unique and cannot contain whitespace, pipes, or colons.

## How it works

systab creates systemd `.service` and `.timer` unit file pairs in `~/.config/systemd/user/`. Each managed unit is tagged with a `# SYSTAB_MANAGED` marker comment. One-time jobs auto-unload after firing. Job output (stdout/stderr) is captured in the systemd journal and viewable via `systab -L`.

Notifications use `ExecStopPost` so they fire after the service completes regardless of success or failure. Desktop notifications show `dialog-information` or `dialog-error` icons based on `$SERVICE_RESULT`. Notification flags are persisted as `# SYSTAB_FLAGS=` comments in service files, so they survive across edit sessions.

## Options

```
Job Creation:
  -t <time>         Time specification (required for job creation)
  -c <command>      Command string to execute
  -f <script>       Script file to execute (reads stdin if neither -c nor -f)
  -n <name>         Give the job a human-readable name (usable in place of hex ID)
  -i                Send desktop notification on completion (success/failure)
  -m <email>        Send email notification to address (via sendmail)
  -o [lines]        Include job output in notifications (default: 10 lines)

Management (accept hex ID or name):
  -D <id|name>      Disable a job
  -E <id|name>      Enable a disabled job
  -e                Edit jobs in crontab-like format
  -L [id|name] [filter]  List job logs (optionally for a specific job and/or filtered)
  -S [id|name]      Show status of all managed jobs (or a specific job)
  -C                Clean up completed one-time jobs
  -h                Show help
```

## License

AGPL-3.0-or-later. See [LICENSE](LICENSE).

## Contributing

The primary repository is hosted on [Forgejo](https://code.opennomad.com/opennomad/systab) with a public mirror on [GitHub](https://github.com/opennomad/systab).

Contributions (issues and pull requests) are welcome on GitHub.

After cloning, enable the pre-commit hook (runs ShellCheck + tests):

```bash
git config core.hooksPath .githooks
```


## FAQ

Why this wrapper?

I was missing the simplicity of `at` and `crontab` commands. `systemd` has many features and benefits that those tools do not have, but convenience for the user to set a quick timer is not one of them.

**What's the difference between `-c` and `-f`?**

`-f` validates that the file exists and is executable at creation time, catching typos and permission issues early. With `-c`, errors only surface when systemd runs the job later (visible via `systab -L`). Under the hood, both produce the same `ExecStart` line.

**Why did you mess with the crontab format?**

Originally I meant to keep it the same, but there isn't a one-to-one mapping of times supported by cron and systemd. systemd has more options. I also want the human readble strings like "in 5 minutes". Trying to force that into the crontab format with it's space delimited format meant quotes, etc. in the end I used the `|` and limit the number of fields so that the commands can also be piped.
