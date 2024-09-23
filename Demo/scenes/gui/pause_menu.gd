extends CanvasLayer

@export var pause_button:StringName

@export var sfx_button_move:AudioStream

@export var sfx_button_select:AudioStream

@export var sfx_button_exit:AudioStream

@onready var resume_button:Button = $"Panel/Margins/Sections/Main/menu/resume"
@onready var ui_sections:TabContainer = $"Panel/Margins/Sections"

@onready var audio:AudioStreamPlaybackPolyphonic

var pause_active:bool = false

var scene:SceneTree

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	scene = get_tree()
	custom_viewport = get_window().get_viewport()
	$Panel/Margins/Sections/Main/Info/Version.text += ProjectSettings.get_setting("application/config/version")
	$"AudioStreamPlayer".play()
	audio = $"AudioStreamPlayer".get_stream_playback()

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
	if paused:
		audio.play_stream(sfx_button_select)
	else:
		audio.play_stream(sfx_button_exit)

func button_movement() -> void:
	audio.play_stream(sfx_button_move)

func _on_resume_pressed() -> void:
	audio.play_stream(sfx_button_select)
	if pause_active:
		toggle_pause(false)

func _on_restart_pressed() -> void:
	toggle_pause(false)
	audio.play_stream(sfx_button_select)
	scene.reload_current_scene()

func _on_options_pressed() -> void:
	audio.play_stream(sfx_button_select)

func _on_quit_pressed() -> void:
	audio.play_stream(sfx_button_exit)
	OS.set_restart_on_exit(true)
	scene.quit()
