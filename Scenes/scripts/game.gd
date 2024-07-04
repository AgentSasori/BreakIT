extends Node2D

# Export vars
@export var balls : int = 0

# Constants
var SPRITE_MULITPLIER : int = 2
const version = 0.3

# Simple Vars
var debug : bool = true
var brick_size : Vector2 = Vector2(32 * SPRITE_MULITPLIER, 16 * SPRITE_MULITPLIER)
var brick_nodes = []
var logonode
var dummy = 0
var fps : int = 0
var score : int = 0
var ballspeed : int = 0
var state : int = 0
var player_level : int = 1
var bricks : int = 0
var highscore : int = 0
var volume : float = 0.5
var player_can_rotate : bool = false
var player

# Lists
var brick_list = [
	preload("res://Scenes/brick_grey.tscn"), 
	preload("res://Scenes/brick_green.tscn"),
	preload("res://Scenes/brick_yellow.tscn"),
	preload("res://Scenes/brick_orange.tscn"),
	preload("res://Scenes/brick_red.tscn")
	]
var bonus_brick_list = [
	preload("res://Scenes/brick_extraball.tscn"),
	preload("res://Scenes/brick_speedup.tscn"),
	preload("res://Scenes/brick_bomb.tscn"),
	preload("res://Scenes/brick_loot.tscn"),
	]

var credits = [
	"credits:game",
	"AgentSasori:coding",
	"zapsplat:music",
	"opengameart:graphics",
]

# Onready vars
@onready var BallsLabel = $Control/Balls
@onready var ScoreLabel = $Control/Score
@onready var LevelLabel = $Control/Level
@onready var FPSLabel = $Control/FPS
@onready var BallspeedLabel = $Control/Ballspeed
@onready var BricksLabel = $Control/Bricks
@onready var BonusLabel = $BonusText
@onready var HighscoreLabel = $Control/Highscore
@onready var BugsLabel = $Control/_BUGS
@onready var PlayerNode = preload("res://Scenes/player.tscn")
@onready var BallNode = preload("res://Scenes/ball.tscn")
@onready var LogoNode = preload("res://Scenes/logo.tscn")
@onready var GunNode = preload("res://Scenes/player_gun.tscn")
@onready var bullet = preload("res://Scenes/laserbeam.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to ball-signals
	$Ball.connect("ball_down", ball_down)
	$Ball.connect("score_up", score_up)
	$Ball.connect("bonus", bonus)
	#$Player.connect("game_over", game_over)
	#$Player.connect("game_paused", game_paused)
	#$Player.connect("spawn_bullet", spawn_bullet)
	BallsLabel.text = str(balls)
	
	# Set volume
	_on_bg_music_slider_value_changed(0.5)
	$Control/BGMusicSlider.value = 0.5
	_show_menu(true)
	$Music.play()

func spawn_bullet(pos_left, pos_right):
	var bullet_left = bullet.instantiate()
	var bullet_right = bullet.instantiate()	
	add_child(bullet_left)
	add_child(bullet_right)
	bullet_left.position = pos_left
	bullet_right.position = pos_right

func game_paused():
	$Control/Unpause.show()
	
func show_logo(_visible:bool = true):
	if _visible == true:
		if !logonode:
			logonode = LogoNode.instantiate()
			add_child(logonode)
			logonode.position = position
		else:
			print("Logo already exists")
	else:
		if logonode != null:
			logonode.queue_free()
	
func brick_destroyed(bricknode):
	# decrease bricks left
	bricks -= 1
	# delete the brick in the list
	brick_nodes.erase(bricknode)
	# destroy it
	#bricknode.queue_free()
	#print("Brick has been destroyed and will be erased from list: ", bricknode)

func update_stats():
	if state > 0:
		BallsLabel.show()
		BallsLabel.text = "Balls left: " + str(balls)
		ScoreLabel.show()
		ScoreLabel.text = "Score: " + str(score)
		LevelLabel.show()
		LevelLabel.text = "Level: " + str(player_level)
		BallspeedLabel.show()
		BallspeedLabel.text = "Speed: " + str(ballspeed)
		BricksLabel.show()
		BricksLabel.text = "Bricks: " + str(bricks)
		FPSLabel.show()
		FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
		HighscoreLabel.show()
		HighscoreLabel.text = "Highest: " + str(highscore)

func game_over():
	print("GAME OVER. Score: ", score)
	state = 0
	$Ball.speed = 300
	_show_menu(true)
	# delete player
	player.queue_free()
	# delete all bricks 
	print("Deleting Nodes: ", brick_nodes.size())
	for b in brick_nodes:
		if b != null:
			b.queue_free()
	brick_nodes.clear()

func reset_game_stats():
	print("Score: ", score, " of total bricks: ", brick_nodes.size())
	state = 0
	score = 0
	bricks = 0
	balls = 3
	state = 0
	highscore = 0
	player_level = 1

func _new_highscore():
	print("NEW HIGHSCORE")
	BonusLabel.text = "NEW HIGHSCORE"
	BonusLabel.show()
	highscore = score
	$FX_Highscore.show()
	$Control/Highscore.show()
	$Timer_Highscore.start()
	HighscoreLabel.text = "Highscore:" + str(highscore)

func ball_down():
	if balls > 0:
		balls -= 1
		update_stats()
	else:
		if score > highscore:
			_new_highscore()
		print("GAME OVER")
		BonusLabel.text = "GAME OVER"
		BonusLabel.show()
		$Timer.start()
		game_over()
		
func score_up():
	update_stats()
	if state > 0:
		score += player_level * ballspeed
		if brick_nodes.size() <= 0:
			BonusLabel.text = "LEVEL UP"
			BonusLabel.show()
			$Timer.start()
			create_bricks(50, 50, randi_range(2, 7), randi_range(7, 10))
			$Player.change_padel(player_level)
	
func bonus(type):
	print("BONUS: ", type)
	match type:
		"extraball":
			BonusLabel.text = "NEW BALL!"
			balls += 1
		"speedup":
			$Player.speed += $Player.accelerate
			BonusLabel.text = "PADEL SPEED UP"
		"bomb":
			BonusLabel.text = "BOOOM!"
			#print("Executing self-destruction on bricks: ", brick_nodes.size())
			var destroying = 0
			for b in brick_nodes:
				#if randi() % 2 == 0:
				print("SEND self-destruction to brick: ", b)
				# if node exists and is NOT in group of bonus-bricks because they dont have crack stages
				if b != null and not b.is_in_group("bonus"):
					b.hit() # 1000 = definitly destroyed :D
					destroying += 1
				else:
					print("ERROR! Node not exists!")
			print("Send selfdestroy to ", destroying, " of " , brick_nodes.size() , " bricks")
		"loot":
			BonusLabel.text = "LOOTBOX"
			player.enable_guns(true)
			
	#BonusLabel.transform.scale = 1.0
	BonusLabel.show()
	BonusLabel.modulate = Color(1,1,1)
	$Timer.start()
	update_stats()

func create_bricks(posx:int = 50, posy:int = 50, rows:int = 5, columns:int = 10):
	# set type/color of bricks randomly
	var randombrickno = randi_range(0, brick_list.size() - 1)
	var brick = brick_list[randombrickno]

	# set layout based on playerlevel
	var brick_cap = player_level * 15
	if brick_cap > 150:
		brick_cap = 150
	print("new playfield. width: ", columns, " height: ", rows, " brick cap: ", brick_cap)
	
	for x in columns:
		for y in rows:
			# randomize some "holes"
			if randi() % (rows * columns) > 3:
				var newbrick
				# randomize for a bonus brick
				if randi() % (rows * columns) == 0: # (rows * columns)
					newbrick = bonus_brick_list[randi_range(0, bonus_brick_list.size() - 1)].instantiate()
				else:
					newbrick = brick.instantiate()
					# For testing

				# duplicate / also instanciate the texture (atlas) for each sprite
				newbrick.get_node("Sprite2D").texture = newbrick.get_node("Sprite2D").texture.duplicate(DUPLICATE_SCRIPTS)
				# add new brick as an child of the main-scene
				add_child(newbrick)
				# add to the list of bricks
				brick_nodes.append(newbrick)
				#set position on screen
				newbrick.position.x = posx + x * brick_size.x
				newbrick.position.y = posy + y * brick_size.y
				# depending on the type/color of brick, increase the y-value for the atlas
				newbrick.set_brick_color(randombrickno) # THIS LIKE STOPS RUNNING SOMETIMES WHILE SPAWNING: NON EXISTING FUNCTION
				#newbrick.atlaspos.y = newbrick.spritesize.y * randombrickno
				bricks += 1 # counter for bricks
				if bricks >= brick_cap:
					break
	print("Bricks ready. Total bricks: ", brick_nodes.size())

func _show_menu(_visible:bool = true):
	if _visible:
		# the button
		$Control/Button.show()
		$Control/BGMusicSlider.show()
		BugsLabel.show()
		show_logo(true)
		$Control/Credits.show()
	else:
		$Control/Button.hide()
		# hide the music-stuff
		$Control/BGMusicSlider.hide()
		BugsLabel.hide()
		show_logo(false)
		$Control/Credits.hide()
	
func _on_button_pressed():
	# reset stats etc
	reset_game_stats()
	# spawn the player
	player = PlayerNode.instantiate()
	add_child(player)
	player.position = Vector2(400, 400)
	player.connect("game_over", game_over)
	player.connect("game_paused", game_paused)
	player.connect("spawn_bullet", spawn_bullet)	
	# create some bricks
	create_bricks(100, 100, randi_range(2, 7), randi_range(7, 10))
	# spawn a ball!
	$Ball.new_ball(player.global_position)

	# update the stats
	update_stats()
	state = 1
	# Show button and slider
	_show_menu(false)

func _on_timer_timeout():
	var bonustween = create_tween()
	bonustween.set_parallel(true)
	bonustween.tween_property(BonusLabel, "modulate:a", 0, 1)

func _on_timer_fps_timeout():
	update_stats()

func _on_music_finished():
	$Music.play()

func _on_timer_highscore_timeout():
	$FX_Highscore.hide()

func _on_unpause_pressed():
	$Control/Unpause.hide()
	get_tree().paused = false

func _on_bg_music_slider_value_changed(value):
	print("Volume changed to ", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db($Control/BGMusicSlider.value))

func _on_guns_toggled(toggled_on):
	print(toggled_on)
	PlayerNode.enable_guns(toggled_on)

func _on_timer_credits_timeout():
	$Control/Credits.text = credits.pick_random()
	
	
