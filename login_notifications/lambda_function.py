from __future__ import print_function
import os
import jsonpickle
import requests
import json
import re

def lambda_handler(event, context):
    # Send post authentication data to Cloudwatch logs
    print ('## ENVIRONMENT VARIABLES\r' + jsonpickle.encode(dict(**os.environ)))
    print ('## EVENT\r' + jsonpickle.encode(event))
    print ('## CONTEXT\r' + jsonpickle.encode(context))

    print ("Authentication successful")
    print ("Trigger function =", event['triggerSource'])
    print ("User pool = ", event['userPoolId'])
    print ("App client ID = ", event['callerContext']['clientId'])
    print ("User ID = ", event['userName'])
    
    
    # Send Telegram message
    bot_token = os.getenv('APP_TELEGRAM_BOT_TOKEN')
    chat_id = os.getenv('APP_TELEGRAM_CHAT_ID')
    
    if bot_token and chat_id:
        try:
            url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
            user = event['request']['userAttributes']
            user_name = escape_markdown(user['name'])
            user_email = escape_markdown(user['email'])
            site = escape_markdown('onsjabulani.co.za')
            message = f"🏘 __{site}__ Notification: '*{user_name}*' logged in ||Email {user_email}||"
            payload = json.dumps({
                "chat_id": chat_id,
                "text": message,
                "parse_mode": "MarkdownV2",
                "disable_notification": False
            })
            headers = {
                'Content-Type': 'application/json'
            }
            # Lambda needs to return in 5 seconds, thus time-out in 4
            response = requests.request("POST", url, headers=headers, data=payload, timeout=4)
            print (response.text)
        except Exception as e:
            print ("Error sending POST to Telegram API", exc_info=1)

    # Return to Amazon Cognito
    return event
  


def escape_markdown(text: str, version: int = 2, entity_type: str = None) -> str:
    """Helper function to escape telegram markup symbols.
    Args:
        text (:obj:`str`): The text.
        version (:obj:`int` | :obj:`str`): Use to specify the version of telegrams Markdown.
            Either ``1`` or ``2``. Defaults to ``2``.
        entity_type (:obj:`str`, optional): For the entity types
            :tg-const:`telegram.MessageEntity.PRE`, :tg-const:`telegram.MessageEntity.CODE` and
            the link part of :tg-const:`telegram.MessageEntity.TEXT_LINK`, only certain characters
            need to be escaped in :tg-const:`telegram.constants.ParseMode.MARKDOWN_V2`.
            See the official API documentation for details. Only valid in combination with
            ``version=2``, will be ignored else.
    """
    if int(version) == 1:
        escape_chars = r"_*`["
    elif int(version) == 2:
        if entity_type in ["pre", "code"]:
            escape_chars = r"\`"
        elif entity_type == "text_link":
            escape_chars = r"\)"
        else:
            escape_chars = r"\_*[]()~`>#+-=|{}.!"
    else:
        raise ValueError("Markdown version must be either 1 or 2!")

    return re.sub(f"([{re.escape(escape_chars)}])", r"\\\1", text)