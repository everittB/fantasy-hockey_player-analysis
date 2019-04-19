import urllib.request
import json

# Requests data using the NHL.com API
def getFeed(req):

    nhl_api_base = "https://statsapi.web.nhl.com/api/v1/"
    url = nhl_api_base + req
    request = urllib.request.Request(url)
    response = urllib.request.urlopen(request)
    return json.loads(response.read().decode())

def getTeams():

    teams = getFeed("teams").get("teams")

    # Create team list
    team_ids = []
    team_data = open("./data/teams.txt", "w")
    team_data.write("team_id,team_name \n")

    # Get each team name and ID
    for team in teams:
        team_id = team.get("id")

        team_data.write(str(team_id) + "," + team.get("name") + "\n")
        team_ids.append(team_id)

    team_data.close()
    return team_ids

def getPlayers(team_ids):

    player_ids = []
    player_data = open("./data/players.txt", "w")
    player_data.write("playerID,team_id,fullName,posType,position \n")

    # Get id, fullName, positionType, and Position for every player on each teams roster
    for team in team_ids:
        roster = getFeed("teams/" + str(team) + "/roster" ).get("roster")
        for idx in range(len(roster)):
            player_id = roster[idx].get("person").get("id")

            player_data.write(str(player_id) + "," + str(team) + ","
                              + roster[idx].get("person").get("fullName") + ","
                              + roster[idx].get("position").get("type") + ","
                              + roster[idx].get("position").get("abbreviation") + "\n"
                             )

            player_ids.append(player_id)

    player_data.close()
    return player_ids

def getPlayerStats(player_ids):

    # Create file for skaters statistics
    skaters_stats = open("./data/skaters_stats.txt", "w")
    skaters_stats.write("playerID,season,games,timeOnIce,points,goals,assists,shots \n")

    # Create file for goalie statistics
    goalie_stats = open("./data/goalie_stats.txt", "w")
    goalie_stats.write("playerID,season,games,wins,losses,ot_losses,shutouts \n")

    for player in player_ids:

        # Request player info
        player_stats = getFeed("people/" + str(player) + "?hydrate=stats(splits=yearByYear)").get("people")[0]

        # Check to see of the player is a goalie
        if player_stats.get("primaryPosition").get("type") != "Goalie":

            player_stats = player_stats.get("stats")[0].get("splits")

            # Only get NHL sesason stats
            for idx in range(len(player_stats)):
                if player_stats[idx].get("league").get("name") == "National Hockey League":
                    skaters_stats.write(str(player) + "," +
                                       str(player_stats[idx].get("season")) + "," +
                                       str(player_stats[idx].get("stat").get("games")) + "," +
                                       str(player_stats[idx].get("stat").get("timeOnIce")) + "," +
                                       str(player_stats[idx].get("stat").get("points")) + "," +
                                       str(player_stats[idx].get("stat").get("goals")) + "," +
                                       str(player_stats[idx].get("stat").get("assists")) + "," +
                                       str(player_stats[idx].get("stat").get("shots")) + "\n"
                    )

        # Get goalie statistics
        else:

            player_stats = player_stats["stats"][0]["splits"]

            # Only get NHL sesason stats
            for idx in range(len(player_stats)):
                if player_stats[idx].get("league").get("name") == "National Hockey League":
                    goalie_stats.write(str(player) + "," +
                                       str(player_stats[idx].get("season")) + "," +
                                       str(player_stats[idx].get("stat").get("games")) + "," +
                                       str(player_stats[idx].get("stat").get("wins")) + "," +
                                       str(player_stats[idx].get("stat").get("losses")) + "," +
                                       str(player_stats[idx].get("stat").get("ot_losses")) + "," +
                                       str(player_stats[idx].get("stat").get("shutouts")) + "\n"
                    )

    skaters_stats.close()
    goalie_stats.close()

def main():
    print("Getting teams")
    teams = getTeams()
    print("Getting rosters")
    players = getPlayers(teams)
    print("Getting player statistics")
    getPlayerStats(players)

if __name__ == '__main__':
    main()
