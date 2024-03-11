#!/usr/bin/env bash

# Function to check if command exists
command_exists() {
    type "$1" &> /dev/null
}

# Check if Python3 and curl are installed
if ! command_exists python3; then
    echo "Error: Python 3 is not installed. Please install Python 3 and try again."
    exit 1
elif ! command_exists curl; then
    echo "Error: curl is not installed. Please install curl and try again."
    exit 1
fi

# Get the OS details
OS="$(uname -s)"
DISTRO=""

echo "Operating System Detected: $OS"

# Detecting Linux distribution
if [ "$OS" = "Linux" ] && [ -f "/etc/os-release" ]; then
    . /etc/os-release
    DISTRO=$NAME
    echo "Linux Distribution Detected: $DISTRO"
fi

# Function to install poetry specific to Arch Linux and derivatives
install_poetry_arch() {
    curl -sSL https://install.python-poetry.org | python3 -
}

# ...

# Install Poetry based on the identified distribution
if [[ "$DISTRO" == "Arch Linux" || "$DISTRO" == "ArcoLinux" ]]; then
    # Install Poetry for Arch Linux and derivatives
    echo "Installing Poetry for Arch-based distribution..."
    install_poetry_arch
else
    echo "Installation script is designed for Arch-based distributions."
    echo "Detected distribution is '$DISTRO'."
    exit 1
fi



# Check if Poetry is installed
if ! command_exists poetry; then
    echo "Poetry is not installed. Installing now..."
    install_poetry_arch
fi

# Check for lock file to see if 'poetry install' was run before.
if [ ! -f "poetry.lock" ]; then
    echo "Installing dependencies using Poetry..."
    poetry install

    # Exit if poetry install fails
    if [ $? -ne 0 ]; then
        echo "'poetry install' failed."
        exit 1
    fi
else
    echo "Dependencies have been installed previously."
fi

# Activate the virtual environment
# Note: 'poetry shell' won't work as expected in a non-interactive shell script
if ! poetry env list --full-path | grep -q "$(pwd)"; then
    POETRY_VENV_PATH=$(poetry env info --path)

    # Inform the user to activate the environment manually
    echo "Please activate the Poetry virtual environment manually with the following command:"
    echo "source ${POETRY_VENV_PATH}/bin/activate"

    # Alternatively, we can try activating the environment within the script
    # But this won't affect the parent shell
    # source "${POETRY_VENV_PATH}/bin/activate"
else
    echo "The Poetry virtual environment is already activated."
fi

# Run the server launch script if available
if [ -f "./run_server.sh" ]; then
    echo "Starting the server..."
    ./run_server.sh
else
    echo "Server launch script './run_server.sh' not found. Cannot start the server."
    exit 1
fi
