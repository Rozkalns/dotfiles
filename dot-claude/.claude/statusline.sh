#!/usr/bin/env bash
# Claude Code status line (2 lines, color-coded thresholds)
# Line 1: model | context | 5h limit | 7d limit
# Line 2: top 3 tools

input=$(cat)

# Colors
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[2m'
RESET='\033[0m'

# Color a percentage: green <50, yellow 50-79, red 80+
color_pct() {
  local val=$(printf '%.0f' "$1")
  if [ "$val" -ge 80 ]; then printf '%b' "$RED"
  elif [ "$val" -ge 50 ]; then printf '%b' "$YELLOW"
  else printf '%b' "$GREEN"
  fi
}

model=$(echo "$input" | jq -r '.model.display_name // "Claude"' | sed 's/ (.*)//')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

# Context window
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  filled=$(echo "$used_pct" | awk '{printf "%d", int($1 / 10 + 0.5)}')
  [ "$filled" -gt 10 ] && filled=10
  empty=$((10 - filled))
  bar_color=$(color_pct "$used_pct")
  bar=""
  for i in $(seq 1 "$filled"); do bar="${bar}█"; done
  for i in $(seq 1 "$empty");  do bar="${bar}░"; done
  ctx="${bar_color}[${bar}] ${pct_int}%${RESET}"
else
  ctx="${DIM}[░░░░░░░░░░] --${RESET}"
fi

# Rate limits (Max/Pro only)
five_h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

rate=""
if [ -n "$five_h_pct" ]; then
  five_h_display=$(printf '%.0f' "$five_h_pct")
  five_h_color=$(color_pct "$five_h_pct")
  if [ -n "$five_h_reset" ]; then
    now=$(date +%s)
    diff=$(( five_h_reset - now ))
    if [ "$diff" -gt 0 ]; then
      hours=$(( diff / 3600 ))
      mins=$(( (diff % 3600) / 60 ))
      five_h_time="${hours}h${mins}m"
    else
      five_h_time="now"
    fi
  else
    five_h_time="?"
  fi
  rate="5h: ${five_h_color}${five_h_display}%${RESET} ↻${five_h_time}"
fi

if [ -n "$seven_d_pct" ]; then
  seven_d_display=$(printf '%.0f' "$seven_d_pct")
  seven_d_color=$(color_pct "$seven_d_pct")
  if [ -n "$seven_d_reset" ]; then
    now=${now:-$(date +%s)}
    diff=$(( seven_d_reset - now ))
    if [ "$diff" -gt 0 ]; then
      days=$(( diff / 86400 ))
      hours=$(( (diff % 86400) / 3600 ))
      seven_d_time="${days}d${hours}h"
    else
      seven_d_time="now"
    fi
  else
    seven_d_time="?"
  fi
  rate="${rate} | 7d: ${seven_d_color}${seven_d_display}%${RESET} ↻${seven_d_time}"
fi

if [ -z "$rate" ]; then
  rate="${DIM}limits: --${RESET}"
fi

# Top 3 tools from transcript
tools=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  tools=$(jq -r '
    select(.type == "assistant") |
    .message.content[]? |
    select(.type == "tool_use") |
    .name
  ' "$transcript" 2>/dev/null \
    | sort | uniq -c | sort -rn | head -3 \
    | awk '{printf "%s(%d) ", $2, $1}' \
    | sed 's/ $//')
fi

# Line 1: model | context | rate limits
printf '%b' "${model} | ctx ${ctx} | ${rate}\n"

# Line 2: top tools
if [ -n "$tools" ]; then
  printf '%b' "${DIM}${tools}${RESET}"
else
  printf '%b' "${DIM}no tools yet${RESET}"
fi
