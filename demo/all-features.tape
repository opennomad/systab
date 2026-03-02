# systab — All Features
# A complete walkthrough: timers, services, status, logs,
# disable/enable, list mode, notifications, and edit mode.

Output demo/all-features.gif
Set Shell bash
Set Width 1200
Set Height 700
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# Clean up any pre-existing jobs with names used in this demo
Hide
Type "for n in healthcheck_home monitor_home backup_home health2_home; do systab -X \"$n\" 2>/dev/null || true; done"
Enter
Sleep 1s
Show

# ── Job Creation ──────────────────────────────────────────────

Hide
Type "./demo/note.sh 'Recurring timer with a name'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'every 5 minutes' -n healthcheck_home -c 'echo health check OK'"
Sleep 500ms
Enter
Sleep 2s

Hide
Type "./demo/note.sh 'One-time reminder in 30 minutes'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'in 30 minutes' -c 'echo reminder: meeting soon'"
Sleep 500ms
Enter
Sleep 2s

Hide
Type "./demo/note.sh 'Persistent service — starts on login, auto-restarts on failure'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -s -n monitor_home -c 'sleep 3600'"
Sleep 500ms
Enter
Sleep 2s

# ── Status ────────────────────────────────────────────────────

Hide
Type "./demo/note.sh 'Status of all jobs and services'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S"
Sleep 500ms
Enter
Sleep 3s

# ── Logs ──────────────────────────────────────────────────────

Hide
Type "./demo/note.sh 'Viewing logs for a specific job'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -L healthcheck_home"
Sleep 500ms
Enter
Sleep 2s

# ── Disable / Enable ──────────────────────────────────────────

Hide
Type "./demo/note.sh 'Disabling a job by name'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -D healthcheck_home"
Sleep 500ms
Enter
Sleep 1s

Type "systab -S healthcheck_home"
Sleep 500ms
Enter
Sleep 2s

Hide
Type "./demo/note.sh 'Re-enabling the job'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -E healthcheck_home"
Sleep 500ms
Enter
Sleep 2s

# ── Notifications ─────────────────────────────────────────────

Hide
Type "./demo/note.sh 'Add desktop notification with -i (fires on job completion)'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'daily' -n backup_home -c '/home/user/backup.sh' -i"
Sleep 500ms
Enter
Sleep 2s

# ── List mode ─────────────────────────────────────────────────

Hide
Type "./demo/note.sh 'List all jobs in crontab format with -l'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -l"
Sleep 500ms
Enter
Sleep 2s

# ── Edit mode ─────────────────────────────────────────────────

Hide
Type "./demo/note.sh 'Edit mode — manage jobs in your $EDITOR'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
Sleep 500ms
Enter
Sleep 3s

# Navigate to end of file in nano and add a new job with flags
Ctrl+V
Sleep 500ms
Down 5
Sleep 500ms
Type "new:n=health2_home,i,e=admin@example.com | hourly | curl -s https://example.com/health"
Sleep 1s
Enter
Sleep 500ms

Ctrl+O
Sleep 500ms
Enter
Sleep 500ms
Ctrl+X
Sleep 3s

# Show updated status
Hide
Type "./demo/note.sh 'Status after edit — new job added with flags'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S"
Sleep 500ms
Enter
Sleep 3s

# ── Clean ─────────────────────────────────────────────────────

Hide
Type "./demo/note.sh 'Clean up completed one-time timers'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -C"
Sleep 500ms
Enter
Sleep 2s

Sleep 2s
