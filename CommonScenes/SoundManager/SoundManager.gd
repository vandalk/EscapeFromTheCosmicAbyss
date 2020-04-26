extends Node

var bgm1 = preload("res://CommonScenes/SoundManager/bgm/Musique_1.ogg")
var bgm2 = preload("res://CommonScenes/SoundManager/bgm/Musique_2.ogg")
var bgm3 = preload("res://CommonScenes/SoundManager/bgm/Musique_electro.ogg")
var track_list = {
	"1" : bgm1,
	"2" : bgm2,
	"electro" : bgm3
}
var track_offset

var bgm_stream
var bgm_preview
var sfx_player
var fade_out
var fade_in

var initial_volume

func _ready():
	bgm_stream = self.get_node("BGMPlayer")
	bgm_preview = self.get_node("PreviewPlayer")
	sfx_player = self.get_node("SfxPlayer")
	
	fade_out = self.get_node("FadeOutTimer")
	fade_in = self.get_node("FadeInTimer")
	
	track_offset = 0


func play_sfx(sfx_name, is_unique = false):
	# sfx_player.play(sfx_name, is_unique) # -- AUDIO REFACTOR
	pass


func play_sfx_with_reverb(sfx_name, is_unique = false, reverb_size = 1, reverb_strenght = 0.5):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# sfx_player.set_reverb(sfx_player.play(sfx_name, is_unique), reverb_size, reverb_strenght) # -- AUDIO REFACTOR
	pass


func play_bgm():
	var track = Global.savedata["options"]["track"]
	var volume = float(Global.savedata["options"]["bgm volume"])/100
	print("Track: %s | Volume: %s"%[track, volume])
	
	bgm_stream.set_stream(track_list[track])
	bgm_stream.volume_db = (1 - volume) * -80 
	bgm_stream.play(track_offset)

func pause_bgm():
	if not bgm_stream.playing:
		bgm_stream.play(track_offset)
	else:
		track_offset = bgm_stream.get_playback_position()
		bgm_stream.stop()

func stop_bgm():
	bgm_stream.stop()

func change_bgm_track():
	var total_length = bgm_stream.stream.get_length()
	var position = bgm_stream.get_playback_position()
	var percent = position/total_length
	var track = Global.savedata["options"]["track"]
	
	bgm_stream.set_stream(track_list[track])
	
	total_length = bgm_stream.stream.get_length()
	track_offset = percent*total_length

func reset_track():
	track_offset = 0

func bgm_set_loop(boolean):
	bgm_stream.set_loop(boolean)

func preview_bgm(track):
	var volume = float(Global.savedata["options"]["bgm volume"])/100
	print("Track: %s | Volume: %s"%[track, volume])
	
	bgm_preview.set_stream(track_list[track])
	bgm_preview.volume_db = (1 - volume) * -80
	bgm_preview.play()

func preview_bgm_play():
	if not bgm_preview.is_playing():
		var track = Global.savedata["options"]["track"]
		self.preview_bgm(track)

func stop_preview_bgm():
	bgm_preview.stop()

func change_bgm_volume(vol):
	var float_vol = float(vol)/100
	var vol_db = (1 - float_vol) * -80
	print("Vol: %s | Volume: %s | Volume db: %s"%[vol, float_vol, vol_db])
	bgm_stream.volume_db = vol_db
	bgm_preview.volume_db = vol_db

func fade_out_start():
	if fade_in.time_left != 0:
		fade_in_stop()
	initial_volume = Global.savedata["options"]["bgm volume"]*0.01
	fade_out.start()
	
	print("Initial Volume: %s"%[initial_volume])

func fade_out_stop():
	fade_out.stop()
	print("Stop Volume: %s"%[bgm_stream.volume_db])

func fade_in_start():
	if fade_out.time_left != 0:
		fade_out_stop()
	initial_volume = bgm_stream.volume_db
	fade_in.start()
	
	print("Initial Volume: %s"%[initial_volume])

func fade_in_stop():
	fade_in.stop()
	print("Stop Volume: %s"%[bgm_stream.volume_db])

func _on_FadeOutTimer_timeout():
	print("fade out!")
	var current_vol = bgm_stream.volume_db
	current_vol -= 1
	
	if current_vol < 0:
		current_vol = 0
	
	if initial_volume - 15 >= 0:
		if current_vol > initial_volume - 15:
			bgm_stream.volume_db = current_vol
		else:
			fade_out_stop()
	else:
		if current_vol > 0:
			bgm_stream.volume_db = current_vol
		else:
			fade_out_stop()

func _on_FadeInTimer_timeout():
	print("fade in!")
	var target_volume =  Global.savedata["options"]["bgm volume"]
	var target_volume_db = (1 - (target_volume*0.01)) * -80
	var current_vol = bgm_stream.volume_db
	current_vol += 1
	
	if initial_volume + 15 <= target_volume_db:
		if current_vol < target_volume_db:
			bgm_stream.volume_db = current_vol
		else:
			bgm_stream.volume_db = target_volume_db
			fade_in_stop()
	else:
		if current_vol < target_volume_db:
			bgm_stream.volume_db = current_vol
		else:
			bgm_stream.volume_db = target_volume_db
			fade_in_stop()


