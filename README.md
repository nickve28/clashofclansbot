# ClashOfClansSlackbot

A slack bot that integrates with several Clash of clan services. Made to make life easier for planning war attacks with your clanmates.

Please read through this file in order to configure this bot properly.

## Features

- Starting wars on clashcaller by issueing a !startwar command
- Reserve and attack targets on clashcaller
- Track (bad) donators, with a configurable margin and minimum donations, which slackbot will output every 12 hours.

## Requirements
- Know how to install erlang and elixir: http://elixir-lang.org/install.html
- Have a Slack group for your clan
- Have a slack bot integration made on slack
  -  go to [https://YOURSLACKGROUP.slack.com/apps/manage/custom-integrations]()
  - In here, go to bots and make one if you don't have it
  - Find the token of the bot and save it for later
- [Have a clash of clans api token](https://developer.clashofclans.com/#/account)
  - Make sure you configure your right IP address. If you don't know what to put, google how to find our your public IP address.
  - Copy this token for later as well
- You need to know your clantag in clash of clans

## Deploying the bot

Assuming you have configured elixir and completed the step from the requirements, you need to compile and run the bot. This can by running the following commands, in the folder containing the code.

```
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod SLACK_TOKEN={{slack_token}} CLASHAPI_TOKEN={{clashapi_token}} CLASHAPI_CLANTAG={{clashapi_clantag}} mix release
```

Replace the slack_token, clashapi_token and clashapi_clantag values accordingly.

The reason for this is since these tokens are sensitive data, so you should not put this in your configuration.

When this is done, run the following.
```
rel/clash_of_clans_slackbot/bin/clash_of_clans_slackbot start
```

## How to use the bot

The bot supports the following commands:
- !startwar SIZE "CLANNAME" "ENEMYCLANNAME"
  - starts the war for your clan.
  - Keep in mind that both names need double quotes, this is to differentiate between clan names containing spaces
  - Connects with clashcaller
  - Returns the war link, and saves it locally as well.
  - Example: !startwar 10 "Atomic Bullies" "Not your clan"
- !war
  - Gets the war link
  - Useful if you want direct control over clashcaller, for player performance for example.
  - Example: !war
- !reservations TARGET
  - Print reservations made for this target made on clashcaller
  - If no reservations are known, slackbot will note that
  - Example: !reservations 1
- !reserve TARGET PLAYERNAME
  - Reserves the target on clashcaller
  - Case insensitive
  - Example: !reserve 1 Nick
- !overview
  - Shows the overview of the war, showing the best attack registered per target
  - Example: !overview
- !overview NAME
  - Shows the overview of attacks made by this player
  - Example: !overview nick
- !unreserve TARGET NAME
  - Removes a reservation on a target
  - Example: !unreserve 3 nick
- !attack TARGET PLAYERNAME STARS
  - Sets the stars of the attack
  - Only works if the attack is reserved beforehand
  - Can be updated
  - Case insensitive
  - Example: !attack 1 Nick 3

  Anything regarding donations will be done itself.

## Known issues / gotcha's
- Player-links are not yet configurable in an easy way
- Playernames should not use emojis in clashcaller

## Trouble using?

Feel free to contact me if you can't get the bot working properly.
