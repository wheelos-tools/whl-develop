#!/bin/bash
set -euo pipefail

# List regular users (UID >= 1000, excluding 'nobody')
echo "Available users:"
USER_LIST=$(awk -F: '$3 >= 1000 && $1 != "nobody" { print $1 }' /etc/passwd)
echo "$USER_LIST"
echo

# Prompt to select a user to delete
read -p "Enter the username you want to delete: " TARGET_USER

# Prevent deletion of root or the current user
if [ "$TARGET_USER" = "root" ] || [ "$TARGET_USER" = "$(whoami)" ]; then
    echo "Error: Cannot delete 'root' or the currently logged-in user!"
    exit 1
fi

# Check if the user exists
if ! id "$TARGET_USER" &>/dev/null; then
    echo "Error: User '$TARGET_USER' does not exist!"
    exit 1
fi

# Confirm deletion
read -p "Are you sure you want to delete user '$TARGET_USER' and their home directory? [y/N]: " CONFIRM
CONFIRM=${CONFIRM,,}  # Convert to lowercase

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
    echo "Aborted: User deletion cancelled."
    exit 0
fi

# Delete the user and their home directory
sudo userdel -r "$TARGET_USER"

echo "User '$TARGET_USER' has been deleted and their home directory removed."
