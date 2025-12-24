#!/bin/bash

if pgrep -x waybar > /dev/null; then
  pkill -x waybar
  sleep 0.3
fi

waybar &
