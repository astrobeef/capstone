extends Control

signal puzzle_requested(index: int)

func refresh(progression: PuzzleProgression) -> void:
	var list := get_node("./MarginContainer/VBoxContainer")
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var heading := Label.new()
	heading.text = "Choose a puzzle"
	list.add_child(heading)
	for index in range(progression.puzzles.size()):
		var button := Button.new()
		button.name = "Puzzle_%d" % index
		var status := ""
		if progression.completed[index]:
			status = " (Completed)"
		elif not progression.is_unlocked(index):
			status = " (Locked)"
		button.text = progression.puzzles[index].title + status
		button.disabled = not progression.is_unlocked(index)
		button.pressed.connect(func(): puzzle_requested.emit(index))
		list.add_child(button)
