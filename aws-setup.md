# Hướng dẫn Triển khai Website lên AWS với SSL

## 🎯 Mục tiêu
Triển khai trang web `index.html` lên AWS EC2 với domain `demo.yez.vn` và SSL certificate.

## 📋 Yêu cầu Trước khi Bắt đầu

### 1. AWS Account
- Tài khoản AWS với quyền truy cập EC2
- Key pair để SSH vào server

### 2. Domain Configuration
- Domain `demo.yez.vn` đã được đăng ký
- Quyền quản lý DNS records

## 🚀 Bước 1: Tạo EC2 Instance

### 1.1 Launch EC2 Instance
```bash
# Thông số khuyến nghị:
- Instance Type: t3.micro (Free tier) hoặc t3.small
- OS: Ubuntu 22.04 LTS
- Storage: 8GB GP2
- Security Group: Mở ports 22, 80, 443
```

### 1.2 Security Group Configuration
```
Inbound Rules:
- SSH (22): 0.0.0.0/0
- HTTP (80): 0.0.0.0/0
- HTTPS (443): 0.0.0.0/0
```

## 🌐 Bước 2: Cấu hình DNS

### 2.1 Point Domain đến EC2
```bash
# Trong DNS provider của bạn, thêm A record:
Type: A
Name: demo
Value: [EC2_PUBLIC_IP]
TTL: 300
```

### 2.2 Kiểm tra DNS Propagation
```bash
# Kiểm tra DNS đã propagate chưa
nslookup demo.yez.vn
dig demo.yez.vn
```

## 🔧 Bước 3: Kết nối và Triển khai

### 3.1 SSH vào EC2
```bash
ssh -i your-key.pem ubuntu@[EC2_PUBLIC_IP]
```

### 3.2 Upload Files
```bash
# Từ máy local, upload files lên EC2
scp -i your-key.pem index.html nginx.conf deploy.sh ubuntu@[EC2_PUBLIC_IP]:~/
```

### 3.3 Chạy Deploy Script
```bash
# Trên EC2 server
chmod +x deploy.sh
./deploy.sh
```

## 🔒 Bước 4: Cấu hình SSL

### 4.1 Manual SSL Setup (nếu script không hoạt động)
```bash
# Cài đặt Certbot
sudo apt install certbot python3-certbot-nginx

# Tạo SSL certificate
sudo certbot --nginx -d demo.yez.vn

# Test renewal
sudo certbot renew --dry-run
```

### 4.2 Auto-renewal Setup
```bash
# Thêm vào crontab
sudo crontab -e
# Thêm dòng: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Bước 5: Monitoring và Maintenance

### 5.1 Kiểm tra Status
```bash
# Nginx status
sudo systemctl status nginx

# SSL certificate status
sudo certbot certificates

# Website accessibility
curl -I https://demo.yez.vn
```

### 5.2 Log Files
```bash
# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# SSL renewal logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

## 🔄 Bước 6: Cập nhật Website

### 6.1 Manual Update
```bash
# Upload file mới
scp -i your-key.pem index.html ubuntu@[EC2_PUBLIC_IP]:~/

# Copy lên web directory
sudo cp ~/index.html /var/www/demo.yez.vn/
sudo chown www-data:www-data /var/www/demo.yez.vn/index.html
```

### 6.2 Automated Deployment (Optional)
```bash
# Tạo script update
cat > update.sh << 'EOF'
#!/bin/bash
cd /var/www/demo.yez.vn
git pull origin master
sudo chown -R www-data:www-data .
sudo systemctl reload nginx
EOF

chmod +x update.sh
```

## 🛠️ Troubleshooting

### Common Issues:

1. **SSL Certificate Failed**
   ```bash
   # Kiểm tra DNS
   nslookup demo.yez.vn
   
   # Kiểm tra port 80
   sudo netstat -tlnp | grep :80
   ```

2. **Nginx Configuration Error**
   ```bash
   # Test config
   sudo nginx -t
   
   # Check syntax
   sudo nginx -T
   ```

3. **Permission Issues**
   ```bash
   # Fix permissions
   sudo chown -R www-data:www-data /var/www/demo.yez.vn
   sudo chmod -R 755 /var/www/demo.yez.vn
   ```

## 📈 Performance Optimization

### 1. Enable Gzip Compression
```nginx
# Đã có trong nginx.conf
gzip on;
gzip_types text/plain text/css application/javascript;
```

### 2. Browser Caching
```nginx
# Đã có trong nginx.conf
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. Security Headers
```nginx
# Đã có trong nginx.conf
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

## 💰 Cost Optimization

### 1. EC2 Instance
- Sử dụng t3.micro (Free tier) cho development
- T3.small cho production với traffic thấp

### 2. Storage
- GP2 EBS volume với size tối thiểu (8GB)

### 3. Data Transfer
- CloudFront CDN cho static content (optional)

## 🔐 Security Best Practices

1. **Regular Updates**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Firewall Configuration**
   ```bash
   sudo ufw enable
   sudo ufw allow ssh
   sudo ufw allow 'Nginx Full'
   ```

3. **SSL/TLS Configuration**
   - Sử dụng TLS 1.2+ only
   - Strong cipher suites
   - HSTS headers

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. DNS propagation
2. Security group rules
3. Nginx configuration
4. SSL certificate status
5. File permissions

---

**Lưu ý**: Đảm bảo backup dữ liệu trước khi thực hiện các thay đổi lớn. 