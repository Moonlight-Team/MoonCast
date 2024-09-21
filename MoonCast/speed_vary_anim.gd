extends Resource

class_name SpeedVariedAnimLib

##A sorted (largest to smallest) array of the keys in this anim
var sorted_keys:PackedFloat32Array
##The key of the current anim
var current:float
##The array pos of the current anim
var current_pos:int = 0
##The key of the previous (slower) anim
var previous:float = -1.0
##The key of the next (faster) anim
var next:float = -1.0

func load_dictionary(dict:Dictionary) -> void:
	#check the anim_run keys for valid values
	for keys:float in dict.keys():
		var snapped_key:float = snappedf(keys, 0.001)
		if not is_equal_approx(keys, snapped_key):
			push_warning("Key ", keys, " is more precise than the precision cutoff")
		sorted_keys.append(snapped_key)
	#sort the keys (from least to greatest)
	sorted_keys.sort()
	
	sorted_keys.reverse()
	
	pos_update(0)

func pos_update(pos:int) -> void:
	current = sorted_keys[clampi(pos, 0, sorted_keys.size() - 1)]
	if pos > 0:
		previous = sorted_keys[pos - 1]
	else:
		previous = current - 1.0
	
	if pos < sorted_keys.size() - 1:
		next = sorted_keys[pos + 1]
	else:
		next = current + 1.0

func update_anim_key(speed:float) -> float:
	if sorted_keys.size() == 1:
		return sorted_keys[0]
		
	if speed > next:
		prints("Incrimenting", current, "to", next)
		pos_update(current_pos + 1)
	if speed < previous:
		prints("Decrementing ", current, "to", previous)
		pos_update(current_pos -1)
	return current
