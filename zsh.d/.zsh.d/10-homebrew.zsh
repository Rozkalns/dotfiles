# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
# Greedy-upgrade these auto_updates casks; phpstorm left out so its own updater doesn't race brew
export HOMEBREW_UPGRADE_GREEDY_CASKS="claude docker-desktop figma firefox@developer-edition ghostty github handbrake-app herd keka keycastr lm-studio macpass miro netnewswire notion obsidian postman raycast rectangle shottr spotify"
