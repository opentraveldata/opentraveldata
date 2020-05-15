List of official [Twitter](http://www.twitter.com) accounts belonging to travel players with their corresponding official [IATA code](https://www.iata.org/en/services/codes/):
- 2 letters airline designator code for airlines, airline alliances or Global Distribution Systems
- 3 letters location identifier for airports (see [opentraveldata/data/iata](https://github.com/opentraveldata/opentraveldata/tree/master/data/IATA)

Official means:
- a [verified Twitter account](https://help.twitter.com/fr/managing-your-account/about-twitter-verified-accounts)
- or a twitter account considered as official (when no verified account exists) when "official" is mentioned in the Twitter account description, when the number of followers is considered as realistic and relevant

The data file stored in this directory (travel_players_twitter_accounts.csv) corresponds to manually curated data.

Format of the csv file
----------------------

| Field             | Description                        | Remarks                                 |
|:-----------------:|:----------------------------------:|:---------------------------------------:|
| twitter_account   | Twitter account (without the @)    | a tarvel player can get several accounts|
| account_type      | Type of travel player              | airline, airline_alliance, airport      |
| IATA_code         | Travel player IATA code            | 2 letters for airline, 3 for airport    |


