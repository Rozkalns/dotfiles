# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
# Greedy-upgrade these auto_updates casks (brew owns them; turn off in-app updaters). Casks only run from an interactive terminal, not the 3am LaunchAgent
export HOMEBREW_UPGRADE_GREEDY_CASKS="claude docker-desktop figma firefox@developer-edition ghostty github handbrake-app herd keka keycastr lm-studio macpass miro netnewswire notion obsidian phpstorm postman raycast rectangle shottr spotify"
