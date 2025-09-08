@tool
extends Node2D

class_name Ring2D

@export_group("Animation", "animation_")
##The [SpriteFrames] to use for this [Ring2D]'s animations.
@export var animation_sheet:SpriteFrames
##The offset to render the animation relative to the position of the node.
@export var animation_offset:Vector2:
	set(new_offset):
		animation_offset = new_offset
		queue_redraw()
##The name of the animation to play normally. This animation will loop.
@export var animation_normal_name:StringName
##The name of the animation to play when collected. This will play once when the ring
##is collected and then the ring object will self-disable.
@export var animation_collected_name:StringName

@export_group("Collision", "collision_")
##The collision [Rect2] for this ring.
@export var collision_shape:Shape2D:
	set(new_shape):
		collision_shape = new_shape
		
		if collision_shape != null:
			collision_shape.connect("changed", queue_redraw)
		queue_redraw()
##The debug color for this ring.
@export var collision_debug_color:Color = Color.YELLOW:
	set(new_color):
		collision_debug_color = new_color
		queue_redraw()

var collected:bool = false

func _get_configuration_warnings() -> PackedStringArray:
	return []

func _draw() -> void:
	if is_instance_valid(animation_sheet) and animation_sheet.has_animation(animation_normal_name):
		var frame_count:int = animation_sheet.get_frame_count(animation_normal_name)
		
		var duration_array:Array[float]; duration_array.resize(frame_count)
		var texture_array:Array[Texture2D]; texture_array.resize(frame_count)
		
		var anim_speed:float = animation_sheet.get_animation_speed(animation_normal_name)
		
		var anim_length:float = 0.0
		var anim_offset:float = 0.0
		
		for frame:int in frame_count:
			duration_array[frame] = animation_sheet.get_frame_duration(animation_normal_name, frame)
			texture_array[frame] = animation_sheet.get_frame_texture(animation_normal_name, frame)
			
			anim_length += duration_array[frame]
		
		for frame:int in frame_count:
			var duration:float = duration_array[frame]
			var texture:Texture2D = texture_array[frame]
			
			var new_offset:float = anim_offset + duration
			
			draw_animation_slice(anim_length, anim_offset, new_offset)
			draw_texture(texture, animation_offset, modulate)
			
			anim_offset = new_offset
	
	draw_end_animation()
	
	if Engine.is_editor_hint():
		collision_shape.draw(get_canvas_item(), collision_debug_color)
