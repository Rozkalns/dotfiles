#!/bin/bash

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DOTFILES_DIR="$(cd "$_SCRIPT_DIR/.." && pwd)"

# Add bin to PATH for utility scripts
export PATH="$_DOTFILES_DIR/bin:$PATH"

. "$_SCRIPT_DIR/utils.sh"

# Configuration
SCREENSHOTS_FOLDER="${HOME}/Screenshots"
COMPUTER_NAME="Hatchet"
LANGUAGES=(en lv)
LOCALE="en_US@currency=EUR"
MEASUREMENT_UNITS="Centimeters"

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
    info "Applying comprehensive macOS system defaults..."
    info "This may take a minute..."

    # Close System Preferences to prevent conflicts
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null

    ###############################################################################
    # Computer & Host Name                                                        #
    ###############################################################################

    # Get current computer name
    CURRENT_NAME=$(scutil --get ComputerName 2>/dev/null || echo "Not set")

    info "Current computer name: $CURRENT_NAME"
    read -p "Set computer name to '$COMPUTER_NAME'? (Skip on work laptops) [y/n] " set_computer_name

    if [[ "$set_computer_name" == "y" ]]; then
        info "Setting computer name to: $COMPUTER_NAME..."
        sudo scutil --set ComputerName "$COMPUTER_NAME"
        sudo scutil --set HostName "$COMPUTER_NAME"
        sudo scutil --set LocalHostName "$COMPUTER_NAME"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
        success "Computer name set to $COMPUTER_NAME"
    else
        info "Skipping computer name change (keeping: $CURRENT_NAME)"
    fi

    ###############################################################################
    # Localization                                                                #
    ###############################################################################

    info "Configuring localization (languages, locale, metric units)..."

    # Set language and text formats
    defaults write NSGlobalDomain AppleLanguages -array ${LANGUAGES[@]}
    defaults write NSGlobalDomain AppleLocale -string "$LOCALE"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "$MEASUREMENT_UNITS"
    defaults write NSGlobalDomain AppleMetricUnits -bool true

    # Set the time zone automatically
    sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
    sudo systemsetup -setusingnetworktime on 2>/dev/null

    ###############################################################################
    # Security                                                                    #
    ###############################################################################

    info "Configuring security settings..."

    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    ###############################################################################
    # System Behavior                                                             #
    ###############################################################################

    info "Configuring system behavior..."

    # Disable audio feedback when volume is changed
    defaults write com.apple.sound.beep.feedback -bool false

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" " 2>/dev/null
    sudo nvram StartupMute=%01 2>/dev/null

    # Menu bar: show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent YES

    # Disable opening and closing window animations (faster)
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

    # Increase window resize speed for Cocoa applications
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Disable Resume system-wide
    defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

    # Disable the crash reporter
    defaults write com.apple.CrashReporter DialogType -string "none"

    ###############################################################################
    # Keyboard & Input                                                            #
    ###############################################################################

    info "Configuring keyboard and input..."

    # Disable smart quotes and dashes as they're annoying when typing code
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    ###############################################################################
    # Trackpad, Mouse, Bluetooth                                                  #
    ###############################################################################

    info "Configuring trackpad and mouse..."

    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    # Trackpad: swipe between pages with three fingers
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

    # Increase sound quality for Bluetooth headphones/headsets
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    ###############################################################################
    # Screen & Screenshots                                                        #
    ###############################################################################

    info "Configuring screen and screenshots..."

    # Save screenshots to the ~/Screenshots folder
    mkdir -p "${SCREENSHOTS_FOLDER}"
    defaults write com.apple.screencapture location -string "${SCREENSHOTS_FOLDER}"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 2

    ###############################################################################
    # Finder                                                                      #
    ###############################################################################

    info "Configuring Finder..."

    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true

    # Finder: disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Finder: show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Finder: allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Expand the following File Info panes: "General", "Open with", and "Sharing & Permissions"
    defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

    # Hide icons on desktop (optional - keep your current setting)
    defaults write com.apple.finder CreateDesktop -bool false

    # Hide external/internal drives on desktop (optional - keep your current setting)
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

    ###############################################################################
    # Dock                                                                        #
    ###############################################################################

    info "Configuring Dock..."

    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true

    # Don't animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false

    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    # No bouncing icons
    defaults write com.apple.dock no-bouncing -bool true

    # Don't show recently used applications in the Dock
    defaults write com.Apple.Dock show-recents -bool false

    # Do not rearrange spaces automatically
    defaults write com.apple.dock mru-spaces -bool false

    # Dock size settings
    defaults write com.apple.dock tilesize -float 48
    defaults write com.apple.dock largesize -float 160
    defaults write com.apple.dock minimize-to-application -bool true

    # Hot corners
    # Top-left: disabled
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tl-modifier -int 0
    # Top-right: disabled
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-tr-modifier -int 0
    # Bottom-left: Start Screen Saver (locks screen with password requirement)
    defaults write com.apple.dock wvous-bl-corner -int 10
    defaults write com.apple.dock wvous-bl-modifier -int 0
    # Bottom-right: disabled
    defaults write com.apple.dock wvous-br-corner -int 0
    defaults write com.apple.dock wvous-br-modifier -int 0

    ###############################################################################
    # Mail                                                                        #
    ###############################################################################

    info "Configuring Mail..."

    # Display emails in threaded mode
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"

    # Disable send and reply animations in Mail.app
    defaults write com.apple.mail DisableReplyAnimations -bool true
    defaults write com.apple.mail DisableSendAnimations -bool true

    # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>`
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    # Disable inline attachments (just show the icons)
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    # Disable sound for incoming mail
    defaults write com.apple.mail MailSound -string ""
    defaults write com.apple.mail PlayMailSounds -bool false

    # Mark all messages as read when opening a conversation
    defaults write com.apple.mail ConversationViewMarkAllAsRead -bool true

    # Disable including results from trash in search
    defaults write com.apple.mail IndexTrash -bool false

    # Automatically check for new messages (not every 5 minutes)
    defaults write com.apple.mail AutoFetch -bool true
    defaults write com.apple.mail PollTime -string "-1"

    # Show most recent message at the top in conversations
    defaults write com.apple.mail ConversationViewSortDescending -bool true

    ###############################################################################
    # Calendar                                                                    #
    ###############################################################################

    info "Configuring Calendar..."

    # Show week numbers
    defaults write com.apple.iCal "Show Week Numbers" -bool true

    # Week starts on Monday
    defaults write com.apple.iCal "first day of week" -int 1

    ###############################################################################
    # Activity Monitor                                                            #
    ###############################################################################

    info "Configuring Activity Monitor..."

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    ###############################################################################
    # Software Updates                                                            #
    ###############################################################################

    info "Configuring software updates..."

    # Enable the automatic update check
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    # Check for software updates weekly
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 7

    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true

    # Install System data files & security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

    # Turn on app auto-update
    defaults write com.apple.commerce AutoUpdate -bool true

    # Allow the App Store to reboot machine on macOS updates
    defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

    ###############################################################################
    # Time Machine                                                                #
    ###############################################################################

    info "Configuring Time Machine..."

    # Disable prompting to use new external drives as Time Machine volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    ###############################################################################
    # Rectangle (if installed)                                                    #
    ###############################################################################

    if [ -d "/Applications/Rectangle.app" ]; then
        info "Configuring Rectangle..."
        defaults write com.knollsoft.Rectangle curtainChangeSize -int 2
        defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 1
        defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.85
    fi

    ###############################################################################
    # Restart affected applications                                               #
    ###############################################################################

    info "Restarting affected applications..."

    for app in "Activity Monitor" "Calendar" "Dock" "Finder" "Mail" "SystemUIServer"; do
        killall "${app}" &> /dev/null
    done

    success "macOS defaults applied successfully!"
    info "Some changes may require a logout/restart to take full effect."
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    register_keyboard_shortcuts
    apply_osx_system_defaults
fi