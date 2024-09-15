@tool
extends EditorPlugin

const docs_scene:PackedScene = preload("res://addons/mooncast_docs/docs.tscn")
const docs_icon:CompressedTexture2D = preload("res://addons/mooncast_docs/MoonCastPhysicsTable.png")

var docs_screen:Control

func _enter_tree() -> void:
	setup()

func _exit_tree() -> void:
	cleanup()

func _enable_plugin() -> void:
	setup()

func _disable_plugin() -> void:
	cleanup()

func _get_plugin_name() -> String:
	return "MoonCast Docs"

func _get_plugin_icon() -> Texture2D:
	return docs_icon

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	docs_screen.visible = visible

func setup() -> void:
	docs_screen = docs_scene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(docs_screen)
	docs_screen.hide()

func cleanup() -> void:
	EditorInterface.get_editor_main_screen().remove_child(docs_screen)
	docs_screen.queue_free()
