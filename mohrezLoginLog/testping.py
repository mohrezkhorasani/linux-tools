import requests

# ---------- تنظیمات ----------
API_URL = "https://telbot.hekmateislami.com/madeline/send.php"
API_TOKEN = "2H7xK9pQmR4vT8wYzB6nL3jF5dS1gA0eC2uI7oP9kM4xR6tV8wZ"
PEER = "-1003492895671"
REPLY_TO = "60"

# ---------- داده‌های ارسالی ----------
payload = {
    "token": API_TOKEN,
    "peer": PEER,
    "text": "🏓 **Ping** — تست سلامت API",
    "reply_to_msg_id": REPLY_TO,
    # delete ارسال نمی‌شود => null
}

try:
    response = requests.post(API_URL, data=payload, timeout=15)
    print("HTTP Status:", response.status_code)
    print("Response Body:", response.text)

    if response.status_code == 200:
        print("✅ API سالم است و پیام ارسال شد.")
    else:
        print("❌ API پاسخ خطا داد. کد وضعیت و بدنه را بررسی کنید.")

except requests.exceptions.RequestException as e:
    print("❌ خطا در اتصال به API:", e)