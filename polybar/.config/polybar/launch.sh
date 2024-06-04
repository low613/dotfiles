#!/usr/bin/env bash
killall polybar
if type "xrandr"; then
	for m in $(xrandr --query | grep " connected" | grep -v primary | cut -d" " -f1); do
		MONITOR=$m polybar --config="$HOME/.config/polybar/config.ini" --reload toph &
	done
	m=$(xrandr --query | grep " connected" | grep primary | cut -d" " -f1)
	MONITOR=$m polybar --config="$HOME/.config/polybar/config.ini" --reload primary &
else
	polybar --reload toph &
fi
