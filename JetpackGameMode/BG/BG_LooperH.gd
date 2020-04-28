extends AnimatedSprite

var end_point

func _ready():
	end_point = self.get_node("EndPoint")
	
	set_process(true)
	pass

func _process(delta):
	#print("Global Pos: %s | Pos: %s"%[self.global_position, self.position])
	if end_point.global_position.x < 0:
		#print("Move Sprite!")
		frame = floor(rand_range(0.0,5.0))
		var new_pos = Vector2(self.position.x + (2*2020), self.position.y)
		self.position = new_pos
	pass
