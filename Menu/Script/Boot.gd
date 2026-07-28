extends Node2D

@export var BG: TextureRect
@export var fade_duration: float = 1.0
@export var display_duration: float = 5.0
@export var next_scene_path: String = "res://Game/Game.tscn"

func _ready() -> void:
	
	start_splash_sequence()
	
func start_splash_sequence() -> void:
	
	var tween = create_tween()
	
	tween.tween_property(BG, "modulate:a", 0.0, fade_duration)
	tween.tween_interval(display_duration)
	tween.tween_property(BG, "modulate:a", 1.0, fade_duration)
	tween.tween_callback(go_to_main_menu)
	
func go_to_main_menu() -> void:
	
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Error: Main Menu scene path not found! Check 'next_scene_path'.")
	
