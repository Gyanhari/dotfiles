# ~/.config/hypr/scripts/dim-screen.sh
#!/usr/bin/env bash
# Fade brightness down then back up on resume (cyberpunk feel)

# Fade down
for i in {100..10..-5}; do
    brightnessctl -s set $i%
    sleep 0.05
done

# Just before lock, go almost black
brightnessctl -s set 5%

# Lock will trigger right after this script finishes
