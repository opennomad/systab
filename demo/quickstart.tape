# systab — Quick Start
# Create a timer, create a service, then disable the service via edit mode.

Output demo/quickstart.gif
Set Shell bash
Set Width 1200
Set Height 600
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# Clean up any pre-existing jobs with names used in this demo
Hide
Type "for n in healthcheck_home monitor_home; do systab -X \"$n\" 2>/dev/null || true; done"
Enter
Sleep 1s
Show

# Create a recurring timer
Hide
Type "./demo/note.sh 'Create a recurring timer'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'every 5 minutes' -n healthcheck_home -c 'echo health check OK'"
Sleep 500ms
Enter
Sleep 2s

# Create a persistent service
Hide
Type "./demo/note.sh 'Create a persistent service'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -s -n monitor_home -c 'sleep 3600'"
Sleep 500ms
Enter
Sleep 2s

# Both visible in status
Hide
Type "./demo/note.sh 'Both jobs visible in status'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S"
Sleep 500ms
Enter
Sleep 2s

# Open edit mode and disable the service by commenting out its line
Hide
Type "./demo/note.sh 'Edit mode — disable the monitor service'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
Sleep 500ms
Enter
Sleep 3s

# In nano: search for "monitor_home", jump to start of that line, prefix with '#'
Ctrl+W
Sleep 500ms
Type "monitor_home"
Enter
Sleep 1s
Ctrl+A
Sleep 500ms
Type "#"
Sleep 500ms

Ctrl+O
Sleep 500ms
Enter
Sleep 500ms
Ctrl+X
Sleep 3s

# Verify the service is now disabled
Hide
Type "./demo/note.sh 'Monitor service is now disabled'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S"
Sleep 500ms
Enter
Sleep 2s

Sleep 2s
