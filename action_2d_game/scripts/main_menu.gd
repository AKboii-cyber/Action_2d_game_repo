extends Control
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings
@onready var how_to_play_page: Panel = $HowToPlayPage


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	settings.visible = false
	how_to_play_page.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/storyline.tscn")


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings.visible = true
	how_to_play_page.visible = false


func _on_how_to_play_pressed() -> void:
	main_buttons.visible = false
	settings.visible = false
	how_to_play_page.visible = true


func _on_back_pressed() -> void:
	_ready()
