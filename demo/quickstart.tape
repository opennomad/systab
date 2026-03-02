# systab — Quick Start
# Create a timer, create a service, then use edit mode to add a new job.

Output demo/quickstart.gif
Set Shell bash
Set Width 1200
Set Height 600
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# Clean up any pre-existing jobs with names used in this demo
Hide
Type "for n in healthcheck_home monitor_home diskcheck_home; do systab -X \"$n\" 2>/dev/null || true; done"
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
Type "systab -t 'every 5 minutes' -n healthcheck_home -c 'uptime'"
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
Type "systab -s -n monitor_home -c 'ping -c 1 localhost'"
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

# Open edit mode: screenshot then add a new job
Hide
Type "./demo/note.sh 'Edit mode — add a new job'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
Sleep 500ms
Enter
Sleep 3s

Screenshot demo/editmode.png

# Navigate to end of file in nano and add a new job
Ctrl+V
Sleep 500ms
Down 5
Sleep 500ms
Type "new:n=diskcheck_home | daily | df -h"
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
Type "./demo/note.sh 'Status after edit — new job added'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S"
Sleep 500ms
Enter
Sleep 2s

Sleep 2s
