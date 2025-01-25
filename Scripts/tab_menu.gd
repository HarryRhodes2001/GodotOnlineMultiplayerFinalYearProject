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
	sync_player_IDs.rpc(playerID)
	print(playerID)
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

# When a user leaves, find their entry in the playerID array and remove it after hiding their
# leaderboard entry
func on_leave(playerName):
	print("Player name is: ", playerName)
	var ID = find_value(str(playerName))
	print(playerID)
	
	# Instead of removing the section entirely, move the players name and attributes up instead
	
	for i in range(0, noOfPlayers):
		print("PlayerID = ", playerID[i][0], playerID[i][1])
		if playerID[i][0] == ID and i != noOfPlayers-1:
			playerID[i][0] = playerID[i+1][0]
			playerID[i][1] = playerID[i+1][1]
			var nodeName = "PlayerName" + str(i+1)
			var nodeName2 = "PlayerName" + str(i+2)
			var playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
			var playerNode2 = $VBoxContainer/GridContainer.get_node(nodeName2)
			playerNode.text = playerNode2.text
			nodeName = "PlayerKills" + str(i+1)
			nodeName2 = "PlayerKills" + str(i+2)
			playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
			playerNode2 = $VBoxContainer/GridContainer.get_node(nodeName2)
			playerNode.text = playerNode2.text
			nodeName = "PlayerDeaths" + str(i+1)
			nodeName2 = "PlayerDeaths" + str(i+2)
			playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
			playerNode2 = $VBoxContainer/GridContainer.get_node(nodeName2)
			playerNode.text = playerNode2.text
		elif i == noOfPlayers-1:
			var nodeName = "PlayerName" + str(i+1)
			var playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
			playerNode.visible = false
			nodeName = "PlayerKills" + str(i+1)
			playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
			playerNode.visible = false
			nodeName = "PlayerDeaths" + str(i+1)
			playerNode = $VBoxContainer/GridContainer.get_node(nodeName)
			playerNode.visible = false
			noOfPlayers -= 1
			playerID.erase(playerID[i])
			print(playerID)

# Set the number of deaths for a killed player as well as set the number of kills
# for the player who had killed them
func set_deaths(playerName, deaths, att_name, kills):
	var nodeName
	if playerName == "1":
		print("Server died")
		nodeName = "PlayerDeaths" + str(1)
	else:
		print("Peer died")
		var id = find_value(playerName)
		nodeName = "PlayerDeaths" + str(id)
	
	print(nodeName, "   ", playerName, "   ", deaths, "   ", att_name, "   ", kills)
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

# Find the corresponding "simplified" ID value of a players full ID
func find_value(playerName):
	for row in range(playerID.size()):
			for col in range(playerID[row].size()):
				if str(playerID[row][col]) == playerName:
					print(playerID)
					print(playerID[row][col])
					print(playerID[row][col-1])
					return playerID[row][col-1]

@rpc ("any_peer")
func sync_player_IDs(list):
	playerID = list
