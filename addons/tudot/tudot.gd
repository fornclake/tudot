@tool extends EditorPlugin
## Godot Tutor addon.

## Tutorial resource.
var tutorial : Tutorial:
	set = set_tutorial

var dock
var overlay
var file_dialog : FileDialog

signal tutorial_selected


# Initialize overlay and dock.
func _enter_tree():
	dock = preload("res://addons/tudot/dock.tscn").instantiate()
	dock.get_node("Task/Buttons/Go").pressed.connect(play)
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	
	overlay = dock.get_node("Overlay")
	overlay.visible = false
	overlay._tutor = self
	overlay._editor_interface = get_editor_interface()
	
	file_dialog = dock.get_node("FileDialog")
	
	dock.get_node("Task/Buttons/Load").pressed.connect(file_dialog.popup)
	file_dialog.file_selected.connect(set_tutorial)
	
	tutorial_selected.connect(play)


# Remove dock.
func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()


# Play a single tutorial step.
func _play_step(step : Tutorial.Step):
	for dialog in step.dialogs:
		await overlay.create_and_play_dialog(dialog)


# Loads a new tutorial using a FileDialog and sets the task text to its script.
func set_tutorial(path):
	var resource = load(path)
	
	if not resource or not resource is Tutorial:
		printerr("Failed to load tutorial resource.")
	
	tutorial = resource
	dock.get_node("Task/Text").text = tutorial.text


## Parses the tutorial resource and plays it.
func play():
	tutorial.parse()
	overlay.show()
	for step in tutorial.steps:
		await _play_step(step)
	overlay.hide()
