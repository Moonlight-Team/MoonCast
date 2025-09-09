@tool
extends Node2D
##A basic ring collectible node type
class_name Ring2D

@export_group("Animation", "animation_")
##The [SpriteFrames] to use for this [Ring2D]'s animations.
@export var animation_sheet:SpriteFrames:
	set(new_sheet):
		animation_sheet = new_sheet
		
		if animation_sheet != null:
			animation_sheet.connect("changed", queue_redraw)
		queue_redraw()
##The offset to render the animation relative to the position of the node.
@export var animation_offset:Vector2:
	set(new_offset):
		animation_offset = new_offset
		queue_redraw()
##The name of the animation to play normally. This animation will loop.
@export var animation_normal_name:StringName = &"default":
	set(new_name):
		animation_normal_name = new_name
		queue_redraw()
##The name of the animation to play when collected. This will play once when the ring
##is collected and then the ring object will self-disable.
@export var animation_collected_name:StringName = &"collected":
	set(new_name):
		animation_collected_name = new_name
		queue_redraw()

@export_group("Collision", "collision_")
##The collision [Rect2] for this ring.
@export var collision_shape:Shape2D:
	set(new_shape):
		if area_rid.is_valid():
			#clear this first so that the previous collision shape can be safely freed
			PhysicsServer2D.area_clear_shapes(area_rid)
		
		collision_shape = new_shape
		
		if new_shape != null:
			new_shape.connect("changed", queue_redraw)
			
			if area_rid.is_valid():
				PhysicsServer2D.area_add_shape(area_rid, new_shape.get_rid())
			
		queue_redraw()
@export_flags_2d_physics var collision_layer:int = 1:
	set(new_layer):
		collision_layer = new_layer
		
		if area_rid.is_valid():
			PhysicsServer2D.area_set_collision_layer(area_rid, new_layer)

##The debug color for this ring.
@export var collision_debug_color:Color = Color.YELLOW:
	set(new_color):
		collision_debug_color = new_color
		queue_redraw()

var collected:bool = false

var area_rid:RID

func _get_configuration_warnings() -> PackedStringArray:
	return []

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			if is_instance_valid(collision_shape):
				set_notify_transform(true)
				
				area_rid = PhysicsServer2D.area_create()
				
				PhysicsServer2D.area_set_collision_layer(area_rid, collision_layer)
				PhysicsServer2D.area_add_shape(area_rid, collision_shape.get_rid())
				
				PhysicsServer2D.area_set_space(area_rid, get_world_2d().space)
				
				PhysicsServer2D.area_set_monitor_callback(area_rid, collision_check)
		
		NOTIFICATION_TRANSFORM_CHANGED:
			PhysicsServer2D.area_set_transform(area_rid, global_transform)
		
		NOTIFICATION_DRAW:
			if is_instance_valid(animation_sheet):
				draw_sprites()
			
			if Engine.is_editor_hint() or (is_visible_in_tree() and get_tree().debug_collisions_hint):
				collision_shape.draw(get_canvas_item(), collision_debug_color)

func collision_check(status:int, body_rid:RID, instance_id:int, body_shape_idx:int, _self_shape_idx:int) -> void:
	
	if status == PhysicsServer2D.AREA_BODY_ADDED:
		#TODO: Specifically check for the player
		
		collect()

func collect() -> void:
	set_notify_transform(false)
	PhysicsServer2D.call_deferred("area_set_monitorable", area_rid, false)
	collected = true
	queue_redraw()

func draw_sprites() -> void:
	if not collected and animation_sheet.has_animation(animation_normal_name):
		var frame_count:int = animation_sheet.get_frame_count(animation_normal_name)
		
		var anim_fps:float = animation_sheet.get_animation_speed(animation_normal_name)
		
		var anim_length:float = frame_count / anim_fps #in seconds
		var anim_offset:float = 0.0
		
		for frame:int in frame_count:
			var seconds_duration:float = animation_sheet.get_frame_duration(animation_normal_name, frame) / anim_fps
			var texture:Texture2D = animation_sheet.get_frame_texture(animation_normal_name, frame)
			
			var new_offset:float = anim_offset + seconds_duration
			
			draw_animation_slice(anim_length, anim_offset, new_offset)
			draw_texture(texture, animation_offset, modulate)
			
			anim_offset = new_offset
		
		draw_end_animation()
	elif collected and animation_sheet.has_animation(animation_collected_name):
		RenderingServer.canvas_item_clear(get_canvas_item())
		var frame_count:int = animation_sheet.get_frame_count(animation_collected_name)
		
		var anim_fps:float = animation_sheet.get_animation_speed(animation_collected_name)
		
		var anim_length:float = frame_count / anim_fps #in seconds
		var anim_offset:float = 0.0
		
		for frame:int in frame_count:
			var seconds_duration:float = animation_sheet.get_frame_duration(animation_collected_name, frame) / anim_fps
			var texture:Texture2D = animation_sheet.get_frame_texture(animation_collected_name, frame)
			
			var new_offset:float = anim_offset + seconds_duration
			
			draw_animation_slice(anim_length, anim_offset, new_offset)
			draw_texture(texture, animation_offset, modulate)
			
			anim_offset = new_offset
		
		draw_end_animation()
