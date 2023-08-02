# Message content
message="This laptop is for training purposes only. It will not access Teams, Outlook or any Voyagecare application with the exception of Aspire. If you encounter any issues, please contact the IT helpdesk."

# Get the screen resolution
screen_width=$(xrandr --current | grep 'connected primary' | awk '{print $4}' | cut -d 'x' -f1)
screen_height=$(xrandr --current | grep 'connected primary' | awk '{print $4}' | cut -d 'x' -f2)

# Calculate the center coordinates for the dialog box
dialog_width=300
dialog_height=150
x=$((($screen_width - $dialog_width) / 2))
y=$((($screen_height - $dialog_height) / 2))

# Display the dialog box in the center of the screen and wait for user input
if zenity --question --title="Notification" --text="$message" --width=$dialog_width --height=$dialog_height --ok-label="OK" --cancel-label="Cancel"; then
    # OK button was clicked
    # Start Firefox in kiosk mode using private window as no cache
    firefox --kiosk --private-window voyagecare.com
else
    # Cancel button was clicked or the dial'disabled'og was closed
    zenity --info --text= "Notification" "Cancel button pressed. Initiating shutdown..." --width=500
    # Wait for a few seconds before shutting down to allow the user to see the message
sleep 5

# Shutdown the machine
systemctl poweroff
fi