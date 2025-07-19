# 🌐 Website Demo - demo.yez.vn

Trang web demo du lịch được triển khai trên AWS với SSL certificate.

## 📁 Cấu trúc Project

```
demo_ai/
├── index.html          # Trang web chính
├── nginx.conf          # Cấu hình Nginx
├── deploy.sh           # Script triển khai tự động
├── docker-compose.yml  # Docker Compose config
├── aws-setup.md        # Hướng dẫn chi tiết AWS
└── README.md           # File này
```

## 🚀 Triển khai Nhanh

### Phương pháp 1: Sử dụng Script (Khuyến nghị)

1. **Chuẩn bị AWS EC2**
   ```bash
   # Tạo EC2 instance Ubuntu 22.04
   # Mở ports: 22, 80, 443
   ```

2. **Upload files**
   ```bash
   scp -i your-key.pem index.html nginx.conf deploy.sh ubuntu@[EC2_IP]:~/
   ```

3. **Chạy deploy script**
   ```bash
   ssh -i your-key.pem ubuntu@[EC2_IP]
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Phương pháp 2: Sử dụng Docker

1. **Cài đặt Docker**
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose
   ```

2. **Chạy containers**
   ```bash
   docker-compose up -d
   ```

3. **Cấu hình SSL**
   ```bash
   docker-compose run --rm certbot
   ```

## 🔧 Cấu hình DNS

Thêm A record trong DNS provider:
```
Type: A
Name: demo
Value: [EC2_PUBLIC_IP]
TTL: 300
```

## 📊 Monitoring

### Kiểm tra Status
```bash
# Nginx status
sudo systemctl status nginx

# SSL certificate
sudo certbot certificates

# Website accessibility
curl -I https://demo.yez.vn
```

### Log Files
```bash
# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 🔄 Cập nhật Website

### Manual Update
```bash
# Upload file mới
scp -i your-key.pem index.html ubuntu@[EC2_IP]:~/

# Copy lên web directory
sudo cp ~/index.html /var/www/demo.yez.vn/
sudo chown www-data:www-data /var/www/demo.yez.vn/index.html
```

### Automated Update (Git)
```bash
# Trên server
cd /var/www/demo.yez.vn
git pull origin master
sudo systemctl reload nginx
```

## 🛠️ Troubleshooting

### SSL Issues
```bash
# Kiểm tra DNS
nslookup demo.yez.vn

# Test SSL renewal
sudo certbot renew --dry-run
```

### Nginx Issues
```bash
# Test configuration
sudo nginx -t

# Check syntax
sudo nginx -T
```

### Permission Issues
```bash
# Fix permissions
sudo chown -R www-data:www-data /var/www/demo.yez.vn
sudo chmod -R 755 /var/www/demo.yez.vn
```

## 🔐 Security Features

- ✅ SSL/TLS encryption
- ✅ HTTP to HTTPS redirect
- ✅ Security headers (HSTS, XSS Protection)
- ✅ Gzip compression
- ✅ Browser caching
- ✅ Hidden files protection

## 📈 Performance Features

- ✅ Gzip compression cho static files
- ✅ Browser caching (1 year cho static assets)
- ✅ Optimized Nginx configuration
- ✅ HTTP/2 support

## 💰 Cost Optimization

- **EC2**: t3.micro (Free tier) hoặc t3.small
- **Storage**: 8GB GP2 EBS volume
- **SSL**: Let's Encrypt (Free)
- **Domain**: demo.yez.vn

## 📞 Support

Nếu gặp vấn đề:

1. Kiểm tra DNS propagation
2. Verify Security Group rules
3. Check Nginx configuration
4. Review SSL certificate status
5. Confirm file permissions

## 🔗 Links

- 🌐 Website: https://demo.yez.vn
- 📚 Documentation: [aws-setup.md](aws-setup.md)
- 🐳 Docker: [docker-compose.yml](docker-compose.yml)

---

**Lưu ý**: Đảm bảo backup dữ liệu trước khi thực hiện các thay đổi lớn. 