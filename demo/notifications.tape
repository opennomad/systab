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
Hide
Type "./demo/note.sh 'Desktop notification on success'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'in 1 minute' -c 'echo success' -i"
Sleep 500ms
Enter
Sleep 2s

# Desktop notification — failure case
Hide
Type "./demo/note.sh 'Desktop notification on failure'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'in 1 minute' -c 'exit 1' -i"
Sleep 500ms
Enter
Sleep 2s

# Email notification
Hide
Type "./demo/note.sh 'Email notification via sendmail'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'in 1 minute' -c 'echo test' -m user@example.com"
Sleep 500ms
Enter
Sleep 2s

# Both notifications
Hide
Type "./demo/note.sh 'Both desktop and email notifications'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'every day at 9am' -c '/home/user/backup.sh' -i -m admin@example.com"
Sleep 500ms
Enter
Sleep 2s

# Show the generated service file to see ExecStopPost lines
Hide
Type "./demo/note.sh 'Inspecting generated service file'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "cat ~/.config/systemd/user/systab_*.service | less"
Sleep 500ms
Enter
Sleep 2s
Type "/ExecStopPost"
Enter
Sleep 3s
Type "q"
Sleep 1s

# Check status
Hide
Type "./demo/note.sh 'Checking status of all jobs'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S | less"
Sleep 500ms
Enter
Sleep 2s
Type "/Job:"
Enter
Sleep 3s
Type "q"
Sleep 1s

Sleep 2s
