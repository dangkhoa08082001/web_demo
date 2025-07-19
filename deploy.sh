#!/bin/bash

# Deploy Script for demo.yez.vn on AWS
# Author: AI Assistant
# Date: $(date)

set -e  # Exit on any error

echo "🚀 Starting deployment for demo.yez.vn..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="demo.yez.vn"
WEB_ROOT="/var/www/$DOMAIN"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install -y nginx certbot python3-certbot-nginx git curl

# Create web directory
print_status "Creating web directory..."
sudo mkdir -p $WEB_ROOT
sudo chown -R $USER:$USER $WEB_ROOT

# Copy website files
print_status "Copying website files..."
cp index.html $WEB_ROOT/
sudo chown -R www-data:www-data $WEB_ROOT

# Setup Nginx configuration
print_status "Setting up Nginx configuration..."
sudo cp nginx.conf $NGINX_CONF

# Create symlink to enable site
sudo ln -sf $NGINX_CONF $NGINX_ENABLED

# Test Nginx configuration
print_status "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
print_status "Reloading Nginx..."
sudo systemctl reload nginx

# Setup SSL with Let's Encrypt
print_status "Setting up SSL certificate..."
if sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@yez.vn; then
    print_status "SSL certificate installed successfully!"
else
    print_warning "SSL certificate installation failed. Please check DNS settings."
    print_warning "Make sure domain $DOMAIN points to this server's IP address."
fi

# Setup automatic SSL renewal
print_status "Setting up automatic SSL renewal..."
sudo crontab -l 2>/dev/null | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | sudo crontab -

# Final Nginx reload
print_status "Final Nginx reload..."
sudo systemctl reload nginx

# Check if Nginx is running
if sudo systemctl is-active --quiet nginx; then
    print_status "Nginx is running successfully!"
else
    print_error "Nginx is not running. Please check the configuration."
    exit 1
fi

# Display final information
echo ""
print_status "Deployment completed successfully!"
echo ""
echo "🌐 Website URL: https://$DOMAIN"
echo "📁 Web root: $WEB_ROOT"
echo "⚙️  Nginx config: $NGINX_CONF"
echo ""
echo "🔧 Useful commands:"
echo "   sudo nginx -t                    # Test Nginx configuration"
echo "   sudo systemctl reload nginx      # Reload Nginx"
echo "   sudo systemctl status nginx      # Check Nginx status"
echo "   sudo certbot renew --dry-run     # Test SSL renewal"
echo ""
print_status "Your website is now live at https://$DOMAIN" 