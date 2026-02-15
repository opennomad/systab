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
Hide
Type "./demo/note.sh 'Creating some jobs to work with'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "systab -t 'every 5 minutes' -c 'echo ping'"
Enter
Sleep 2s
Type "systab -t daily -c '/home/user/backup.sh' -i"
Enter
Sleep 2s

# Open edit mode with EDITOR=nano for visibility
Hide
Type "./demo/note.sh 'Opening edit mode — add notifications, create and modify jobs'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
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
Type "new:n=health,i,e=admin@example.com | hourly | curl -s https://example.com/health"
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
Hide
Type "./demo/note.sh 'Changes applied — checking status'"
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

# Re-open edit mode to show flags are persisted
Hide
Type "./demo/note.sh 'Re-opening edit mode — flags are persisted'"
Enter
Sleep 500ms
Show
Sleep 1s
Type "EDITOR=nano systab -e"
Sleep 500ms
Enter
Sleep 3s

# Just view and exit without changes
Ctrl+X
Sleep 2s

Sleep 2s
