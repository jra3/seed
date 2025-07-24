#!/usr/bin/env bash

# macOS System Preferences Configuration
# Run with: bash macos-defaults.sh

echo "Configuring macOS defaults..."

# Important: Safari settings require Full Disk Access for Terminal
echo "NOTE: Safari settings require Full Disk Access for Terminal.app"
echo "If Safari settings don't work, grant access via:"
echo "System Settings → Privacy & Security → Full Disk Access → Add Terminal"
echo ""

# Close System Preferences to prevent conflicts
osascript -e 'tell application "System Preferences" to quit'

# Computer Name and Hostname
# ----------------------------------------------------------------------
# Set computer name (as it appears in Finder)
COMPUTER_NAME="johns-mac"
echo "Setting computer name to: $COMPUTER_NAME"

# Set all the hostname types
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"

# Flush DNS cache
sudo dscacheutil -flushcache

# General UI/UX
# ----------------------------------------------------------------------

# Set highlight color to lime green
# RGB values: 0.50 1.00 0.00 (lime green)
defaults write NSGlobalDomain AppleHighlightColor -string "0.500000 1.000000 0.000000"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Automatically quit printer app once print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Trackpad
# ----------------------------------------------------------------------

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Disable "More Gestures" trackpad options
# Swipe between pages
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 0

# Swipe between full-screen apps
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerHorizSwipeGesture -int 0

# Notification Center (already off by default, but let's be explicit)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 0

# Mission Control
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -int 0
defaults write com.apple.dock showMissionControlGestureEnabled -bool false

# App Exposé
defaults write com.apple.dock showAppExposeGestureEnabled -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerVertSwipeGesture -int 0

# Launchpad
defaults write com.apple.dock showLaunchpadGestureEnabled -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fourFingerPinchGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.fiveFingerPinchGesture -int 0

# Show Desktop
defaults write com.apple.dock showDesktopGestureEnabled -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 0

# Keyboard
# ----------------------------------------------------------------------

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set the fastest keyboard repeat rate (1 = fastest)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Swap Caps Lock and Control keys
# This remaps the modifier keys for the built-in keyboard
# The format is: <caps_lock>,<left_shift>,<left_control>,<left_option>,<left_command>,<right_option>,<right_command>
# Values: 0=disabled, 1=command, 2=shift, 3=option, 4=control, 5=caps_lock
# Swapping caps_lock (5) with control (4)
defaults -currentHost write -g com.apple.keyboard.modifiermapping.1452-636-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'
defaults -currentHost write -g com.apple.keyboard.modifiermapping.1452-636-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771300</integer></dict>'

# Screen
# ----------------------------------------------------------------------

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to a specific folder
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Hot Corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# 14: Quick Note
# Top left screen corner → Start screen saver
defaults write com.apple.dock wvous-tl-corner -int 5
defaults write com.apple.dock wvous-tl-modifier -int 0

# Finder
# ----------------------------------------------------------------------

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

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
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder (requires sudo)
if [[ -t 0 ]]; then
    # Interactive terminal - can prompt for password
    sudo chflags nohidden /Volumes 2>/dev/null || echo "Note: Could not unhide /Volumes (requires sudo)"
else
    # Non-interactive - skip sudo commands
    echo "Skipping: unhide /Volumes (requires sudo in interactive mode)"
fi

# Dock
# ----------------------------------------------------------------------

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 48

# Enable magnification
defaults write com.apple.dock magnification -bool true

# Set magnification icon size
defaults write com.apple.dock largesize -int 64

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Don't animate opening applications
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Safari & WebKit
# ----------------------------------------------------------------------

# Note: Safari is sandboxed and requires Full Disk Access for Terminal
# to properly write preferences. Without it, these commands won't work.
# Go to System Settings → Privacy & Security → Full Disk Access → Add Terminal

# Quit Safari before making changes
killall Safari 2>/dev/null || true

# Privacy: don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Enable the Develop menu and the Web Inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true  # Required for macOS Monterey+
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Show the bookmarks bar (Favorites bar)
defaults write com.apple.Safari ShowFavoritesBar -bool true
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true

# Show the status bar
defaults write com.apple.Safari ShowOverlayStatusBar -bool true

# Show the tab bar even with only one tab
defaults write com.apple.Safari AlwaysShowTabBar -bool true

# Kill preferences daemon to ensure changes are loaded
killall cfprefsd 2>/dev/null || true

# Terminal
# ----------------------------------------------------------------------

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Activity Monitor
# ----------------------------------------------------------------------

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# Other
# ----------------------------------------------------------------------

echo "macOS defaults configured!"
echo "Note: Some changes require a logout/restart to take effect."