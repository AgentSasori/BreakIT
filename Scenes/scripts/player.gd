extends CharacterBody2D

# Export Vars
@export var speed : int  = 30000
@export var jump_impulse : int  = 600
@export var gravity : int = -2000
@export var accelerate : int = 2000

# Signals to the main (Game.gd)
signal game_over
signal game_paused
signal spawn_bullet

var direction_x : int = 0
var spritesize = Vector2(32, 8)
var atlaspos = Vector2(64, 7)
var max_padel_no = 6
var BackgroundNode
var paused : bool = false
var can_fire : bool = false
var guns_enabled : bool = false
var _is_on_wall :bool = false
var player_can_rotate : bool = true

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	BackgroundNode = get_parent().get_node("Background")
	ajust_padel_collision()

func ajust_padel_collision() -> void:
	#$CollisionShape2D.shape.extends = Vector2(32, 9)
	pass
	
func enable_guns(yes = false):
	if yes:
		$Sprite2D_Left_Gun.show()
		$Sprite2D3_Right_Gun.show()
	else:
		$Sprite2D_Left_Gun.hide()
		$Sprite2D3_Right_Gun.hide()
	guns_enabled = yes
	
func change_padel(no):
	var spacebetween = 8
	# Change color of the ball in the atlas
	if no < 0 or no >= max_padel_no:
		no = 1
		
	var rect = Rect2(atlaspos.x, atlaspos.y + no * (spacebetween + spritesize.y), spritesize.x, spritesize.y)
	$Sprite2D.texture.region = rect 
	speed += accelerate
	
func _spawn_bullet():
	if guns_enabled:
		emit_signal("spawn_bullet", $MarkerLeft.global_position, $MarkerRight.global_position)
		can_fire = false
		$Timer_Guns.start()
		
func handle_input(delta):
	direction_x = 0
	if Input.is_action_pressed("ui_left"):
		direction_x -= 1
		if _is_on_wall == false:
			BackgroundNode.position.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction_x += 1
		if _is_on_wall == false:
			BackgroundNode.position.x += 1
	if Input.is_action_pressed("ui_q") and player_can_rotate:
		rotation = 35
	if Input.is_action_pressed("ui_e") and player_can_rotate:
		rotation = -35
	if is_on_floor() && Input.is_action_pressed("ui_select"):
		velocity.y = -jump_impulse
	if Input.is_action_just_released("ui_pause"):
		emit_signal("game_paused")
		get_tree().paused = true
	if Input.is_action_just_pressed("ui_fire"):
		if can_fire and guns_enabled:
			_spawn_bullet()
	velocity.x = direction_x * delta * speed

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func _physics_process(delta):
	if Input.is_action_just_released("ui_cancel"):
		emit_signal("game_over")
	handle_input(delta)
	apply_gravity(delta)
	move_and_slide()

func _on_timer_guns_timeout():
	can_fire = true

func _on_area_2d_body_entered():
	_is_on_wall = true

func _on_area_2d_body_exited():
	_is_on_wall = false
