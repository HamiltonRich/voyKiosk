#!/bin/bash

# Rich H script to deploy kiosk mode to a linux install
# The setup script sets the kiosk script in the autostart folder and installs
# xdotools if needed.
# It initiates the shutdown if the user clicks "Cancel" or closes the dialog.

# Change wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:///home/voyage/desktop/wallpaper.png'

# Hide dock
gnome-extensions disable ubuntu-dock@ubuntu.com

# Function to run commands with sudo when necessary
run_command() {
  if sudo -n true 2>/dev/null; then
    # No password prompt needed, can run the command with sudo directly
    sudo "$@"
  else
    # Password is needed, prompt the user for it using Zenity
    password=$(zenity --password --title="Enter the password for sudo" --width=500)
    # Check if the user canceled the password entry
    if [[ $? -ne 0 ]]; then
      zenity --error --text="Password entry canceled. Exiting..."
      exit 1
    fi
    # Execute the command with sudo using the password provided by the user
    echo "$password" | sudo -S "$@"
  fi
}

# Check if xdotool is installed
if ! command -v xdotool ; then
    echo "Error: xdotool not found. Installing now."
    run_command sudo apt install xdotool
    zenity --info --text="xdotool is installed."  --width=500 
else
    zenity --info --text="xdotool is installed." --width=500
fi

#make autostart directory if not already in place
dir="/home/voyage/.config/autostart"

if [ ! -d $dir ]; then
    zenity --info --text="Creating directory: $dir" --width=500
    mkdir -p $dir
else
    zenity --info--text="Directory already exists: $dir" --width=500
fi

# Disable meta key
gsettings set org.gnome.mutter overlay-key 'disabled'
zenity --info --text="Meta key disabled" --width=500

# Contents of the .desktop file
desktop_file_content="[Desktop Entry]
Type=Application
Exec=$HOME/Desktop/kiosk.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=kiosk
Name=kiosk
Comment[en_US]=
Comment="

autostart_dir="$HOME/.config/autostart"
echo "$desktop_file_content" > "$autostart_dir/kiosk.desktop"
chmod +x "$autostart_dir/kiosk.desktop"

zenity --info --text="Setup complete" --width=500
