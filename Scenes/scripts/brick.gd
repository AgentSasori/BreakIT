extends StaticBody2D
# class_name Brick

@export var atlaspos = Vector2(112, 0)
@export var spritesize = Vector2(32,16)
@export var max_cracked_state = 2
@export var is_bonus = false
#@export var scene = PackedScene

var cracked = 0

@onready var game_node = get_node("../../Game")
@onready var parent = get_parent()
#@onready var spritesize = Vector2(32, 16)

func set_brick_color(no:int = 1):
	# depending on brick the atlas position must be changed
	atlaspos.y += no * spritesize.y

func hit():
	#if damagestage:
		#cracked = damagestage
		#print("full destruction")
		
	if cracked < max_cracked_state and not self.is_in_group("bonus"):
		cracked += 1
		var rect = Rect2(atlaspos.x + (cracked * spritesize.x), atlaspos.y, spritesize.x, spritesize.y)
		$Sprite2D.texture.region = rect #get_region(Rect2i(112, 16, 32, 16))
	else:
		# disable the collision
		$CollisionShape2D.disabled = true
		# Some grafic-effects: move the brick down and fade it out and delete it 
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position:y", self.position.y + 50, 0.3)
		tween.tween_property(self, "modulate:a", 0, 0.3) 
		tween.tween_property(self, "rotation_degrees",  randi_range(-120, 90) + 40, randf_range(0.5,2))# [-1,1].pick_random())
		tween.tween_callback(self.queue_free).set_delay(1)
		# tell the main script a brick has been destroyed 
		game_node.brick_destroyed(self)
		
		# maybe for later?
		if is_bonus:
			pass
