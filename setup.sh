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

# Function to check if a package is installed
is_installed() {
    if dpkg -l | grep -q "^ii  $1 "; then
        return 0
    else
        return 1
    fi
}

# Function to check if a snap package is installed
is_snap_installed() {
    if snap list | grep -q "^$1 "; then
        return 0
    else
        return 1
    fi
}

echo -e "${BLUE}Starting installation process...${NC}\n"

# Update package list and upgrade existing packages
echo -e "${BOLD}Updating system packages...${NC}"
apt-get update && apt-get upgrade -y

# Install wget, curl, and other prerequisites
echo -e "\n${BOLD}Installing prerequisites...${NC}"
if ! is_installed "wget" || ! is_installed "curl" || ! is_installed "apt-transport-https"; then
    apt-get install -y wget curl apt-transport-https gnupg software-properties-common
    log_installation "Prerequisites"
else
    echo -e "${GREEN}Prerequisites already installed${NC}"
fi

# Install Git
echo -e "\n${BOLD}Installing Git...${NC}"
if ! is_installed "git"; then
    apt-get install -y git
    git config --system credential.helper store
    git config --system pull.rebase false
    log_installation "Git"
else
    echo -e "${GREEN}Git already installed${NC}"
fi

# Install Chrome
echo -e "\n${BOLD}Installing Chrome...${NC}"
if ! is_installed "google-chrome-stable"; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt-get install -y ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
    log_installation "Chrome"
else
    echo -e "${GREEN}Chrome already installed${NC}"
fi

# Install Slack
echo -e "\n${BOLD}Installing Slack...${NC}"
if ! is_installed "slack-desktop"; then
    wget https://downloads.slack-edge.com/releases/linux/4.35.126/prod/x64/slack-desktop-4.35.126-amd64.deb
    apt-get install -y ./slack-desktop-4.35.126-amd64.deb
    rm slack-desktop-4.35.126-amd64.deb
    log_installation "Slack"
else
    echo -e "${GREEN}Slack already installed${NC}"
fi

# Install DBeaver CE
echo -e "\n${BOLD}Installing DBeaver CE...${NC}"
if ! is_installed "dbeaver-ce"; then
    wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | apt-key add -
    echo "deb https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
    apt-get update
    apt-get install -y dbeaver-ce
    log_installation "DBeaver CE"
else
    echo -e "${GREEN}DBeaver CE already installed${NC}"
fi

# Install Postman
echo -e "\n${BOLD}Installing Postman...${NC}"
if ! is_snap_installed "postman"; then
    snap install postman
    log_installation "Postman"
else
    echo -e "${GREEN}Postman already installed${NC}"
fi

# Install Skype
echo -e "\n${BOLD}Installing Skype...${NC}"
if ! is_snap_installed "skype"; then
    snap install skype --classic
    log_installation "Skype"
else
    echo -e "${GREEN}Skype already installed${NC}"
fi

# Install VSCode
echo -e "\n${BOLD}Installing VSCode...${NC}"
if ! is_snap_installed "code"; then
    snap install code --classic
    log_installation "VSCode"
else
    echo -e "${GREEN}VSCode already installed${NC}"
fi

# Install Terminator
echo -e "\n${BOLD}Installing Terminator...${NC}"
if ! is_installed "terminator"; then
    apt-get install -y terminator
    log_installation "Terminator"
else
    echo -e "${GREEN}Terminator already installed${NC}"
fi

# Disable Wayland
echo -e "\n${BOLD}Disabling Wayland...${NC}"
if [ -f "/etc/gdm3/custom.conf" ]; then
    # Create backup
    cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.backup
    # Uncomment and set WaylandEnable=false
    sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
    echo -e "${GREEN}Wayland disabled successfully${NC}"
else
    echo -e "${RED}GDM3 configuration file not found${NC}"
fi











# Second part
# Uninstall MySQL Server
echo -e "\n${BOLD}Removing MySQL Server...${NC}"
if command_exists mysql; then
    systemctl stop mysql
    apt-get purge -y mysql-server mysql-client mysql-common
    apt-get autoremove -y
    apt-get autoclean
    rm -rf /etc/mysql /var/lib/mysql
    log_installation "MySQL Server Removed"
else
    echo -e "${GREEN}✓ MySQL Server already removed${NC}"
fi

# Install MySQL Server and Set Root Password
echo -e "\n${BOLD}Installing MySQL Server...${NC}"
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server mysql-server/root_password password password" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections
apt-get install -y mysql-server
systemctl enable mysql
systemctl start mysql
log_installation "MySQL Server Installed"

# Configure MySQL to Use Root User with Password Authentication
# Skip user check, directly set the root user password
echo "till this"
sudo mysql -u root -ppassword -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
sudo mysql -u root -ppassword -e "FLUSH PRIVILEGES;"

# Define command_exists function (if not defined in the script)
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Uninstall PostgreSQL completely, including data and configuration files
echo -e "\n${BOLD}Removing PostgreSQL...${NC}"
if command_exists psql; then
    systemctl stop postgresql
    apt-get purge -y postgresql* postgresql-contrib
    apt-get autoremove -y
    apt-get autoclean
    rm -rf /etc/postgresql /var/lib/postgresql /var/log/postgresql /usr/share/postgresql
    log_installation "PostgreSQL Removed"
else
    echo -e "${GREEN}✓ PostgreSQL already removed${NC}"
fi

# Install PostgreSQL
echo -e "\n${BOLD}Installing PostgreSQL...${NC}"
apt-get install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql

# Ensure the "root" user is removed if it exists
echo -e "\n${BOLD}Ensuring PostgreSQL root user is removed...${NC}"
su - postgres -c "psql -c \"DROP USER IF EXISTS root;\""

# Ensure the "root" user is created with SUPERUSER role and password is set
echo -e "\n${BOLD}Configuring PostgreSQL root user...${NC}"
su - postgres -c "psql -c \"CREATE USER root WITH SUPERUSER PASSWORD 'password';\""

# Optional: Ensure the default postgres user also has a password (if needed)
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'password';\""

log_installation "PostgreSQL Installed and Configured"


# Install Redis
echo -e "\n${BOLD}Installing Redis...${NC}"
if ! is_installed "redis-server"; then
    apt-get install -y redis-server
    
    # Configure Redis
    cp /etc/redis/redis.conf /etc/redis/redis.conf.backup
    sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf
    
    # Start and enable Redis
    systemctl enable redis-server
    systemctl start redis-server
    log_installation "Redis"
else
    echo -e "${GREEN}Redis already installed${NC}"
fi

# Install NVM and Node.js 18
echo -e "\n${BOLD}Installing NVM and Node.js 18...${NC}"
export NVM_DIR="/root/.nvm"

if [ ! -d "$NVM_DIR" ]; then
    # Download and install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Source NVM immediately
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Add NVM to global profile
    cat > /etc/profile.d/nvm.sh << 'EOF'
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

    # Add NVM to current user's .bashrc
    cat >> ~/.bashrc << 'EOF'
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

    # Source the new NVM environment
    source ~/.bashrc
    
    # Install Node.js
    nvm install 18
    nvm use 18
    nvm alias default 18
    
    log_installation "NVM and Node.js"
else
    echo -e "${GREEN}NVM already installed${NC}"
fi

# Install Touchpad Gestures
echo -e "\n${BOLD}Installing Touchpad Gestures...${NC}"
if ! is_installed "touchegg"; then
    # Add Touchegg repository and install
    add-apt-repository -y ppa:touchegg/stable
    apt-get update
    apt-get install -y touchegg
    
    # Start and enable Touchegg service
    systemctl enable touchegg.service
    systemctl start touchegg.service
    
    # Install Flatpak if not already installed
    if ! is_installed "flatpak"; then
        apt-get install -y flatpak
    fi
    
    # Install Touché (GUI for Touchegg)
    flatpak install -y https://dl.flathub.org/repo/appstream/com.github.joseexposito.touche.flatpakref
    log_installation "Touchpad Gestures"
else
    echo -e "${GREEN}Touchpad Gestures already installed${NC}"
fi

# Create development environment script
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

# Enhanced MySQL connectivity check
check_mysql() {
    mysql -u root -ppassword -e "SELECT 1;" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "MySQL is accessible."
        return 0
    else
        echo "MySQL is not accessible."
        return 1
    fi
}
# Enhanced PostgreSQL connectivity check
check_postgres() {
    # Check if the root user exists and has superuser privileges
    if ! sudo -u postgres psql -c "SELECT rolname, rolsuper FROM pg_roles WHERE rolname='root';" &>/dev/null; then
        echo "PostgreSQL user 'root' does not exist or lacks superuser privileges."
        return 1
    fi

    # Check if the 'root' user can connect to the 'postgres' database
    if ! PGPASSWORD=password psql -U root -d postgres -h localhost -c "\q" &>/dev/null; then
        echo "PostgreSQL user 'root' cannot connect to the 'postgres' database."
        return 1
    fi

    echo "PostgreSQL user 'root' is accessible and can connect to 'postgres'."
    return 0
}





check_redis() {
    redis-cli ping &>/dev/null
    return $?
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
if check_service mysql && check_mysql; then
    echo -e "${GREEN}✓ MySQL Server is running and accessible${NC}"
else
    echo -e "${RED}✗ MySQL Server is not properly configured${NC}"
fi

if check_service postgresql && check_postgres; then
    echo -e "${GREEN}✓ PostgreSQL is running and accessible${NC}"
else
    echo -e "${RED}✗ PostgreSQL is not properly configured${NC}"
fi

if check_service redis-server && check_redis; then
    echo -e "${GREEN}✓ Redis is running and accessible${NC}"
else
    echo -e "${RED}✗ Redis is not properly configured${NC}"
fi

echo -e "\n${BOLD}Touchpad Gestures:${NC}"
check_service touchegg && echo -e "${GREEN}✓ Touchegg service is running${NC}" || echo -e "${RED}✗ Touchegg service is not running${NC}"
flatpak list | grep -q touche && echo -e "${GREEN}✓ Touché is installed${NC}" || echo -e "${RED}✗ Touché is not installed${NC}"

echo -e "\n${BOLD}Node.js Environment:${NC}"
if [ -s "/root/.nvm/nvm.sh" ]; then
    echo -e "${GREEN}✓ NVM installed${NC}"
    . "/root/.nvm/nvm.sh"
    node_version=$(node -v)
    echo -e "${GREEN}✓ Node.js $node_version${NC}"
else
    echo -e "${RED}✗ NVM not found${NC}"
    echo -e "${RED}✗ Node.js not found${NC}"
fi

echo -e "\n${BOLD}Installation process completed!${NC}"
echo -e "${BLUE}Please log out and log back in for all changes to take effect.${NC}"