extends Resource
class_name TRowRes

@export
var state: String
@export
var row: Array[String]

func _init(p_state: String, p_row: Array[String]) -> void:
	state = p_state
	row = p_row

func print_transitions():
	var print_statement = "%s ||" % state
	for e in row:
		print_statement += " %s " % e
	print(print_statement)
