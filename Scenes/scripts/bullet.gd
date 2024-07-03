extends Area2D

@onready var speed : int = 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= speed * delta

func _on_body_entered(body):
	if body.is_in_group("brick"):
		body.hit()
	queue_free()
