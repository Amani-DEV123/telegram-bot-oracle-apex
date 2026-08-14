# Telegram Bot Integration with Oracle APEX

## Project Overview

This is an experimental Telegram Bot project integrated with Oracle APEX using the Telegram Bot API and PL/SQL.

The project demonstrates how Oracle APEX can communicate with Telegram, receive messages, process JSON data, and handle user interactions.

## Current Status

The bot currently provides multiple options for users.

**Currently implemented:**

* **Option 1: Orders** — Fully functional

**Planned:**

* Other options will be implemented in future development.

## Technologies Used

* Oracle APEX
* Oracle Database
* PL/SQL
* Telegram Bot API
* REST API
* JSON
* APEX_WEB_SERVICE
* APEX_JSON
* DBMS_SCHEDULER

## How It Works

1. The user interacts with the Telegram Bot.
2. Oracle APEX communicates with the Telegram Bot API.
3. The system receives and processes Telegram updates.
4. The JSON response is parsed using `APEX_JSON`.
5. The selected option is processed using PL/SQL.
6. The system stores the latest processed `update_id`.
7. A scheduled database job checks for new Telegram messages.

## Main Components

### CHECK_TELEGRAM_MESSAGES

The main PL/SQL procedure responsible for:

* Retrieving new Telegram updates.
* Parsing the JSON response.
* Extracting the `update_id`.
* Reading message information.
* Processing user selections.
* Updating the latest processed update ID.

### TELEGRAM_BOT_CONTROL

A control table used to store the latest processed Telegram `update_id`.

This helps prevent the same Telegram message from being processed multiple times.

## Telegram API

The project uses the Telegram Bot API `getUpdates` method to retrieve new messages.

Example response:

```json
{
  "ok": true,
  "result": [
    {
      "update_id": 126,
      "message": {
        "text": "Hello"
      }
    }
  ]
}
```

## JSON Processing

Oracle APEX `APEX_JSON` is used to parse and extract data from the Telegram response.

Example:

```sql
apex_json.parse(l_response);

l_count := apex_json.get_count('result');
```

The system then processes each update:

```sql
FOR i IN 1 .. l_count LOOP
    l_update_id := apex_json.get_number(
        p_path => 'result[%d].update_id',
        p0     => i
    );
END LOOP;
```

## Security

The Telegram Bot Token should never be committed to GitHub.

Use a secure configuration method or replace the token with a placeholder:

```sql
l_token CONSTANT VARCHAR2(200) := 'YOUR_TELEGRAM_BOT_TOKEN';
```

## Project Goal

The goal of this experimental project is to explore the integration between Telegram and Oracle APEX using REST APIs, PL/SQL, and JSON processing.

## Future Improvements

* Implement additional Telegram menu options.
* Add more functionality to the Orders option.
* Send messages from Oracle APEX to Telegram.
* Add interactive Telegram buttons.
* Store Telegram users and conversations.
* Add more Telegram commands.
* Connect Telegram interactions with Oracle database data.
