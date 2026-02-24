# systab — Persistent Services
# Creates a managed service (no timer), checks status, disables/enables,
# inspects via edit mode, then cleans up.

Output demo/services.gif
Set Shell bash
Set Width 1200
Set Height 600
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# Create a persistent service
Hide
Type "./demo/note.sh 'Creating a persistent service job (runs on login, auto-restarts)'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -s -n monitor -c 'sleep 3600'"
Sleep 500ms
Enter
Sleep 2s

# Check status — should show Type: Service, Active (running)
Hide
Type "./demo/note.sh 'Checking status — service is running'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S monitor"
Sleep 500ms
Enter
Sleep 2s

# Inspect the generated unit file
Hide
Type "./demo/note.sh 'Inspecting the generated unit file'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "cat ~/.config/systemd/user/systab_*.service | less"
Sleep 500ms
Enter
Sleep 2s
Type "/SYSTAB_TYPE"
Enter
Sleep 2s
Type "q"
Sleep 1s

# View logs
Hide
Type "./demo/note.sh 'Viewing service logs'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -L monitor"
Sleep 500ms
Enter
Sleep 2s

# Disable the service
Hide
Type "./demo/note.sh 'Disabling the service (stops it)'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -D monitor"
Sleep 500ms
Enter
Sleep 2s

# Verify disabled
Hide
Type "./demo/note.sh 'Verifying service is disabled/stopped'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S monitor"
Sleep 500ms
Enter
Sleep 2s

# Re-enable
Hide
Type "./demo/note.sh 'Re-enabling the service'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -E monitor"
Sleep 500ms
Enter
Sleep 2s

# Open edit mode — service appears with 'service' in schedule column
Hide
Type "./demo/note.sh 'Service jobs appear in edit mode with schedule = service'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
Sleep 500ms
Enter
Sleep 3s

# Just view and exit
Ctrl+X
Sleep 2s

# Also show a service created via edit mode
Hide
Type "./demo/note.sh 'Creating a service via edit mode: new:s | service | cmd'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
Sleep 500ms
Enter
Sleep 3s

Ctrl+V
Sleep 500ms
Down 5
Sleep 500ms
Type "new:s,n=watcher | service | sleep 7200"
Sleep 1s
Enter

Ctrl+O
Sleep 500ms
Enter
Sleep 500ms
Ctrl+X
Sleep 3s

# Final status
Hide
Type "./demo/note.sh 'Both services visible in status'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S"
Sleep 500ms
Enter
Sleep 3s

Sleep 2s
