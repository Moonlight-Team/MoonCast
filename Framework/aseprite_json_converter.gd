@tool
extends EditorScript

# a script to turn aseprite animations from a json file into a SpriteFrames object
# Some prerequisites:
# * Export the aseprite file as a sprite sheet, with JSON metadata
# * Keep the sheet in the same directory as the JSON file

##Change this to the path of your aseprite json file
const aseprite_json_path: String = "res://Demo/player/sonic1/Sonic Sprite.json"

var source_texture: ImageTexture
var atlas_textures: Array[AtlasTexture] = []
var texture_durations:PackedInt32Array = []
var base_export_path:String

func import_atlases(from_data:Dictionary, atlas_source:ImageTexture) -> void:
	var keys:Array = from_data.keys()
	
	atlas_textures.resize(keys.size())
	texture_durations.resize(keys.size())
	
	for frame_index:int in range(keys.size()):
		var cur_frame:Dictionary = from_data.get(keys[frame_index])
		
		var out_tex:AtlasTexture = AtlasTexture.new()
		
		var sheet_region: Rect2 = Rect2(
			cur_frame["frame"]["x"],
			cur_frame["frame"]["y"],
			cur_frame["frame"]["w"],
			cur_frame["frame"]["h"],
		)
		
		out_tex.region = sheet_region
		out_tex.atlas = atlas_source
		
		if cur_frame["trimmed"] == true:
			var orig_region: Vector2 = Vector2(
				cur_frame["spriteSourceSize"]["x"],
				cur_frame["spriteSourceSize"]["y"],
			)
			
			var source_size:Vector2 = Vector2(
				cur_frame["sourceSize"]["w"],
				cur_frame["sourceSize"]["h"]
			)
			
			out_tex.margin = Rect2(
				orig_region.x,
				orig_region.y,
				source_size.x - sheet_region.size.x,
				source_size.y - sheet_region.size.y
			)
		
		atlas_textures[frame_index] = out_tex
		texture_durations[frame_index] = cur_frame["duration"]
		
		ResourceSaver.save(out_tex, base_export_path + keys[frame_index] + ".tres")

func import_animations(from_data:Array) -> void:
	var out_frames: SpriteFrames = SpriteFrames.new()
	
	for anim in from_data:
		var cur_name:String = anim["name"]
		
		out_frames.add_animation(cur_name)
		
		var start_frame:int = anim["from"]
		var end_frame:int = anim["to"]
		var frame_count: int = end_frame - start_frame
		var total_time_ms:int = 0
		
		if end_frame != start_frame:
			total_time_ms = 0
			
			for i:int in range(start_frame, end_frame):
				total_time_ms += texture_durations[i]
			var average_time_ms:float = total_time_ms / frame_count
			
			printt(cur_name, 
			"\n\ttotal time in milliseconds: ", total_time_ms, 
			"\n\tFrames: ", frame_count,
			"\n\tTime in seconds", total_time_ms * 0.001,
			)
			
			for i in range(start_frame, end_frame):
				var this_frame_time: float = texture_durations[i] / average_time_ms
				
				printt("\tThis frame's time:", this_frame_time)
				out_frames.add_frame(cur_name, atlas_textures[i], this_frame_time)
		else:
			frame_count = 1
			total_time_ms = texture_durations[start_frame]
			out_frames.add_frame(cur_name, atlas_textures[start_frame])
		
		var frames_per_second: float = (frame_count * 1000) / total_time_ms
		
		out_frames.set_animation_speed(cur_name, frames_per_second)
		
	
	ResourceSaver.save(out_frames, base_export_path + aseprite_json_path.get_file() + ".tres")

func _run() -> void:
	var json_string: String = FileAccess.get_file_as_string(aseprite_json_path)
	base_export_path = aseprite_json_path.get_base_dir() + "/"
	
	if json_string.is_empty():
		push_error("Could not open file : ", aseprite_json_path)
		return
	
	var json_data: Dictionary = JSON.parse_string(json_string)
	
	if json_data.is_empty():
		push_error("Could not parse JSON file: ", aseprite_json_path)
		return
	
	var atlas_file: String = base_export_path + String(json_data["meta"]["image"])
	var atlas_image: Image = Image.load_from_file(atlas_file)
	source_texture = ImageTexture.create_from_image(atlas_image)
	
	var out_frames: SpriteFrames = SpriteFrames.new()
	
	import_atlases(json_data["frames"], source_texture)
	
	var anim_list:Array = json_data["meta"]["frameTags"]
	
	import_animations(anim_list)
