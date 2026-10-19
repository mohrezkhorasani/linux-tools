# Linux Tools & Scripts | مجموعه ابزارها و اسکریپت‌های کاربردی لینوکس

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash%20%2F%20Shell-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-orange.svg)](https://www.kernel.org/)

مجموعه‌ای از ابزارها، اسکریپت‌های شل (Bash) و ابزارهای کاربردی سیستم‌عامل لینوکس برای مدیریت سرور، خودکارسازی تسک‌ها، شبکه و وب‌سرورها.

A curated collection of practical Linux automation scripts, system administration tools, and utilities maintained by **[@mohrezkhorasani](https://github.com/mohrezkhorasani)**.

---

## 📂 ساختار مخزن | Repository Structure

```text
.
├── LICENSE
├── README.md
└── mohrezCertBot/
    ├── mohrezCertBot.sh          # اسکریپت اصلی صدور و پیکربندی خودکار SSL برای HAProxy و Nginx
    ├── certs.lst                 # نگاشت دامنه‌ها و مسیر فایل‌های pem در HAProxy (ماسک‌شده با ***)
    ├── haproxy.cfg               # فایل پیکربندی کامل HAProxy با ALPN و SSL (ماسک‌شده با ***)
    ├── haproxy.cfgy              # نسخه کمکی/پیش‌نویس کانفیگ HAProxy
    └── sample_cert_bundle.pem    # ساختار نمونه فایل تجمیع‌شده PEM برای HAProxy
```

> [!NOTE]
> **امنیت اطلاعات (Security & Privacy):** تمام آدرس‌های IP خصوصی، شناسه‌های سرور، نام‌های دامنه و کلیدهای رمزنگاری در فایل‌های پیکربندی با `***` جایگزین شده‌اند تا هیچ‌گونه اطلاعات محرمانه‌ای نشت پیدا نکند.


---

## 🛠️ فهرست ابزارها | Available Tools

### 1. `mohrezCertBot` (Automated SSL for HAProxy & Nginx)

#### 📝 توضیحات (Persian):
اسکریپت `mohrezCertBot.sh` یک ابزار خودکار برای ایجاد و تمدید گواهینامه‌های SSL معتبر (Let's Encrypt) و ادغام آن با وب‌سرور **HAProxy** و **Nginx** است.

در سرورهایی که HAProxy به عنوان لود بالانسر یا پروکسی معکوس (Reverse Proxy) در لایه فرانت و Nginx در لایه بک‌اند قرار دارند، یا پورت ۸۰ توسط Nginx اشغال است:
1. **آزادسازی خودکار پورت ۸۰:** وب‌سرور Nginx به صورت موقت متوقف می‌شود تا Certbot بتواند از چالش پیش‌فرض HTTP-01 روی پورت ۸۰ استفاده کند (`--standalone`).
2. **تضمین راه‌اندازی مجدد Nginx:** با استفاده از مکانیزم `trap ... EXIT` در Bash، تحت هر شرایطی (موفقیت، بروز خطا، یا لغو با `Ctrl+C`) سرویس Nginx مجدداً استارت می‌شود تا دان‌تایم رخ ندهد.
3. **دریافت گواهینامه:** با اجرای غیرتعاملی `certbot certonly` گواهینامه دریافت می‌شود. همچنین دایرکتوری‌های تمدید Let's Encrypt (حتی پسوند `-0001`) به صورت خودکار شناسایی می‌شوند.
4. **ایجاد فایل ترکیبی برای HAProxy:** گواهینامه‌های Let's Encrypt به صورت دو فایل مجزای `privkey.pem` و `fullchain.pem` تولید می‌شوند؛ اما HAProxy نیازمند یک فایل تجمیع‌شده است. این اسکریپت هر دو را به صورت استاندارد در مسیر `/etc/haproxy/<domain>.pem` ترکیب می‌کند.
5. **تنظیم سطح دسترسی امن:** دسترسی فایل گواهینامه به `600` محدود می‌شود (`chmod 600`).
6. **اعمال روی HAProxy:** سرویس HAProxy ری‌استارت می‌شود تا گواهینامه جدید فوراً فعال گردد.

#### 📝 Description (English):
`mohrezCertBot.sh` automates the process of generating Let's Encrypt SSL certificates and configuring them for **HAProxy** while safely co-existing with **Nginx**:
- Temporarily frees port 80 by gracefully stopping Nginx.
- Uses Bash `trap ... EXIT` to ensure Nginx is reliably restarted on exit regardless of success, failure, or interruption.
- Runs Certbot standalone non-interactively to generate the certificates.
- Resolves certificate paths (including `-0001` renewal directory suffixes).
- Combines `privkey.pem` and `fullchain.pem` into HAProxy's expected unified `.pem` format at `/etc/haproxy/${DOMAIN}.pem`.
- Hardens file permissions (`chmod 600`).
- Restarts HAProxy to instantly load and serve the certificate over HTTPS.

---

### 🚀 راهنمای استفاده از `mohrezCertBot` | Usage Guide

#### نیازمندی‌ها | Prerequisites:
- سیستم‌عامل لینوکس (Ubuntu, Debian, CentOS, AlmaLinux, ...)
- دسترسی `sudo` / Root
- ابزارهای نصب شده: `certbot`, `haproxy`, `nginx`, `bash`

#### مراحل اجرا | Quick Start:

1. **دانلود یا کلون کردن مخزن:**
   ```bash
   git clone https://github.com/mohrezkhorasani/linux-tools.git
   cd linux-tools/mohrezCertBot
   ```

2. **اعطای دسترسی اجرایی به اسکریپت:**
   ```bash
   chmod +x mohrezCertBot.sh
   ```

3. **(اختیاری) تنظیم ایمیل در اسکریپت:**
   می‌توانید فایل `mohrezCertBot.sh` را ویرایش کرده و متغیر `EMAIL` را روی ایمیل خودتان قرار دهید:
   ```bash
   EMAIL="your-email@example.com"
   ```

4. **اجرای اسکریپت برای دامنه موردنظر:**
   ```bash
   sudo ./mohrezCertBot.sh yourdomain.com
   ```

#### نمونه خروجی | Example Output:
```text
[INFO] Stopping Nginx to free port 80...
[SUCCESS] Nginx stopped
[INFO] Starting Certbot generation for domain: yourdomain.com
[INFO] Running certbot to generate certificate...
...
[SUCCESS] Found certificate directory: /etc/letsencrypt/live/yourdomain.com
[INFO] Creating HAProxy PEM file: /etc/haproxy/yourdomain.com.pem
[SUCCESS] HAProxy PEM file created successfully at /etc/haproxy/yourdomain.com.pem
[INFO] Restarting HAProxy...
[SUCCESS] HAProxy restarted successfully
[SUCCESS] ✨ Certificate generation and setup completed for yourdomain.com!
[INFO] Certificate files are in: /etc/letsencrypt/live/yourdomain.com
[INFO] HAProxy PEM file: /etc/haproxy/yourdomain.com.pem
[INFO] Starting Nginx again...
[SUCCESS] Nginx started successfully
```

---

### ⚙️ کانفیگ نمونه HAProxy | HAProxy Configuration Sample

در فایل `/etc/haproxy/haproxy.cfg` می‌توانید فرانت‌اند خود را به صورت زیر تنظیم کنید:

```haproxy
frontend https_front
    bind *:443 ssl crt /etc/haproxy/ alpn h2,http/1.1
    mode http
    
    use_backend app_backend if { ssl_fc_sni -i yourdomain.com }
    default_backend app_backend

backend app_backend
    mode http
    server srv1 127.0.0.1:8080 check
```

---

## ➕ افزودن ابزارهای جدید | Contributing & Adding New Tools

این مخزن به مرور زمان با ابزارها و اسکریپت‌های کاربردی بیشتری در حوزه لینوکس توسعه داده خواهد شد. برای افزودن ابزارهای جدید:
1. پوشه یا فایلی با نام مشخص برای ابزار در این مخزن قرار دهید.
2. دسترسی‌های لازم و `#!/bin/bash` را در ابتدای اسکریپت‌ها رعایت کنید.
3. توضیحات، نحوه اجرا و پارامترهای ورودی را به فایل `README.md` اضافه کنید.

---

## 📄 لایسنس | License
این پروژه تحت مجوز [MIT](LICENSE) منتشر شده است.
