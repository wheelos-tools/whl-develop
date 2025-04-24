#!/bin/bash
set -euo pipefail

# Check parameters: username and password
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <new_username> <password>"
    exit 1
fi

NEW_USER="$1"
PASSWORD="$2"

# Check if the user already exists
if id "$NEW_USER" &>/dev/null; then
    echo "Error: User '$NEW_USER' already exists!"
    exit 1
fi

# Create the user with a home directory and bash as the default shell
sudo useradd -m -s /bin/bash "$NEW_USER"

# Set the user password (non-interactively)
echo "$NEW_USER:$PASSWORD" | sudo chpasswd

# Get the current user's home directory (assuming it has config files)
CURRENT_HOME="/home/$(whoami)"

# Copy configuration files if they exist
for file in .bashrc .profile; do
    if [ -f "$CURRENT_HOME/$file" ]; then
        sudo cp "$CURRENT_HOME/$file" "/home/$NEW_USER/"
    fi
done

# Set ownership of the new user's home directory
sudo chown -R "$NEW_USER:$NEW_USER" "/home/$NEW_USER"

# Add the user to the sudo group for admin privileges
sudo usermod -aG sudo "$NEW_USER"

# --- Ensure the docker group exists and add the new user ---
# Check if the docker group exists and create it if it does not exist
if ! getent group docker > /dev/null; then
    echo "Info: 'docker' group does not exist. Creating it..."
    sudo groupadd docker
    echo "'docker' group created."
fi

# Add the new user to the docker group
sudo usermod -aG docker "$NEW_USER"
echo "User '$NEW_USER' added to 'docker' group."

echo "User '$NEW_USER' created, password set, added to sudo\docker group, and environment configured."
