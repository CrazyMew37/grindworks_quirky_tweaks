extends Node

func _init():
	var overwrite_mole_battle = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_fairway_mole_battle.tscn")
	overwrite_mole_battle.take_over_path("res://objects/modules/cgc/variants/cgc_fairway_mole_battle.tscn")
	var overwrite_mole_boss = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_fairway_parkour_boss.tscn")
	overwrite_mole_boss.take_over_path("res://objects/modules/cgc/variants/cgc_fairway_parkour_boss.tscn")
	var overwrite_mole_room = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_mole_stomp.tscn")
	overwrite_mole_room.take_over_path("res://objects/modules/cgc/variants/cgc_mole_stomp.tscn")
	var overwrite_mole_quadrant = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_quadrant_room.tscn")
	overwrite_mole_quadrant.take_over_path("res://objects/modules/cgc/variants/cgc_quadrant_room.tscn")
	var overwrite_fence_prison = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_fairway_fence_prison.tscn")
	overwrite_fence_prison.take_over_path("res://objects/modules/cgc/variants/cgc_fairway_fence_prison.tscn")
	var overwrite_vertical_room = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_fairway_vertical.tscn")
	overwrite_vertical_room.take_over_path("res://objects/modules/cgc/variants/cgc_fairway_vertical.tscn")
	var overwrite_sand_moles = preload("res://mods-unpacked/CrazyMew37-YellowMoleDestroyer/overwrites/cgc_long_room_moles.tscn")
	overwrite_sand_moles.take_over_path("res://objects/modules/cgc/variants/cgc_long_room_moles.tscn")
