#!/bin/bash

# Update the package list and upgrade all packages
sudo apt update && sudo apt upgrade -y

# Install required dependencies
sudo apt install -y wget curl software-properties-common apt-transport-https

# Function to install Google Chrome
install_chrome() {
    echo "Installing Google Chrome..."
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
}

# Function to install Slack
install_slack() {
    echo "Installing Slack..."
    wget -q https://downloads.slack.com/linux_releases/slack-desktop-*.deb
    sudo apt install -y ./slack-desktop-*.deb
    rm -f slack-desktop-*.deb
}

# Function to install DBeaver Community Edition
install_dbeaver() {
    echo "Installing DBeaver Community Edition..."
    wget -qO - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
    echo "deb https://dbeaver.io/debs/ dbeaver-ce main" | sudo tee /etc/apt/sources.list.d/dbeaver.list
    sudo apt update
    sudo apt install -y dbeaver-ce
}

# Function to install Postman
install_postman() {
    echo "Installing Postman..."
    wget -q https://dl.pstmn.io/download/latest/linux64/Postman-linux-x64.tar.gz
    sudo tar -xzf Postman-linux-x64.tar.gz -C /opt
    sudo ln -s /opt/Postman/Postman /usr/bin/postman
    rm -f Postman-linux-x64.tar.gz
}

# Function to install Skype
install_skype() {
    echo "Installing Skype..."
    wget -q https://go.skype.com/skypeforlinux-64.deb
    sudo apt install -y ./skypeforlinux-64.deb
    rm -f skypeforlinux-64.deb
}

# Function to install Visual Studio Code
install_vscode() {
    echo "Installing Visual Studio Code..."
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt update
    sudo apt install -y code
}

# Function to install Terminator
install_terminator() {
    echo "Installing Terminator..."
    sudo apt install -y terminator
}

# Function to install MySQL Server
install_mysql() {
    echo "Installing MySQL Server..."
    sudo apt install -y mysql-server
    # Secure MySQL installation (non-interactive)
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
    sudo mysql -e "FLUSH PRIVILEGES;"
}

# Function to install PostgreSQL
install_postgresql() {
    echo "Installing PostgreSQL..."
    sudo apt install -y postgresql
    # Set username and password
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'password';"
}

# Function to install NVM and Node.js
install_nvm_node() {
    echo "Installing NVM and Node.js..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    # Source NVM to the current shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
    nvm install 18
}

# Run installation functions
install_chrome
install_slack
install_dbeaver
install_postman
install_skype
install_vscode
install_terminator
install_mysql
install_postgresql
install_nvm_node

# Clean up
sudo apt autoremove -y
echo "Installation completed successfully!"
