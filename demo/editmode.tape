# systab — Edit Mode Screenshot
# Creates representative jobs, opens edit mode, captures a screenshot.

Output demo/editmode.gif
Set Shell bash
Set Width 1200
Set Height 500
Set FontSize 16

Set TypingSpeed 0

# Clean up any pre-existing jobs with names used in this demo
Hide
Type "for n in healthcheck_home backup_home syncthing_home cleanup_home; do systab -X \"$n\" 2>/dev/null || true; done"
Enter
Sleep 1s

# Create representative jobs silently
Type "systab -t 'every 5 minutes' -n healthcheck_home -c 'curl -s https://example.com/health' -i"
Enter
Sleep 2s
Type "systab -t 'daily' -n backup_home -c '/home/user/backup.sh' -i"
Enter
Sleep 2s
Type "systab -s -n syncthing_home -c '/usr/bin/syncthing --no-browser'"
Enter
Sleep 2s
Type "systab -t 'weekly' -n cleanup_home -c 'find /tmp -mtime +7 -delete'"
Enter
Sleep 2s
Show

Type "EDITOR=nano systab -e"
Enter
Sleep 3s

Screenshot demo/editmode.png

Sleep 1s
