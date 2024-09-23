extends CanvasLayer

@export var pause_button:StringName

@onready var resume_button:Button = $"Panel/Margins/TabContainer/UI/menu/resume"

var pause_active:bool = false

var scene:SceneTree

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	scene = get_tree()
	custom_viewport = get_window().get_viewport()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(pause_button):
		pause_active = not pause_active
		toggle_pause(pause_active)
	elif event.is_action_released(pause_button) and pause_active:
		resume_button.grab_focus()

func toggle_pause(paused:bool) -> void:
	visible = paused
	pause_active = paused
	scene.paused = paused

func _on_resume_pressed() -> void:
	if pause_active:
		toggle_pause(false)

func _on_restart_pressed() -> void:
	scene.reload_current_scene()

func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	pass # Replace with function body.
