#!/bin/sh
input=$(cat)

# Colors
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Usage: color_pct <value> <yellow_threshold> <red_threshold> <label>
color_pct() {
  val=$1; low=$2; high=$3; label=$4
  if [ "$val" -ge "$high" ]; then
    printf "${RED}%s${RESET}" "$label"
  elif [ "$val" -ge "$low" ]; then
    printf "${YELLOW}%s${RESET}" "$label"
  else
    printf "${GREEN}%s${RESET}" "$label"
  fi
}

model=$(echo "$input" | jq -r '.model.display_name')

# Context usage  (green <50, yellow 50-80, red >80)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
used_int=$(printf "%.0f" "${used:-0}")
context=$(color_pct "$used_int" 50 80 "$(printf 'C:%s%%' "$used_int")")

metrics="$context"

# Session cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  metrics="$metrics $(printf '$%.3f' "$cost")"
fi

# Session (5h) rate limit + hours until reset  (green <50, yellow 50-75, red >75)
session_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$session_used" ]; then
  session_int=$(printf "%.0f" "$session_used")
  session_label=$(printf "S:%s%%" "$session_int")
  resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  if [ -n "$resets_at" ]; then
    now=$(date +%s)
    diff_min=$(( (resets_at - now) / 60 ))
    if [ "$diff_min" -le 59 ]; then
      reset_fmt="${diff_min}m"
    else
      reset_fmt="$(( diff_min / 60 ))h"
    fi
    session_label="$session_label $reset_fmt"
  fi
  metrics="$metrics $(color_pct "$session_int" 50 75 "$session_label")"
fi

# Weekly (7d) rate limit  (green <40, yellow 40-70, red >70)
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$week_used" ]; then
  week_int=$(printf "%.0f" "$week_used")
  week_label=$(printf "W:%s%%" "$week_int")
  week_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
  if [ -n "$week_resets_at" ]; then
    now=$(date +%s)
    diff_min=$(( (week_resets_at - now) / 60 ))
    diff_days=$(( diff_min / 1440 ))
    diff_hours=$(( (diff_min % 1440) / 60 ))
    if [ "$diff_days" -gt 0 ]; then
      week_label="$week_label ${diff_days}d${diff_hours}h"
    else
      week_label="$week_label ${diff_hours}h"
    fi
  fi
  metrics="$metrics $(color_pct "$week_int" 40 70 "$week_label")"
fi

# Output style / mode (e.g. plan mode)
style=$(echo "$input" | jq -r '.output_style.name // empty')
if [ -n "$style" ] && [ "$style" != "null" ] && [ "$style" != "default" ]; then
  metrics="$metrics | $style"
fi

# Git branch + dirty indicator
dir=$(echo "$input" | jq -r '.workspace.current_dir')
branch=$(git -C "$dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  dirty=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)
  [ -n "$dirty" ] && branch="${branch}*"
fi

if [ -n "$branch" ]; then
  printf "%s | %s | %s" "$model" "$metrics" "$branch"
else
  printf "%s | %s" "$model" "$metrics"
fi
