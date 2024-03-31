import time
import telebot
import sys
import os
from auth import client

spreadsheet = client.open("Сообщения из бота")

BOT_TOKEN = os.environ.get("BOT_TOKEN")

if BOT_TOKEN is None:
    sys.exit(100)

bot = telebot.TeleBot(BOT_TOKEN)


def get_data_from_message(message: telebot.types.Message) -> list[str]:

    get_curr_date = lambda dt: time.strftime("%d.%m.%Y %H:%M:%S", time.localtime(dt))

    data = message.json
    user_data = data["from"]

    date = get_curr_date(data["date"])
    username = user_data["username"]
    first_name = user_data["first_name"]
    text = data["text"]

    return [date, username, first_name, text]


@bot.message_handler(commands=["start"])
def send_welcome(message):
    bot.reply_to(message, "Пожалуйста, напишите сообщение для склада")


@bot.message_handler(func=lambda msg: True)
def process_message(message):

    worksheet = spreadsheet.sheet1

    next_row = len(worksheet.get_all_values()) + 1
    message_data = get_data_from_message(message)
    worksheet.insert_row(message_data, next_row)
    print(message_data)
    bot.reply_to(message, "Ваше сообщение отправлено на склад")


if __name__ == "__main__":
    bot.infinity_polling()
