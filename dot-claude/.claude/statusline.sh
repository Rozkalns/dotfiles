#!/usr/bin/env bash
# Claude Code status line (2 lines, color-coded thresholds)
# Line 1: model | context | 5h limit | 7d limit
# Line 2: last 3 distinct tools, then last 3 distinct skills — most recent
#         first, each with its session total

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

# Tool + skill usage from transcript (single pass: "T<tab>name" / "S<tab>skill")
# Skill calls are tallied as skills, not as a "Skill" tool.
usage=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  usage=$(jq -r '
    select(.type == "assistant") |
    .message.content[]? |
    select(.type == "tool_use") |
    if .name == "Skill"
    then "S\t" + (.input.skill // "?")
    else "T\t" + .name
    end
  ' "$transcript" 2>/dev/null)
fi

# Last 3 distinct names of one kind (T|S), most recent first, each with its total
recent_of() {
  printf '%s\n' "$usage" | awk -F'\t' -v kind="$1" '
    $1 == kind { n++; seq[n] = $2; total[$2]++ }
    END {
      for (i = n; i >= 1 && shown < 3; i--) {
        name = seq[i]
        if (name in seen) continue
        seen[name] = 1
        shown++
        out = out (shown > 1 ? " › " : "") name "(" total[name] ")"
      }
      print out
    }'
}

tools_recent=$(recent_of T)
skills_recent=$(recent_of S)

# Line 1: model | context | rate limits
printf '%b' "${model} | ctx ${ctx} | ${rate}\n"

# Line 2: tools and skills, most recent first.
# Labels sit at default weight to match line 1's "ctx"/"5h:"; entries stay dim.
printf '%b' "tools ${DIM}${tools_recent:-none yet}${RESET} | skills ${DIM}${skills_recent:-none}${RESET}"
