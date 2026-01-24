#!/bin/bash

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/utils.sh"

register_keyboard_shortcuts() {
    info "Registering keyboard shortcuts..."

    # Disable Spotlight Cmd+Space shortcut to allow Raycast to use it
    info "Disabling Spotlight Cmd+Space shortcut for Raycast..."
    # Disable Show Spotlight search (key code 64)
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
    # Disable Show Finder search window (key code 65)
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"

    success "Spotlight shortcuts disabled. Raycast can now use Cmd+Space"
    info "Note: You may need to restart or log out for changes to take effect"
}

apply_osx_system_defaults() {
    info "Applying OSX system defaults..."

    # Enable key repeats
    defaults write -g ApplePressAndHoldEnabled -bool false

    # Disable prompting to use new exteral drives as Time Machine volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Hide external hard drives on desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

    # Hide hard drives on desktop
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

    # Hide removable media hard drives on desktop
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

    # Hide mounted servers on desktop
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

    # Hide icons on desktop
    defaults write com.apple.finder CreateDesktop -bool false

    # Avoid creating .DS_Store files on network volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show hidden files inside the finder
    defaults write com.apple.finder "AppleShowAllFiles" -bool true

    # Show Status Bar
    defaults write com.apple.finder "ShowStatusBar" -bool true

    # Do not show warning when changing the file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Set weekly software update checks
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 7

    # Spaces span all displays
    defaults write com.apple.spaces "spans-displays" -bool false

    # Do not rearrange spaces automatically
    defaults write com.apple.dock "mru-spaces" -bool false

    # Set Dock autohide
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock largesize -float 128
    defaults write com.apple.dock "minimize-to-application" -bool true
    defaults write com.apple.dock tilesize -float 32

    # Rectangle
    defaults write com.knollsoft.Rectangle curtainChangeSize -int 2
    defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 1
    defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.85
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    register_keyboard_shortcuts
    apply_osx_system_defaults
fi