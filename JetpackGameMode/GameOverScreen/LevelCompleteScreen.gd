extends Node2D

var replay_btn
var next_level_btn
var upgrade_btn
var level_select_btn
var animator

var last_focus

var game
var label_message
var score
var label_score
var highscore
var label_highscore
var upgrade_points
var label_upgrade
var congratulations

var options_path = "res://CommonScenes/OptionsMenu/OptionsMenuScreen.tscn"
var upgrade_path = "res://CommonScenes/UpgradeMenu/UpgradeMenu.tscn"
var level_select_path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"

func _ready():
	replay_btn = self.get_node("Replay")
	next_level_btn = self.get_node("NextLevel")
	upgrade_btn = self.get_node("Upgrade")
	level_select_btn = self.get_node("LevelSelect")
	animator = self.get_node("AnimationPlayer")
	
	label_message = self.get_node("CompleteText")
	label_score = self.get_node("Score")
	label_highscore = self.get_node("Highscore")
	label_upgrade = self.get_node("UpgradePoints")
	congratulations = self.get_node("HighscoreText")
	
	game = get_parent().get_parent()
	
	if not upgrade_btn.is_connected("focus_enter",self,"_on_focus_enter"):
		upgrade_btn.connect("focus_enter",self,"_on_focus_enter")
	
	if not level_select_btn.is_connected("focus_enter",self,"_on_focus_enter"):
		level_select_btn.connect("focus_enter",self,"_on_focus_enter")
	
	pass

func open(msg):
	self.show()
	label_message.set_text("%s Complete!"%[msg])
	animator.play_backwards("fade out")
	
	#SoundManager.bgm_set_loop(false)
	#SoundManager.stop_bgm()
	
	game.set_game_state("GameOver")
	get_tree().set_pause(true)
	
	score = game.get_score()
	print_score(score, label_score)
	
	highscore = game.highscore
	print_score(highscore, label_highscore)
	
	upgrade_points = game.upgrade_points
	print_decimal(upgrade_points, label_upgrade)
	
	if score > highscore:
		congratulations.show()
		game.highscore = score
		Global.update_story_highscore(score)
	
	var last_level = game.level_loader.get_max_levels()-1
	if Global.savedata["story"]["current level"] < last_level:
		next_level_btn.grab_focus()
	else:
		next_level_btn.set_disabled(true)
		level_select_btn.grab_focus()

func _on_replay_pressed():
	if game != null:
		animator.play("fade out")
		yield(animator, "finished")
		
		resume_game()
#		ScreenManager.load_screen("res://JetpackGameMode/JetpackGame.tscn", self)
		get_tree().change_scene("res://JetpackGameMode/JetpackGame.tscn")
		
func _on_quit_pressed():
	get_tree().quit()


func resume_game():
	self.hide()
	get_tree().set_pause(false)

func print_score(points, label):
	var points_str
	if points < 10:
		points_str = "000"+str(points)
	elif points < 100:
		points_str = "00"+str(points)
	elif points < 1000:
		points_str = "0"+str(points)
	else:
		points_str = str(points)
	label.set_text(points_str)

func print_decimal(points, label):
	var points_str
	if points < 10:
		points_str = "0"+str(points)
	else:
		points_str = str(points)
	label.set_text(points_str)

func _on_upgrade_pressed():
	var path = upgrade_path
	last_focus = upgrade_btn.get_path()
	animator.play("fade out")
	yield(animator, "finished")
	
	self.hide()
	ScreenManager.load_above(path, last_focus, self)


func _on_focus_enter():
	#print("FOCUS GRABBED")
	if self.is_hidden():
		self.show()
		animator.play_backwards("fade out")
		yield(animator, "finished")
		
		if SoundManager.bgm_stream.is_paused():
			SoundManager.pause_bgm()
		
		upgrade_points = Global.savedata["story"]["upgrade points"]
		print_decimal(upgrade_points, label_upgrade)
		

func _on_LevelSelect_pressed():
	var path = level_select_path
	last_focus = level_select_btn.get_path()
	animator.play("fade out")
	yield(animator, "finished")
	
	self.hide()
	ScreenManager.load_above(path, last_focus, self)


func _on_NextLevel_pressed():
	Global.savedata["story"]["current level"] +=1 
	_on_replay_pressed()