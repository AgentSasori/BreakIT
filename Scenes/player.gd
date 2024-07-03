extends CharacterBody2D


@export var speed : int  = 30000
@export var jump_impulse : int  = 600
@export var gravity : int = -2000
@export var friction : int = 1500

var direction_x : int = 0

func handle_input(delta):
	direction_x = 0
	if Input.is_action_pressed("ui_left"):
		direction_x -= 1 
	if Input.is_action_pressed("ui_right"):
		direction_x += 1
	if is_on_floor() && Input.is_action_pressed("ui_select"):
		velocity.y = -jump_impulse
	velocity.x = direction_x * delta * speed

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta


func _physics_process(delta):
	
	handle_input(delta)
	apply_gravity(delta)
	move_and_slide()

# OLD : only left-right movement
#func _physics_process(delta):
#	velocity = Vector2.ZERO
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	#var direction = Input.get_axis("ui_left", "ui_right")
#	if Input.is_action_pressed("ui_left"):
#		velocity.x -= 1 
#	if Input.is_action_pressed("ui_right"):
#		velocity.x += 1
#		
#	#velocity.x = direction.x * speed * delta
#	
#	move_and_collide(velocity * speed * delta)
