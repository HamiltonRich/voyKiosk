#!/bin/bash

# Rich H script to deploy kiosk mode to a Linux install
# The setup script sets the kiosk script in the autostart folder and installs
# xdotools if needed.
# It initiates the shutdown if the user clicks "Cancel" or closes the dialog.

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
      zenity --error --text="Password entry cancelled. Exiting..."
      exit 1
    fi
    # Execute the command with sudo using the password provided by the user
    echo "$password" | sudo -S "$@"
  fi
}

# Function to run a command with a progress bar
run_command_with_progress() {
  # Display a progress dialog while running the command
  (
    echo "10"
    sleep 1
    echo "20"
    sleep 1
    echo "30"
    sleep 1
    echo "40"
    sleep 1
    echo "50"
    sleep 1
    echo "60"
    sleep 1
    echo "70"
    sleep 1
    echo "80"
    sleep 1
    echo "90"
    sleep 1
    echo "100"
  ) | zenity --progress --title="Running Command" --text="Please wait..." --auto-close --pulsate --width=500

  # Run the command
  "$@"

  # Close the progress dialog
  sleep 1
  echo "100" | zenity --progress --title="Running Command" --text="Please wait..." --auto-close --width=500
}

# Display a progress dialog while the script is running
(
  # Change wallpaper
  run_command_with_progress gsettings set org.gnome.desktop.background picture-uri '/home/voyage/Desktop/voyKiosk/wallpaper.jpg'

  # Hide dock
  run_command_with_progress gnome-extensions disable ubuntu-dock@ubuntu.com

  # Disable meta key
  run_command_with_progress gsettings set org.gnome.mutter overlay-key 'disabled'

  # Disable overview on start
  run_command_with_progress gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-at-top false

  # Check if xdotool is installed
  if ! command -v xdotool ; then
    run_command_with_progress sudo apt install xdotool
  fi

  # Create the autostart directory if not already in place
  dir="$HOME/.config/autostart"
  if [ ! -d $dir ]; then
    mkdir -p $dir
  fi

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
  echo "$desktop_file_content" > "$autostart_dir/kiosk.sh.desktop"
  chmod +x "$autostart_dir/kiosk.sh.desktop"

  
) | zenity --progress --title="Running Script" --text="Please wait..." --auto-close --pulsate --width=500

zenity --info --text="Setup complete" --width=500
