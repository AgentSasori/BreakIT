extends CharacterBody2D

var START_SPEED = 300
var speed : int = 0
var acc : int = 50
var dir : Vector2
var spritesize = Vector2(8, 8)
var atlaspos = Vector2(144, 8)

var game_node
var bricks : int = 0

# Signals to Game-Node (game.gd)
signal score_up
signal ball_down
signal bonus

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the main game-node with the main-script
	game_node = get_node("../../Game")
	# Using signals for the ball
	#get_parent().connect("new_ball", _new_ball)
	#self.hide()
	new_ball()
	speed = 550

func new_ball(pos = Vector2(400, 400)):
	#position = game_node.get_node("Player").position # (100, 400)
	position = pos
	#position.y = randi_range(400, 500)
	dir.x = randf_range(-1, 1) # [-1,1].pick_random() #
	dir.y = -1 #[-1,1].pick_random() # randf_range(-1, 1) # 
	dir.normalized()
	speed = START_SPEED * game_node.player_level
	switch_ball(0)
	self.show()
	$Timer.start()

func _physics_process(delta):
	var collision = move_and_collide(dir * speed * delta)
		
	if collision:
		var collider = collision.get_collider()
		dir = dir.bounce(collision.get_normal())
		# print(collider.get_children())
				
		if collider.is_in_group("player"):
			pass
			
		if collider == $"../Floor" and game_node.state > 0:
			self.hide()
			new_ball()
			emit_signal("ball_down")

		if collider.is_in_group("brick"):#
			# get no of spawned bricks
			if game_node != null:
				bricks = game_node.bricks
			
			if collider.is_in_group("bomb"):
				# Send signal to game
				emit_signal("bonus", "bomb")
				# load the particleeffect
				var explosion = preload("res://Scenes/explosion.tscn").instantiate()
				# child it to the main node
				game_node.add_child(explosion)
				# position to the brick
				explosion.position = collision.get_position()
				# emit particleeffects
				explosion.emitting = true
				# decrease no. of bricks in mainnode
				#game_node.bricks -= 1
				
			# check if it is a bonus item
			if collider.is_in_group("bonus"):
				if collider.is_in_group("extraball"):
					emit_signal("bonus", "extraball")
					
				if collider.is_in_group("speedup"):
					emit_signal("bonus", "speedup")
					
				if collider.is_in_group("loot"):
					emit_signal("bonus", "loot")
					
				#if collider.is_in_group("bomb"):
					#emit_signal("bonus", "bomb")
					## load particle effect, add to main node and emit it
					#var explosion = preload("res://Scenes/explosion.tscn").instantiate()
					#game_node.add_child(explosion)
					#explosion.position = collision.get_position()
					#explosion.emitting = true
					
				$AudioBonus.play()
				collider.queue_free()
				game_node.bricks -= 1
			else:
				collider.hit()
				
			# Spawn and start the hit-particleeffect
			var destruction = preload("res://Scenes/brick_destruction.tscn").instantiate()
			game_node.add_child(destruction)
			destruction.position = collision.get_position()
			destruction.emitting = true
			# Score up (with a signal)
			emit_signal("score_up")
			# Play a sound
			$AudioBrick.play()
			# update stats
			game_node.update_stats()
			
func switch_ball(activeball):
	var spacebetween = 8
	# Change color of the ball in the atlas
	var rect = Rect2(atlaspos.x, atlaspos.y + activeball * (spacebetween + spritesize.y), spritesize.x, spritesize.y)
	$Sprite2D.texture.region = rect
	$CPUParticles2D2.emitting = true

func _on_timer_timeout():
	# Speed up the ball
	if speed < 2000:
		speed += acc
		# show some particles!
		$CPUParticles2D.emitting = true
		# update label in main scene
		game_node.ballspeed = speed
		# Switch the ball-sprite depending on its speed
		match speed:
			300: switch_ball(1)
			600: switch_ball(2)
			900: switch_ball(3)
			1200: switch_ball(4)
			1500: switch_ball(5)


