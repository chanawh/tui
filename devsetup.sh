#!/bin/bash

# Function to check for command availability
check_command() {
  command -v "$1" &> /dev/null
}

# Function to handle installation of Node.js via NVM
install_nodejs() {
  echo "Installing Node.js using NVM..."
  
  # Check if nvm is installed
  if ! check_command "nvm"; then
    echo "NVM not found. Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

    # Source NVM immediately for the current shell session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  fi

  # Ensure NVM is available before continuing
  if ! check_command "nvm"; then
    echo "NVM installation failed. Exiting setup."
    exit 1
  fi

  # Install Node.js using NVM
  nvm install node || { echo "Error installing Node.js"; return 1; }
}

# Function to restart the shell session
restart_shell() {
  echo "Restarting the terminal session to load NVM..."
  exec "$SHELL" -l || { echo "Failed to restart the terminal session. Please restart manually."; exit 1; }
}

# (Other functions for Python, Ruby, Go, Java, PHP will remain unchanged)

# Function to install the selected language
install_language() {
  local language=$1
  if [[ -z "$language" ]]; then
    echo "Error: No language specified."
    return 1
  fi

  case $language in
    "Node.js")
      echo "Installing Node.js..."
      install_nodejs || { echo "Error installing Node.js"; return 1; }
      ;;

    "Python")
      echo "Installing Python..."
      install_python || { echo "Error installing Python"; return 1; }
      ;;

    "Ruby")
      echo "Installing Ruby..."
      install_ruby || { echo "Error installing Ruby"; return 1; }
      ;;

    "Go")
      echo "Installing Go..."
      install_go || { echo "Error installing Go"; return 1; }
      ;;

    "Java")
      echo "Installing Java..."
      install_java || { echo "Error installing Java"; return 1; }
      ;;

    "PHP")
      echo "Installing PHP..."
      install_php || { echo "Error installing PHP"; return 1; }
      ;;

    *)
      echo "Unknown language selection: $language"
      return 1
      ;;
  esac
  echo "$language installation completed successfully!"
}

# Check if whiptail is installed
if ! check_command "whiptail"; then
  echo "whiptail is required but not installed. Please install it first."
  exit 1
fi

# Welcome message
whiptail --title "Auto DevOps Toolkit" --msgbox "Welcome to the DevOps Toolkit Setup!" 10 60

# Checklist for programming languages selection
LANGUAGES=$(whiptail --title "Select Programming Languages" --checklist \
"Choose the programming languages you want to set up:" 15 60 6 \
"Node.js" "Install Node.js using NVM" OFF \
"Python" "Install Python 3 and pip" OFF \
"Ruby" "Install Ruby and RVM" OFF \
"Go" "Install Go programming language" OFF \
"Java" "Install OpenJDK" OFF \
"PHP" "Install PHP" OFF \
3>&1 1>&2 2>&3)

# Check if user pressed Cancel or selected no languages
if [[ $? -ne 0 || -z "$LANGUAGES" ]]; then
  echo "No languages were selected or you pressed Cancel. Exiting setup."
  exit 1
fi

# Confirm selected languages
echo "You selected the following languages: $LANGUAGES"

# Remove double quotes and split into an array based on space
LANGUAGES_ARRAY=($(echo "$LANGUAGES" | tr -s ' ' '\n' | tr -d '"'))

# Loop through each selected language and install
for LANGUAGE in "${LANGUAGES_ARRAY[@]}"; do
  install_language "$LANGUAGE"
done

# Restart the shell to apply changes
restart_shell

echo "Setup complete."
