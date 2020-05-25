List of official [Twitter](http://www.twitter.com) accounts belonging to travel players with their corresponding official [IATA code](https://www.iata.org/en/services/codes/):
- 2 letters airline designator code for airlines, airline alliances or Global Distribution Systems
- 3 letters location identifier for airports (see [opentraveldata/data/iata](https://github.com/opentraveldata/opentraveldata/tree/master/data/IATA))

Official means:
- a [verified Twitter account](https://help.twitter.com/fr/managing-your-account/about-twitter-verified-accounts)
- or a twitter account considered as official (when no verified account exists) when "official" is mentioned in the Twitter account description, when the number of followers is considered as realistic and relevant

The data file stored in this directory (travel_players_twitter_accounts.csv) corresponds to manually curated data.

Format of the csv file
----------------------

| Field             | Description                            | Remarks                                 |
|:-----------------:|:--------------------------------------:|:---------------------------------------:|
| twitter_account   | Twitter account (without the @)        | a travel player can get several accounts|
| account_type      | Type of travel player                  | see list below                          |
| IATA_code         | Travel player IATA code, if applicable | 2 or 3 letters depending on the player  |


Legend
------

Different types of travel players:
- airline (e.g. Lufthansa)
- airline_alliance (e.g. Star Alliance, OneWorld)
- railway_company (e.g. SNCF, RenFe)
- public_transport_operator (e.g. RATP)
- airport (e.g. Heathrow Airport)
- airline_union (e.g. CGT Air France)
- airport_union (e.g. SNCTA Roissy CDG)
- authority (e.g. Eurocontrol)
- bus_company (e.g. Lignes d'Azur)
- city (e.g. Ville de Nice, France)
