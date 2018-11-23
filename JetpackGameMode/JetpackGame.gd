extends Node2D

# Nodes this script will interact with
var overheat_bar
var overheat_bar_animator
var points_label
var upgrade_messager
var ammunition
var player
var level_loader
var object_spawner

# Other "Game Screens"
var game_over_screen
var level_complete_screen
var countdown
var tutorial

# Game Mode "Stats" and Variables?
export var point_multiple = 5
export var upgrade_multiple = 30
export(String, FILE) var level_select_path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"


var game_settings
var points = 0
var points_level = 0
var cycles = 0
var level_num
var level_title
var highscore = Global.savedata["story"]["highscore"]
var initial_shield = Global.savedata["story"]["initial shield"]
var initial_ammo = Global.savedata["story"]["initial ammo"]
var initial_speed = Global.savedata["story"]["initial speed"]
var max_speed = 4 + Global.savedata["story"]["max speed"]
var laser_duration = Global.savedata["story"]["laser duration"]
var upgrade_points = Global.savedata["story"]["upgrade points"]
var levels_unlocked = Global.savedata["story"]["levels unlocked"]
var cooldown = Global.savedata["story"]["cooldown"]

const STATE = {
	"Playing": 0,
	"Start": 1,
	"Pause": 2,
	"Tutorial": 3,
	"GameOver": 4
}

var current_state = STATE["Playing"]

func _ready():
	game_settings = Global.get_game_mode()
	
	#TODO? - Change the nodes according to game mode?
	tutorial = self.get_node("AboveScreen/TutorialTipScreen")
	game_over_screen = self.get_node("AboveScreen/GameOverScreen")
	level_complete_screen = self.get_node("AboveScreen/LevelCompleteScreen")
	
	# Nodes
	countdown = self.get_node("AboveScreen/CountdownScreen")
	overheat_bar = self.get_node("HUD/TextureProgress")
	overheat_bar_animator = self.get_node("HUD/TextureProgress/AnimationPlayer")
	ammunition = self.get_node("HUD/TextureProgress/Ammunition")
	points_label = self.get_node("HUD/Points")
	upgrade_messager = self.get_node("HUD/UpgradeLabel/Messager")
	player = self.get_node("Player")
	level_loader = self.get_node("LevelLoader")
	object_spawner = self.get_node("Camera2D/ObstacleSpawner")
	
	ammunition.initialize_ammo(initial_ammo)
	
	show_pre_game()

func show_pre_game():
	if game_settings["game mode"] == "story":
		load_story_pregame()
	elif game_settings["game mode"] == "arcade":
		pass
	elif game_settings["game mode"] == "speedrun":
		pass
	else:
		print("ERROR | Invalid game mode: %s"%[game_settings["game mode"]])
	
	self.get_tree().set_pause(true)

func load_story_pregame():
	if not is_tutorial_completed():
		Global.set_current_story_level(0)
	
	if game_settings["sub-mode"] == "level selected":
		game_start()
	elif game_settings["sub-mode"] == "select level":
		var path = level_select_path
		var last_focus = self
		ScreenManager.load_above(path, last_focus, self)
	else:
		print("ERROR | Invalid sub-mode: %s"%[game_settings["sub-mode"]])

func is_tutorial_completed():
	return Global.savedata["story"]["tutorial beaten"]

func initialize_game_stats():
	var highscore = Global.savedata["story"]["highscore"]
	var initial_shield = Global.savedata["story"]["initial shield"]
	var initial_ammo = Global.savedata["story"]["initial ammo"]
	var initial_speed = Global.savedata["story"]["initial speed"]
	var max_speed = 4 + Global.savedata["story"]["max speed"]
	var laser_duration = Global.savedata["story"]["laser duration"]
	var upgrade_points = Global.savedata["story"]["upgrade points"]
	var levels_unlocked = Global.savedata["story"]["levels unlocked"]
	var cooldown = Global.savedata["story"]["cooldown"]

func get_game_state():
	return current_state

func set_game_state(string):
	current_state = STATE[string]

func load_level():
	var num = Global.savedata["story"]["current level"]
	var level
	
	if num < level_loader.get_max_levels():
		level = level_loader.load_level(num)
	else:
		print("ERROR | LEVEL OUT OF RANGE")
		num = level_loader.get_max_levels()-1
		level = level_loader.load_level(num)
	
	if level.tutorial:
		set_game_state("Tutorial")
	
	object_spawner.set_level(level)
	if num < 10:
		level_num = "Level 0%s"%[num]
	else:
		level_num = "Level %s"%[num]
	level_title = level.title

func get_score():
	return points

func get_overheat():
	return overheat_bar.get_value()

func set_overheat(value):
	overheat_bar.set_value(value)

func game_over():
	game_over_screen.open()
	get_tree().set_pause(true)

func _on_scored(num):
	var last_point_level = points_level
	
	points += num
	points_level = int(points/point_multiple)
	#print(points_level)
	
	if points_level > last_point_level:
		ammunition.add_ammo()
		
		print("initial_speed: %s | max_speed: %s"%[player.speed_x, max_speed])
		if player.speed_x < max_speed:
			player.speed_x += 1.0
			player.gravity += 10.0
			player.speed_y -= 20.0
			#print("speed_x: %s | gravity: %s | speed_y: %s"%[player.speed_x, player.gravity, player.speed_y])
			if not player.dashing:
				player.speed.x = player.speed_x* player.unit.x
	#			print(player.speed.x)
	
		if points_level % int(upgrade_multiple/point_multiple) == 0:
			upgrade_points += 1
			upgrade_messager.play("text_anim")
			Global.update_story_upgrade(upgrade_points)
	update_score()
	pass # replace with function body

func update_score():
	var points_str
	if points < 10:
		points_str = "000"+str(points)
	elif points < 100:
		points_str = "00"+str(points)
	elif points < 1000:
		points_str = "0"+str(points)
	else:
		points_str = str(points)
	points_label.set_text(points_str)

func dash_score():
	points -= 5
	update_score()

func game_start():
	load_level()
	if current_state == STATE["Tutorial"]:
		tutorial.play(level_num, level_title)
		object_spawner.connect_tutorial_signal(tutorial)
	else:
		countdown.play(level_num, level_title)

func tutorial_start():
	tutorial.play()

func _on_level_end():
	player_end_level()
	level_complete_screen.open(level_num)
	get_tree().set_pause(true)

func player_end_level():
	player.gravity_force = 0
	player.jetpack_force = 0

func player_reset_y():
	var boost_timer = get_node("AutoBoost")
	player.reset_y()
	Input.action_press("boost")
	boost_timer.start()
	yield(boost_timer,"timeout")
	Input.action_release("boost")
	pass
