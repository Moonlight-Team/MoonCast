extends Node

#a useful autoload singleton for injecting GUIs, players, etc. into any scene

const ini_filename:String = "global_scenes.ini"
const scene_section:String = "GlobalScenes"

const ability_section:String = "GlobalPlayerAbilities"

const general_instructions:String = """;This file is used for easily loading global things in a harmless and easy way. 
;Instructions will be included in the relevant sections of this file on how to use
;this file, or you can look at the script that implements this feature (globals_injector.gd).
"""

const scene_instructions:String = """In this section, add any scenes you want to load in every scene across the game.
The key is a label for the scene that will be loaded into the autoload singleton, and
the value is the path to find that scene at.
"""

var scenes:Dictionary[String, PackedScene]
var root_name_blacklist:PackedStringArray


func _ready() -> void:
	process_ini_file()
	inject_scenes(get_tree().current_scene)
	get_tree().connect(&"node_removed", prepare_injection)

func prepare_injection(_the_node:Node) -> void:
	var tree:SceneTree = get_tree()
	
	if is_instance_valid(tree) and not is_instance_valid(tree.current_scene):
		tree.connect(&"node_added", inject_scenes)

func inject_scenes(root:Node) -> void:
	var tree:SceneTree = get_tree()
	if is_instance_valid(tree.current_scene) and root == tree.current_scene and not root_name_blacklist.has(root.name):
		for scene_names:String in scenes.keys():
			var scene:PackedScene = scenes.get(scene_names, null)
			
			if not scene == null:
				tree.current_scene.add_child(scene.instantiate())
		
		if tree.is_connected(&"node_added", inject_scenes):
			tree.disconnect(&"node_added", inject_scenes)

func process_ini_file() -> void:
	var file_path:String = "res://" + ini_filename
	
	if not FileAccess.file_exists(file_path):
		var new_ini:FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
		new_ini.store_string(general_instructions)
		new_ini.close()
	
	var ini:ConfigFile = ConfigFile.new()
	ini.load(file_path)
	
	if ini.get_sections().size() < 1:
		var file_text:FileAccess = FileAccess.open(file_path, FileAccess.WRITE_READ)
		file_text.store_string(general_instructions)
	
	if ini.has_section(scene_section) and ini.get_section_keys(scene_section).size() > 0:
		for scene_name:String in ini.get_section_keys(scene_section):
			if scene_name == "instructions":
				continue
			elif scene_name == "root_name_blacklist":
				root_name_blacklist = ini.get_value(scene_section, scene_name, [])
			else:
				var scene_path:String = ini.get_value(scene_section, scene_name, "")
				if FileAccess.file_exists(scene_path):
					scenes[scene_name] = load(scene_path)
				else:
					push_warning("Autoload scene called ", scene_name, "could not be loaded at path ", scene_path)
	else:
		ini.set_value(scene_section, "instructions", scene_instructions)
		
	ini.save(file_path)
