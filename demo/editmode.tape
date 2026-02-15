# systab — Edit Mode with Notification Flags
# Demonstrates the crontab-style editor with :flags syntax.

Output demo/editmode.gif
Set Shell bash
Set Width 1200
Set Height 600
Set FontSize 16

Set TypingSpeed 50ms

Sleep 1s

# First create some jobs to edit
Type "# Create some jobs to work with"
Enter
Sleep 500ms
Type "systab -t 'every 5 minutes' -c 'echo ping'"
Enter
Sleep 2s
Type "systab -t daily -c '/home/user/backup.sh' -i"
Enter
Sleep 2s

# Open edit mode with EDITOR=nano for visibility
Type "# Open edit mode — add notifications, create and modify jobs"
Enter
Sleep 1s
Type "EDITOR=nano systab -E"
Sleep 500ms
Enter
Sleep 3s

# In nano: navigate to the end of the file
# Ctrl+V = page down in nano, then Down to reach last line
Ctrl+V
Sleep 500ms
Down 5
Sleep 500ms

# Add a new job line with notification flags
Type "new:i,e=admin@example.com | hourly | curl -s https://example.com/health"
Sleep 1s
Enter

Sleep 1s

# Save and exit nano
Ctrl+O
Sleep 500ms
Enter
Sleep 500ms
Ctrl+X
Sleep 3s

# Show the result
Type "# See the changes applied"
Enter
Sleep 500ms
Type "systab -S"
Sleep 500ms
Enter
Sleep 4s

# Re-open edit mode to show flags are persisted
Type "# Re-open edit mode — flags are persisted"
Enter
Sleep 1s
Type "EDITOR=nano systab -E"
Sleep 500ms
Enter
Sleep 3s

# Just view and exit without changes
Ctrl+X
Sleep 2s

Sleep 2s
