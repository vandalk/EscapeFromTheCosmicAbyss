extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [0,5,5,5,5]
var intro_halfs = [0,0,0,0,0]
var end_beat = 0
var boss = {
	"boss_level": false,
	"laser_countdown":0,
	"scream": false,
	"countdown": 0,
	"sequence": []
}

var beats = {
	"none": 0,
	"tentacles": 0,
	"double_pipe": 0,
	"triple_pipe": 0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}

var half_beats = {
	"none": 0,
	"tentacles": 0,
	"double_pipe": 0,
	"triple_pipe": 0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}