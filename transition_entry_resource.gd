extends Resource
class_name TEntryRes

@export
var input: String                       ## Input triggering transition
@export
var transition: String                  ## State after transition

func _init(p_input: String, p_transition: String) -> void:
	input = p_input
	transition = p_transition
