extends "res://JetpackGameMode/Boss/BackgroundBoss.gd"

var has_killed_player = false
var raycasts

var game
var collision_timer

func _ready():
	raycasts = get_node("LaserMargins/LaserCenter/Raycasts").get_children()
	game = get_tree().get_root().get_node("JetpackGame")
	collision_timer = get_node("CollisionTimer")
	
	animator.play("base")
	set_fixed_process(true)


func _fixed_process(delta):
	for raycast in raycasts:
		if raycast.is_colliding():
			handle_collision(raycast)


func handle_collision(raycast):
	var collider = raycast.get_collider()
	print("Boss | Raycast: %s | Collider: %s" %[raycast.get_name(), collider.get_name()])
	if collider.is_in_group("player"):
		set_fixed_process(false)
		collision_timer.start()
		if not collider.is_dead and collider.shield_energy > 0:
			collider.shield.decrease_energy(1)
		elif not collider.is_dead:
			var player_global_position = collider.get_global_pos()
			has_killed_player = true
			kill_player(player_global_position)


func kill_player(player_global_position):
	#play player killing animation here in the future, if you want/have to
	#at the end of that animation, either from a signal or by calling it directly, call _on_player_killed
	_on_player_killed()


func _on_player_killed():
	if not has_killed_player:
		set_fixed_process(true)


func _on_CollisionTimer_timeout():
	set_fixed_process(true)