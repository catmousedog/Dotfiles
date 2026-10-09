#!/bin/bash

# Get current color scheme
CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$CURRENT_SCHEME" = "'prefer-dark'" ]; then
    # Switch to Light Mode
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' # Change to your light theme
else
    # Switch to Dark Mode
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' # Change to your dark theme
fi