#!/usr/bin/env/python
from argparse import ArgumentParser
from configparser import ConfigParser
from dataclasses import dataclass
from html import escape
from json import dumps as json_dumps
from pathlib import Path
from sys import stdin
from urllib.request import Request, urlopen


TELEGRAM_API_URL = "https://api.telegram.org"


@dataclass(frozen=True)
class Configuration:
    telegram_token: str
    telegram_chat_id: int


def get_config(path: Path) -> Configuration:
    c = ConfigParser()
    c.read(path)
    return Configuration(
        telegram_token=c.get('Telegram', 'Token'),
        telegram_chat_id=c.getint('Telegram', 'ChatId')
    )


def make_argument_parser() -> ArgumentParser:
    parser = ArgumentParser()
    parser.add_argument('-r', metavar='from-addr', type=str, dest='sender')
    parser.add_argument('-s', metavar='subject', type=str, dest='subject')
    parser.add_argument('-c', metavar='config-path', type=Path, dest='config')
    return parser


def format_message(sender: str, subject: str, message: str) -> str:
    r = escape(sender)
    s = escape(subject)
    m = escape(message)
    return f"From: <b>{r}</b>\nSubject: <b>{s}</b>\n\n{m}"


def send_message(
        token: str,
        chat_id: int,
        sender: str,
        subject: str,
        message: str
):
    url = f"{TELEGRAM_API_URL}/bot{token}/sendMessage"
    params = {
        'chat_id': chat_id,
        'text': format_message(sender, subject, message),
        'parse_mode': 'HTML',
        'disable_web_page_preview': 'true'
    }
    req = Request(url)
    req.add_header('Content-Type', 'application/json')
    urlopen(req, json_dumps(params).encode('utf-8'))


if __name__ == '__main__':
    parser = make_argument_parser()
    args = parser.parse_args()
    config = get_config(args.config)
    message = stdin.read()

    send_message(
        config.telegram_token,
        config.telegram_chat_id,
        args.sender,
        args.subject,
        message
    )
