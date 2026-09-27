#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  macOS defaults that matter for keyboard-driven work.
#  Run once:  ./macos/defaults.sh      Some settings need a logout.
#  Every line is reversible; the original value is in the comment.
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

echo "Keyboard"
# Fast key repeat — the single biggest win for navigating in nvim.
defaults write NSGlobalDomain KeyRepeat -int 2              # default 6
defaults write NSGlobalDomain InitialKeyRepeat -int 15      # default 25
# Hold a key to repeat it instead of showing the accent picker.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Full keyboard access: tab reaches every control in every dialog.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "Text input"
# Turn off the "helpful" substitutions that corrupt code and commit messages.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Windows & dialogs"
# No animation delay when a window opens or a sheet slides down.
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
# Expand the save panel by default, and save to disk rather than iCloud.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0        # no hover delay
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false         # keep Space order fixed

echo "Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search here
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Don't litter network and USB volumes with .DS_Store files.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "Screenshots"
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"

echo "Trackpad"
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo
echo "Restarting affected apps…"
for app in Dock Finder SystemUIServer; do killall "$app" >/dev/null 2>&1 || true; done
echo "Done. Log out and back in for the keyboard settings to fully apply."
