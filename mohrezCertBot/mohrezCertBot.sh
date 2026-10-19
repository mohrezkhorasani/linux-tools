#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Function to display usage
usage() {
    echo "Usage: $0 <domain>"
    echo "Example: $0 example.com"
    exit 1
}

# Check if domain argument is provided
if [ $# -eq 0 ]; then
    print_error "No domain provided!"
    usage
fi

DOMAIN="$1"
EMAIL="your-email@example.com"  # Change this to your email

# ---------------------------------------------------------------
# Stop Nginx so port 80 is free for certbot --standalone
# ---------------------------------------------------------------
print_info "Stopping Nginx to free port 80..."
sudo systemctl stop nginx

if [ $? -ne 0 ]; then
    print_error "Failed to stop Nginx"
    exit 1
fi
print_success "Nginx stopped"

# Ensure Nginx is started again no matter how the script exits
# (success, error, or Ctrl+C). The EXIT trap handles all cases.
restore_nginx() {
    print_info "Starting Nginx again..."
    sudo systemctl start nginx
    if [ $? -eq 0 ]; then
        print_success "Nginx started successfully"
    else
        print_error "Failed to start Nginx"
    fi
}
trap restore_nginx EXIT

# ---------------------------------------------------------------
# Run certbot
# ---------------------------------------------------------------
print_info "Starting Certbot generation for domain: $DOMAIN"
print_info "Running certbot to generate certificate..."

sudo certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    -d "$DOMAIN" \
    --preferred-challenges http

# Check if certbot was successful
if [ $? -ne 0 ]; then
    print_error "Certbot failed to generate certificate for $DOMAIN"
    exit 1
fi

# Find the actual directory name (with -0001 suffix if it exists)
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"

# Check if the directory exists, if not try with -0001 suffix
if [ ! -d "$CERT_DIR" ]; then
    CERT_DIR="/etc/letsencrypt/live/${DOMAIN}-0001"
    if [ ! -d "$CERT_DIR" ]; then
        print_error "Could not find certificate directory for $DOMAIN"
        print_info "Tried: /etc/letsencrypt/live/$DOMAIN"
        print_info "Tried: /etc/letsencrypt/live/${DOMAIN}-0001"
        exit 1
    fi
fi

print_success "Found certificate directory: $CERT_DIR"

# Check if required files exist
if [ ! -f "$CERT_DIR/privkey.pem" ] || [ ! -f "$CERT_DIR/fullchain.pem" ]; then
    print_error "Required certificate files not found in $CERT_DIR"
    exit 1
fi

# Combine privkey and fullchain into HAProxy pem file
HAPROXY_PEM="/etc/haproxy/${DOMAIN}.pem"

print_info "Creating HAProxy PEM file: $HAPROXY_PEM"
sudo cat "$CERT_DIR/privkey.pem" "$CERT_DIR/fullchain.pem" | sudo tee "$HAPROXY_PEM" > /dev/null

if [ $? -eq 0 ]; then
    print_success "HAProxy PEM file created successfully at $HAPROXY_PEM"
else
    print_error "Failed to create HAProxy PEM file"
    exit 1
fi

# Set proper permissions
sudo chmod 600 "$HAPROXY_PEM"

# Restart HAProxy
print_info "Restarting HAProxy..."
sudo systemctl restart haproxy

if [ $? -eq 0 ]; then
    print_success "HAProxy restarted successfully"
else
    print_error "Failed to restart HAProxy"
    exit 1
fi

print_success "✨ Certificate generation and setup completed for $DOMAIN!"
print_info "Certificate files are in: $CERT_DIR"
print_info "HAProxy PEM file: $HAPROXY_PEM"

# Nginx will be started automatically by the EXIT trap
