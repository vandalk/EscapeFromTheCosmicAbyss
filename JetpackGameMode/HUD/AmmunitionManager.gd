extends HBoxContainer

# preloaded scenes
var ammo = preload("res://JetpackGameMode/HUD/Ammo.tscn")

# Limits
const TOTAL_SLOTS = 10


func initialize_ammo(initial_ammo):
	for x in range(0,initial_ammo):
		add_ammo()


func add_ammo():
	if get_child_count() >= TOTAL_SLOTS: return
	var instance = ammo.instance()
	add_child(instance, true)


func has_ammo():
	if get_child_count() == 0: 
		return false
	else:
		return true


func use_ammo():
	if get_child_count() == 0 : return false
	var ammo = get_child(0)
	
	ammo.used()
	
	return true


func _on_Ammunition_sort_children():
	if get_child_count() == 0:
		hide()
	else:
		show()
