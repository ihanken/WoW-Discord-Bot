# WoW-Discord-Bot

## Building the Bot

To build the bot, run `docker build -t wow-bot .` while in the base directory of the project.

## Running the Bot

To run the bot, first export the following three environment variables:

* `WOW_BOT_TOKEN`: The bot's token
* `WOW_API_TOKEN`: Your personal token for the WoW API
* `WARCRAFT_LOGS_API_TOKEN`: Your personal token for the Warcraft Logs API

When these are exported, run the command `docker run -dit -e WOW_BOT_TOKEN=$WOW_BOT_TOKEN -e WOW_API_TOKEN=$WOW_API_TOKEN -e WARCRAFT_LOGS_API_TOKEN=$WARCRAFT_LOGS_API_TOKEN wow-bot` to start the bot.

## Deploying the Bot

Dev deployments should occur on a push into the `develop` branch, while production deployments should occur on a push into the `master` branch.