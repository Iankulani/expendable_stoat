#!/bin/bash
# EXPENDABLE_STOAT Setup Script
# Runs on Ubuntu 22.04/24.04

set -e

echo "🦡 EXPENDABLE_STOAT Setup Script"
echo "=================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}⚠️ Running as root. Continuing...${NC}"
else
    echo -e "${YELLOW}⚠️ Not running as root. Some features may require sudo.${NC}"
fi

# Detect OS
echo -e "${BLUE}📋 Detecting OS...${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    echo -e "${GREEN}✅ Detected $OS $VER${NC}"
else
    echo -e "${RED}❌ Could not detect OS${NC}"
    exit 1
fi

# Install system dependencies
echo -e "${BLUE}📦 Installing system dependencies...${NC}"
case $OS in
    ubuntu|debian)
        sudo apt-get update
        sudo apt-get install -y \
            python3.11 \
            python3-pip \
            python3-venv \
            git \
            curl \
            wget \
            build-essential \
            libssl-dev \
            libffi-dev \
            libxml2-dev \
            libxslt1-dev \
            zlib1g-dev \
            tcpdump \
            nmap \
            netcat-openbsd \
            whois \
            dnsutils \
            traceroute \
            nikto \
            iptables \
            iproute2 \
            net-tools \
            redis-server \
            postgresql \
            postgresql-contrib \
            nginx \
            supervisor \
            && sudo rm -rf /var/lib/apt/lists/*
        ;;
    rhel|centos|fedora)
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y \
            python3.11 \
            python3-pip \
            git \
            curl \
            wget \
            openssl-devel \
            libffi-devel \
            libxml2-devel \
            libxslt-devel \
            zlib-devel \
            tcpdump \
            nmap \
            nc \
            whois \
            bind-utils \
            traceroute \
            nikto \
            iptables \
            iproute \
            net-tools \
            redis \
            postgresql \
            postgresql-server \
            nginx \
            supervisor
        ;;
    *)
        echo -e "${RED}❌ Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

# Create project directory
echo -e "${BLUE}📁 Creating project directory...${NC}"
PROJECT_DIR="/opt/expendable_stoat"
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR
cd $PROJECT_DIR

# Clone or copy files
echo -e "${BLUE}📥 Setting up application...${NC}"
if [ -f "/tmp/expendable_stoat.tar.gz" ]; then
    tar -xzf /tmp/expendable_stoat.tar.gz -C $PROJECT_DIR
else
    echo -e "${YELLOW}⚠️ No archive found, assuming files are already here${NC}"
fi

# Create Python virtual environment
echo -e "${BLUE}🐍 Creating Python virtual environment...${NC}"
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# Create directories
echo -e "${BLUE}📁 Creating data directories...${NC}"
mkdir -p .expendable_stoat
mkdir -p expendable_stoat_reports
mkdir -p temp
mkdir -p deploy
mkdir -p logs
mkdir -p data

# Setup database
echo -e "${BLUE}🗄️ Setting up database...${NC}"
if command -v psql &> /dev/null; then
    sudo -u postgres psql -c "CREATE DATABASE expendable_stoat;" || true
    sudo -u postgres psql -c "CREATE USER stoat WITH PASSWORD 'stoat_secure_password_2024';" || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE expendable_stoat TO stoat;" || true
fi

# Setup Redis
echo -e "${BLUE}📡 Setting up Redis...${NC}"
if command -v redis-server &> /dev/null; then
    sudo systemctl enable redis-server
    sudo systemctl start redis-server
fi

# Setup configuration
echo -e "${BLUE}⚙️ Setting up configuration...${NC}"
cp .expendable_stoat/config.json.example .expendable_stoat/config.json || true
sed -i 's/"port": 5000/"port": 5000/g' .expendable_stoat/config.json
sed -i 's/"host": "0.0.0.0"/"host": "0.0.0.0"/g' .expendable_stoat/config.json

# Setup supervisor
echo -e "${BLUE}🔄 Setting up supervisor...${NC}"
sudo bash -c "cat > /etc/supervisor/conf.d/expendable_stoat.conf << EOF
[program:expendable_stoat]
command=$PROJECT_DIR/venv/bin/python $PROJECT_DIR/expendable_stoat.py
directory=$PROJECT_DIR
user=$USER
autostart=true
autorestart=true
stderr_logfile=$PROJECT_DIR/logs/stoat.err.log
stdout_logfile=$PROJECT_DIR/logs/stoat.out.log
environment=PATH=\"$PROJECT_DIR/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
EOF"

# Setup Nginx
echo -e "${BLUE}🌐 Setting up Nginx...${NC}"
sudo bash -c "cat > /etc/nginx/sites-available/expendable_stoat << EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /socket.io/ {
        proxy_pass http://127.0.0.1:5000/socket.io/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF"

sudo ln -sf /etc/nginx/sites-available/expendable_stoat /etc/nginx/sites-enabled/
sudo systemctl reload nginx

# Setup firewall
echo -e "${BLUE}🔥 Setting up firewall...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 5000/tcp
    sudo ufw allow 8080/tcp
    sudo ufw --force enable
fi

# Create systemd service
echo -e "${BLUE}📋 Creating systemd service...${NC}"
sudo bash -c "cat > /etc/systemd/system/expendable_stoat.service << EOF
[Unit]
Description=EXPENDABLE_STOAT Cybersecurity Platform
After=network.target postgresql.service redis-server.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
Environment=\"PATH=$PROJECT_DIR/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
ExecStart=$PROJECT_DIR/venv/bin/python $PROJECT_DIR/expendable_stoat.py
Restart=always
RestartSec=10
StandardOutput=append:$PROJECT_DIR/logs/stoat.log
StandardError=append:$PROJECT_DIR/logs/stoat.err.log

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable expendable_stoat
sudo systemctl start expendable_stoat

# Set permissions
echo -e "${BLUE}🔒 Setting permissions...${NC}"
sudo chown -R $USER:$USER $PROJECT_DIR
sudo chmod -R 755 $PROJECT_DIR

# Test installation
echo -e "${BLUE}🧪 Testing installation...${NC}"
sleep 2
if curl -s http://localhost:5000 > /dev/null; then
    echo -e "${GREEN}✅ Web dashboard is accessible${NC}"
else
    echo -e "${YELLOW}⚠️ Web dashboard may not be running yet${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ EXPENDABLE_STOAT Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}📋 Service Information:${NC}"
echo -e "  Web Dashboard: http://$(hostname -I | awk '{print $1}'):5000"
echo -e "  Phishing Server: http://$(hostname -I | awk '{print $1}'):8080"
echo -e "  API Endpoint: http://$(hostname -I | awk '{print $1}'):5000/api"
echo -e ""
echo -e "${BLUE}📝 Commands:${NC}"
echo -e "  sudo systemctl start expendable_stoat"
echo -e "  sudo systemctl stop expendable_stoat"
echo -e "  sudo systemctl status expendable_stoat"
echo -e "  sudo journalctl -u expendable_stoat -f"
echo -e ""
echo -e "${BLUE}🔧 Configuration:${NC}"
echo -e "  Config: $PROJECT_DIR/.expendable_stoat/config.json"
echo -e "  Logs: $PROJECT_DIR/logs/"
echo -e "  Database: PostgreSQL (expendable_stoat)"
echo -e "  Redis: localhost:6379"
echo -e ""
echo -e "${YELLOW}⚠️ Default credentials:${NC}"
echo -e "  Username: admin"
echo -e "  Password: expendable_stoat_2024"
echo -e "${RED}🔴 CHANGE THE DEFAULT PASSWORD AFTER FIRST LOGIN!${NC}"