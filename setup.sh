#!/bin/bash

# Exit on any error
set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Initialize installation status array
declare -A install_status

# Function to log installation status
log_installation() {
    if [ $? -eq 0 ]; then
        install_status["$1"]="SUCCESS"
        echo -e "${GREEN}✓ Installed: $1${NC}"
    else
        install_status["$1"]="FAILED"
        echo -e "${RED}✗ Failed: $1${NC}"
    fi
}

echo -e "${BLUE}Starting installation process...${NC}\n"

# Update package list and upgrade existing packages
echo -e "${BOLD}Updating system packages...${NC}"
apt-get update && apt-get upgrade -y

# Install wget, curl, and other prerequisites
echo -e "\n${BOLD}Installing prerequisites...${NC}"
apt-get install -y wget curl apt-transport-https gnupg software-properties-common
log_installation "Prerequisites"

# Install Git
echo -e "\n${BOLD}Installing Git...${NC}"
apt-get install -y git
git config --system credential.helper store
git config --system pull.rebase false
log_installation "Git"

# Install Chrome
echo -e "\n${BOLD}Installing Chrome...${NC}"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
log_installation "Chrome"

# Install Slack
echo -e "\n${BOLD}Installing Slack...${NC}"
wget https://downloads.slack-edge.com/releases/linux/4.35.126/prod/x64/slack-desktop-4.35.126-amd64.deb
apt-get install -y ./slack-desktop-4.35.126-amd64.deb
rm slack-desktop-4.35.126-amd64.deb
log_installation "Slack"

# Install DBeaver CE
echo -e "\n${BOLD}Installing DBeaver CE...${NC}"
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
apt-get update
apt-get install -y dbeaver-ce
log_installation "DBeaver CE"

# Install Postman
echo -e "\n${BOLD}Installing Postman...${NC}"
snap install postman
log_installation "Postman"

# Install Skype
echo -e "\n${BOLD}Installing Skype...${NC}"
snap install skype --classic
log_installation "Skype"

# Install VSCode
echo -e "\n${BOLD}Installing VSCode...${NC}"
snap install code --classic
log_installation "VSCode"

# Install Terminator
echo -e "\n${BOLD}Installing Terminator...${NC}"
apt-get install -y terminator
log_installation "Terminator"

# Install MySQL Server
echo -e "\n${BOLD}Installing MySQL Server...${NC}"
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server mysql-server/root_password password password" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections
apt-get install -y mysql-server
systemctl enable mysql
systemctl start mysql
log_installation "MySQL Server"

# Install PostgreSQL
echo -e "\n${BOLD}Installing PostgreSQL...${NC}"
apt-get install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'password';\""
log_installation "PostgreSQL"

# Install NVM and Node.js 18
echo -e "\n${BOLD}Installing NVM and Node.js 18...${NC}"
export NVM_DIR="/root/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
. "$NVM_DIR/nvm.sh"
nvm install 18
nvm use 18
nvm alias default 18
log_installation "NVM and Node.js"

# Create environment script
cat > /etc/profile.d/development-env.sh << 'EOF'
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
chmod +x /etc/profile.d/development-env.sh

# Final system update
apt-get update && apt-get upgrade -y

# Print installation report
echo -e "\n${BOLD}Installation Report:${NC}"
echo -e "${BOLD}==================${NC}"

# Function to check if a command exists
check_command() {
    command -v $1 &> /dev/null
}

# Function to check if a service is running
check_service() {
    systemctl is-active --quiet $1
}

# Verify each installation
echo -e "\n${BOLD}Development Tools:${NC}"
check_command git && echo -e "${GREEN}✓ Git $(git --version)${NC}" || echo -e "${RED}✗ Git not found${NC}"
[ -f "/usr/bin/google-chrome" ] && echo -e "${GREEN}✓ Chrome$(google-chrome --version)${NC}" || echo -e "${RED}✗ Chrome not found${NC}"
[ -f "/usr/bin/slack" ] && echo -e "${GREEN}✓ Slack${NC}" || echo -e "${RED}✗ Slack not found${NC}"
check_command dbeaver && echo -e "${GREEN}✓ DBeaver${NC}" || echo -e "${RED}✗ DBeaver not found${NC}"
snap list | grep -q postman && echo -e "${GREEN}✓ Postman${NC}" || echo -e "${RED}✗ Postman not found${NC}"
snap list | grep -q skype && echo -e "${GREEN}✓ Skype${NC}" || echo -e "${RED}✗ Skype not found${NC}"
check_command code && echo -e "${GREEN}✓ VSCode$(code --version | head -n1)${NC}" || echo -e "${RED}✗ VSCode not found${NC}"
check_command terminator && echo -e "${GREEN}✓ Terminator${NC}" || echo -e "${RED}✗ Terminator not found${NC}"

echo -e "\n${BOLD}Databases:${NC}"
check_service mysql && echo -e "${GREEN}✓ MySQL Server is running${NC}" || echo -e "${RED}✗ MySQL Server is not running${NC}"
check_service postgresql && echo -e "${GREEN}✓ PostgreSQL is running${NC}" || echo -e "${RED}✗ PostgreSQL is not running${NC}"

echo -e "\n${BOLD}Node.js Environment:${NC}"
[ -s "$NVM_DIR/nvm.sh" ] && echo -e "${GREEN}✓ NVM installed${NC}" || echo -e "${RED}✗ NVM not found${NC}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    node_version=$(nvm current)
    echo -e "${GREEN}✓ Node.js $node_version${NC}"
else
    echo -e "${RED}✗ Node.js not found${NC}"
fi

echo -e "\n${BOLD}Installation process completed!${NC}"
echo -e "${BLUE}Please log out and log back in for all changes to take effect.${NC}"