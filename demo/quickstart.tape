# systab — Quick Start
# Creates a few jobs, checks status, views logs, then cleans up.

Output demo/quickstart.gif
Set Shell bash
Set Width 1200
Set Height 600
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# Create a recurring job
Hide
Type "./demo/note.sh 'Creating a recurring health check (every 5 minutes)'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'every 5 minutes' -c 'echo health check OK'"
Sleep 500ms
Enter
Sleep 2s

# Create a one-time job
Hide
Type "./demo/note.sh 'Creating a one-time reminder (30 minutes from now)'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'in 30 minutes' -c 'echo reminder: meeting soon'"
Sleep 500ms
Enter
Sleep 2s

# Check status of all jobs
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

# View logs
Hide
Type "./demo/note.sh 'Viewing job logs'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -L | less"
Sleep 500ms
Enter
Sleep 2s
Type "/Logs for"
Enter
Sleep 3s
Type "q"
Sleep 1s

# Pause a job (uses the first job ID from status)
Hide
Type "./demo/note.sh 'Pausing a job'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -P $(systab -S 2>/dev/null | grep -m1 'Job:' | awk '{print $2}')"
Sleep 500ms
Enter
Sleep 2s

# Show it's paused
Hide
Type "./demo/note.sh 'Verifying job is paused'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -S | less"
Sleep 500ms
Enter
Sleep 2s
Type "/Disabled"
Enter
Sleep 3s
Type "q"
Sleep 1s

# Resume it
Hide
Type "./demo/note.sh 'Resuming the paused job'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -R $(systab -S 2>/dev/null | grep -m1 'Disabled' -B4 | grep 'Job:' | awk '{print $2}')"
Sleep 500ms
Enter
Sleep 2s

# Clean up completed one-time jobs
Hide
Type "./demo/note.sh 'Cleaning up completed one-time jobs'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -C"
Sleep 500ms
Enter
Sleep 2s

Sleep 2s
