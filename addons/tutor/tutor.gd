@tool extends EditorPlugin
## Godot Tutor addon.

## Tutorial resource.
var tutorial : Tutorial = preload("res://tutorials/highlights.tres")

var dock
var overlay


# Initialize overlay and dock.
func _enter_tree():
	dock = preload("res://addons/tutor/dock.tscn").instantiate()
	dock.get_node("Task/Go").pressed.connect(play)
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	
	overlay = dock.get_node("Overlay")
	overlay.visible = false
	overlay._tutor = self
	overlay._editor_interface = get_editor_interface()


# Remove dock.
func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()


# Play a single tutorial step.
func _play_step(step : Tutorial.Step):
	for dialog in step.dialogs:
		await overlay.create_and_play_dialog(dialog)


## Parses the tutorial resource and plays it.
func play():
	tutorial.parse()
	overlay.show()
	for step in tutorial.steps:
		await _play_step(step)
	overlay.hide()
