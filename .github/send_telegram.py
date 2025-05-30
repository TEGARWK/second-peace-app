import os
import requests
from datetime import datetime

def send_telegram_message(token, chat_id, file_path, message):
    url = f"https://api.telegram.org/bot{token}/sendDocument"
    try:
        with open(file_path, 'rb') as f:
            files = {'document': f}
            data = {
                'chat_id': chat_id,
                'caption': message,
                'parse_mode': 'Markdown'  # opsional, jika kamu pakai Markdown di caption
            }
            response = requests.post(url, files=files, data=data)
            print(response.json())
            return response
    except FileNotFoundError:
        print(f"❌ APK file not found: {file_path}")
        exit(1)


telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
chat_id = os.getenv('TELEGRAM_CHAT_ID')
version_name = os.getenv('VERSION_NAME')
file_path = f'build/app/outputs/flutter-apk/app-release-{version_name}.apk'

repository = os.getenv('GITHUB_REPOSITORY')
commit_sha = os.getenv('GITHUB_SHA')
commit_message = os.getenv('GITHUB_COMMIT_MESSAGE')
commit_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

message = f"Repository: {repository}\nCommit: {commit_sha}\nMessage: {commit_message}\nDate: {commit_date}\nVersion: {version_name}"

send_telegram_message(telegram_token, chat_id, file_path, message)