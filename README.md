# systab

A cron/at-like interface for systemd user timers. Create, manage, and monitor scheduled jobs without writing unit files by hand.

## Install

Copy the `systab` script somewhere on your `$PATH`:

```bash
cp systab ~/.local/bin/
```

Requires `bash`, `systemctl`, and optionally `notify-send` (for `-i`) and `sendmail`/`msmtp` (for `-m`).

## Quick start

```bash
# Run a command every 5 minutes
systab -t "every 5 minutes" -c "curl -s https://example.com/health"

# Run a backup script every day at 2am
systab -t "every day at 2am" -f ~/backup.sh

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
| Absolute | `next tuesday at noon` | One-time |
| Systemd keyword | `hourly`, `daily`, `weekly`, `monthly` | Recurring |
| Systemd OnCalendar | `*:0/15` (every 15 min) | Recurring |
| Systemd OnCalendar | `*-*-* 02:00:00` (daily at 2am) | Recurring |
| Systemd OnCalendar | `Mon *-*-* 09:00` (Mondays at 9am) | Recurring |

Relative and absolute formats are parsed by `date -d`. Systemd OnCalendar values are passed through directly.

## Usage

### Creating jobs

```bash
# Command string
systab -t "every 5 minutes" -c "echo hello"

# Script file
systab -t "every day at 2am" -f ~/backup.sh

# From stdin
echo "ls -la /tmp" | systab -t daily

# With desktop notification (success/failure with status icon)
systab -t "in 1 hour" -c "make build" -i

# With email notification (via sendmail)
systab -t "every day at 6am" -c "df -h" -m user@example.com

# Include last 10 lines of output in notification
systab -t "every day at 6am" -c "df -h" -i -o 10
```

### Managing jobs

```bash
# Edit all jobs in your $EDITOR (crontab-style)
systab -E

# Show status of all jobs
systab -S

# Show status of a specific job
systab -S a1b2c3

# View logs (all jobs)
systab -L

# View logs for a specific job
systab -L a1b2c3

# View logs (filtered)
systab -L error

# Pause a job
systab -P <id>

# Resume a paused job
systab -R <id>

# Clean up completed one-time jobs
systab -C
```

### Edit mode

`systab -E` opens your editor with a pipe-delimited job list:

```
a1b2c3 | daily | /home/user/backup.sh
d4e5f6:i | *:0/15 | curl -s https://example.com
g7h8i9:e=user@host | weekly | ~/backup.sh
# aabbcc | hourly | echo "this job is paused"
```

- Edit the schedule or command to update a job
- Delete a line to remove a job
- Add a line with `new` as the ID to create a job: `new | every 5 minutes | echo hello`
- Comment out a line (`#`) to pause, uncomment to resume
- Append notification flags after the ID with `:` — `i` for desktop, `e=addr` for email, `o` for output (default 10 lines), `o=N` for custom count, comma-separated (e.g., `a1b2c3:i,o,e=user@host`)

### Job IDs

Each job gets a 6-character hex ID (e.g., `a1b2c3`) displayed on creation and in status output. Use this ID with `-P`, `-R`, and `-L`.

## How it works

systab creates systemd `.service` and `.timer` unit file pairs in `~/.config/systemd/user/`. Each managed unit is tagged with a `# SYSTAB_MANAGED` marker comment. One-time jobs auto-unload after firing. Job output (stdout/stderr) is captured in the systemd journal and viewable via `systab -L`.

Notifications use `ExecStopPost` so they fire after the service completes regardless of success or failure. Desktop notifications show `dialog-information` or `dialog-error` icons based on `$SERVICE_RESULT`. Notification flags are persisted as `# SYSTAB_FLAGS=` comments in service files, so they survive across edit sessions.

## Options

```
Job Creation:
  -t <time>         Time specification (required for job creation)
  -c <command>      Command string to execute
  -f <script>       Script file to execute (reads stdin if neither -c nor -f)
  -i                Send desktop notification on completion (success/failure)
  -m <email>        Send email notification to address (via sendmail)
  -o <lines>        Include last N lines of job output in notifications (default: 10)

Management:
  -P <id>           Pause (disable) a job
  -R <id>           Resume (enable) a paused job
  -E                Edit jobs in crontab-like format
  -L [id] [filter]  List job logs (optionally for a specific job and/or filtered)
  -S [id]           Show status of all managed jobs (or a specific job)
  -C                Clean up completed one-time jobs
  -h                Show help
```
