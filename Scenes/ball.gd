extends RigidBody2D

var speed : int = 100
var dir : Vector2
var velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	dir.x = [-1,1].pick_random()
	dir.y = [-1,1].pick_random()
	velocity = dir * speed
	
func _on_collision_detected(body):
	if body is StaticBody2D or body is CharacterBody2D:
		# Berechne den Winkel, unter dem der Ball auftrifft
		var normal = body.global_position - global_position
		var angle = normal.angle()
		
		# Reflektiere den Geschwindigkeitsvektor des Balls
		var velocity = linear_velocity.rotated(-angle) * 0.9 # Geschwindigkeit etwas verringern
		apply_central_impulse(velocity.rotated(angle))


func _physics_process(delta):
	#velocity * speed * delta
	move_and_collide(velocity)
