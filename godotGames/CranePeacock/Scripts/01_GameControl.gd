extends Control

var players = ['CRANE', 'PEACOCK']
var pawns = []
var arena_size = 25

var gameStatus
var playerTurn
var positions = []

func _on_ExitButton_pressed():
	get_tree().change_scene("res://Scenes/00_MainControl.tscn")

func _ready():
	pawns = [$CranePawn, $PeacockPawn]
	startGame()

func startGame():
	gameStatus = 'WAITING_ROLL'
	playerTurn = 0 # Crane starts 
	positions = [0,0]
	pawns[0].set_global_position(pos2coord(positions[0]))
	pawns[1].set_global_position(pos2coord(positions[1]))
	turnStart()

func turnStart():
	$StatusLabel.text = 'It is %s\'s turn to play' % players[playerTurn]
	$ActionButton.text = 'Click to roll die'

func movePawn(steps):
	if positions[playerTurn] + steps < arena_size:
		$StatusLabel.text = '%s is moving now..' % players[playerTurn]
		for n in range(steps):			
			positions[playerTurn] += 1
			pawns[playerTurn].set_global_position(pos2coord(positions[playerTurn]))
			yield(get_tree().create_timer(0.5),"timeout")
	else:
		$StatusLabel.text = 'Cannot move; skipping turn!'
		yield(get_tree().create_timer(1.0),"timeout")
	if positions[playerTurn] == arena_size-1:
		$StatusLabel.text = 'Game over; %s won!' % players[playerTurn]
		$ActionButton.text = 'Click to restart'
		gameStatus = 'FINISHED'
	else:
		playerTurn = 1 - playerTurn
		turnStart()

func _on_ActionButton_pressed():
	if gameStatus == 'WAITING_ROLL':
		var steps = roll_die()
		yield(get_tree().create_timer(1.0),"timeout")
		movePawn(steps)
	elif gameStatus == 'FINISHED':
		startGame()
		
func roll_die():
	var roll = 1 + randi() % 6
	$StatusLabel.text = '%s rolled %d' % [players[playerTurn], roll]
	$ActionButton.text = '%d' % roll
	return roll

func pos2coord(pos):
	var x_offset = pos % 10
	x_offset = min(x_offset, 9 - x_offset)
	var y_offset = 4 - pos / 5
	var arenaPos = $ArenaRect.get_global_rect()
	var width = arenaPos.size[0]
	var height = arenaPos.size[1]
	var topLeft = [arenaPos.position[0] + width/2.0 - height/2.0, arenaPos.position[1]]
	var botRight = [arenaPos.end[0] - width/2.0 + height/2.0, arenaPos.end[1]]
	var x_size = (botRight[0] - topLeft[0])/5
	var y_size = (botRight[1] - topLeft[1])/5
	return Vector2(topLeft[0] + x_offset * x_size, topLeft[1] + y_offset * y_size)
