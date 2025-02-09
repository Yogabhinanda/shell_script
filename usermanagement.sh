#!/bin/bash
# Week 3 Challenge 1: User Account Management

# INPUT FROM USER - Taking the arguements via command line from user
ACTION="$1"
USERNAME="$2"
PASSWD="$3"

# FUNCTIONS

#-z "$USERNAME" checks if user name is empty
create_user() {
    if [ -z "$USERNAME" ]; then
        echo "Enter a valid username, it cannot be empty"
        exit 1
    fi
    echo "Username to be created is valid - $USERNAME"
    
    if id "$USERNAME" &>/dev/null; then
        echo "User '$USERNAME' already exists."
        exit 1
    fi

    echo "User '$USERNAME' does not exist and will be created."

    # Create the user
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWD" | sudo chpasswd


    if [ $? -eq 0 ]; then
        echo "$USERNAME CREATED SUCCESSFULLY AND PASSWORD IS SET"
    else
        echo "Failed to create user $USERNAME"
        exit 1
    fi
}

# DELETE USER
delete_user() {
    if id "$USERNAME" &>/dev/null; then
        echo "User '$USERNAME' exists and will be deleted."
        sudo userdel -r "$USERNAME"
        echo "$USERNAME DELETED"
    else
        echo "User '$USERNAME' does not exist."
        exit 1
    fi
}

reset_password() {
    if ! id "$USERNAME" &>/dev/null; then
        echo "User '$USERNAME' does not exist."
        exit 1
    fi

    read -sp "Enter new password for $USERNAME: " NEW_PASSWD
    echo
    read -sp "Confirm new password: " CONFIRM_PASSWD
    echo

    if [ "$NEW_PASSWD" != "$CONFIRM_PASSWD" ]; then
        echo "Passwords do not match. Try again."
        exit 1
    fi

    echo "$USERNAME:$NEW_PASSWD" | sudo chpasswd

    if [ $? -eq 0 ]; then
        echo "Password for '$USERNAME' has been reset successfully."
    else
        echo "Failed to reset password for '$USERNAME'."
        exit 1
    fi
}


list_users() {
    echo "Listing all user accounts on the system:"
    awk -F':' '{print "Username: " $1 ", UID: " $3}' /etc/passwd
}

# switch case used
case "$ACTION" in
    create)
        create_user
        ;;
    delete)
        delete_user
        ;;
    modifypass)
        reset_password
        ;;
    list)
        list_users
        ;;
    *)
        echo "Enter a valid ACTION (create/delete/modifypass/list)"
        exit 1
        ;;
esac
