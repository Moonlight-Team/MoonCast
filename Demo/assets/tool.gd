@tool
extends EditorScript

#little tool script for occasional automation tasks.

func _run() -> void:
	var img:Image = Image.new()
	
	img.load_svg_from_buffer(FileAccess.get_file_as_bytes("res://iconml.svg"))
	
	img.save_png("res://iconml.png")
