extends Control

@export var BG: TextureRect
@export var fade_duration: float = 1.0
@export var display_duration: float = 5.0

func _ready() -> void:
	
	start_splash_sequence()
	
func start_splash_sequence() -> void:
	
	var tween = create_tween()
	tween.tween_property(BG, "modulate:a", 0.0, fade_duration)
	tween.tween_interval(display_duration)
	
