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
Type "systab -t 'every 5 minutes' -c 'echo health check OK'"
Sleep 500ms
Enter
Sleep 2s

# Create a one-time job
Type "systab -t 'in 30 minutes' -c 'echo reminder: meeting soon'"
Sleep 500ms
Enter
Sleep 2s

# Check status of all jobs
Type "systab -S"
Sleep 500ms
Enter
Sleep 4s

# View logs
Type "systab -L"
Sleep 500ms
Enter
Sleep 3s

# Pause a job (uses the first job ID from status)
Type "systab -P $(systab -S 2>/dev/null | grep -m1 'Job:' | awk '{print $2}')"
Sleep 500ms
Enter
Sleep 2s

# Show it's paused
Type "systab -S"
Sleep 500ms
Enter
Sleep 3s

# Resume it
Type "systab -R $(systab -S 2>/dev/null | grep -m1 'Disabled' -B4 | grep 'Job:' | awk '{print $2}')"
Sleep 500ms
Enter
Sleep 2s

# Clean up completed one-time jobs
Type "systab -C"
Sleep 500ms
Enter
Sleep 2s

Sleep 2s
