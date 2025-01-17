extends Control

var noOfPlayers = 0
var playerID = []

# If the user has just pressed the tab button, show the tab button
# Once the button is release, hide this menu
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("scores"):
		visible = true
	
	if event.is_action_released("scores"):
		visible = false

# When a user joins, add the players ID to the tab menu and make those sections visible
# This function uses concatinated stings to find the path of the required node to update
# The multiplayer synchronizer syncs the variables when users join
func on_join(playerName):
	noOfPlayers += 1
	print(noOfPlayers)
	playerID.append([noOfPlayers, playerName])
	var nodeName = "PlayerName" + str(noOfPlayers)
	var playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
	playerNode.visible = true
	playerNode.text = "                     Player " + str(playerName)
	nodeName = "PlayerKills" + str(noOfPlayers)
	playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
	playerNode.visible = true
	nodeName = "PlayerDeaths" + str(noOfPlayers)
	playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
	playerNode.visible = true

func set_deaths(playerName, deaths, att_name, kills):
	var nodeName
	if playerName == "1":
		nodeName = "PlayerDeaths" + str(1)
	else:
		var id = find_value(playerName)
		nodeName = "PlayerDeaths" + str(id)
	var playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
	print(playerNode)
	playerNode.text = str(deaths)
	
	if att_name == "1":
		nodeName = "PlayerKills" + str(1)
	else:
		var id = find_value(att_name)
		nodeName = "PlayerKills" + str(id)
	playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
	print(playerNode)
	playerNode.text = str(kills)

func find_value(playerName):
	for row in range(playerID.size()):
			for col in range(playerID[row].size()):
				if str(playerID[row][col]) == playerName:
					return playerID[row][col-1]
