# systab — Notifications
# Shows status-aware desktop and email notifications.

Output demo/notifications.gif
Set Shell bash
Set Width 1200
Set Height 600
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# Desktop notification — success case
Type "# Desktop notification on success/failure"
Enter
Sleep 1s
Type "systab -t 'in 1 minute' -c 'echo success' -i"
Sleep 500ms
Enter
Sleep 2s

# Desktop notification — failure case
Type "systab -t 'in 1 minute' -c 'exit 1' -i"
Sleep 500ms
Enter
Sleep 2s

# Email notification
Type "# Email notification via sendmail"
Enter
Sleep 1s
Type "systab -t 'in 1 minute' -c 'echo test' -m user@example.com"
Sleep 500ms
Enter
Sleep 2s

# Both notifications
Type "# Both desktop and email"
Enter
Sleep 1s
Type "systab -t 'every day at 9am' -c '/home/user/backup.sh' -i -m admin@example.com"
Sleep 500ms
Enter
Sleep 2s

# Show the generated service file to see ExecStopPost lines
Type "# Inspect generated service file"
Enter
Sleep 1s
Type "cat ~/.config/systemd/user/systab_*.service | head -20"
Sleep 500ms
Enter
Sleep 4s

# Check status
Type "systab -S"
Sleep 500ms
Enter
Sleep 3s

Sleep 2s
