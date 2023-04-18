@tool extends ScrollContainer
## Tutor dock.

const MAX_RECTS = 4 # Maximum number of shader uniforms in Overlay/BG

@export var tutorial : Tutorial

# Rectangles passed to overlay shader
var highlighted_rects : Array[Rect2] = []

# Rectangle getters for editor components
var tutor_rect:
	get: return get_parent().get_global_rect()
var inspector_rect:
	get: return _editor_interface.get_inspector().get_node("../../").get_global_rect()
var file_system_rect:
	get: return _editor_interface.get_file_system_dock().get_parent().get_global_rect()
var scene_tree_rect:
	get: return _scene_tree_dock.get_parent().get_global_rect()
var import_rect:
	get: return _import_dock.get_parent().get_global_rect()

# Node references
var _editor_interface : EditorInterface # set by plugin config when
@onready var overlay_popup = $Overlay
@onready var overlay_background := $Overlay/BG
@onready var task_label = %Text

# Hidden components set by _find_hidden_components
var _hidden_components_found = false
var _scene_tree_dock
var _import_dock
var _node_dock


func _ready():
	task_label.text = tutorial.text
	highlighted_rects = []
	_set_shader_parameters()


func _run_tutorial():
	tutorial.parse()
	task_label.text = tutorial.text
	
	for step in tutorial.steps:
		await _play_step(step)
	
	overlay_popup.hide()


# Searches for editor components not exposed by the engine.
func _find_hidden_components():
	var target_parent # manually search for a target parent we can search from
	for interface_child in _editor_interface.get_base_control().get_children():
		if interface_child is VBoxContainer:
			for vbox_child in interface_child.get_children():
				if vbox_child is HSplitContainer:
					target_parent = vbox_child
	
	# Set references accordingly
	_scene_tree_dock = target_parent.find_child("Scene", true, false)
	_import_dock = target_parent.find_child("Import", true, false)


# Create a dialog and wait until it is dismissed.
func _create_and_play_dialog(dialog : Tutorial.Dialog):
	var new_dialog = _create_dialog(dialog)
	
	_show_overlay()
	overlay_popup.add_child(new_dialog)
	overlay_popup.visibility_changed.connect(new_dialog.queue_free)
	
	await new_dialog.get_node(new_dialog.get_meta("button")).pressed
	
	new_dialog.queue_free()


# Create a dialog instance from a Tutorial.Dialog object
func _create_dialog(dialog: Tutorial.Dialog):
	var new_dialog = preload("res://addons/tutor/dialog.tscn").instantiate()
	var text_node = new_dialog.get_node(new_dialog.get_meta("text"))
	
	text_node.text = dialog.text
	text_node.visible = !text_node.text.is_empty()
	new_dialog.get_node(new_dialog.get_meta("title")).text = dialog.title
	_highlight_from_dialog(dialog)
	
	return new_dialog


## Play a single tutorial step.
func _play_step(step : Tutorial.Step):
	var dialogs := step.dialogs
	while dialogs.size() > 0:
		await _create_and_play_dialog(dialogs[0])
		dialogs.pop_front()


# Get rects to highlight from dialog.
func _highlight_from_dialog(dialog : Tutorial.Dialog):
	highlighted_rects = []
	
	if !_hidden_components_found:
		_find_hidden_components()
	
	for highlight in dialog.highlights:
		var rect : Rect2
		match highlight:
			"inspector": rect = inspector_rect
			"tutor": rect = tutor_rect
			"file_system": rect = file_system_rect
			"scene_tree": rect = scene_tree_rect
			"import": rect = import_rect
		highlighted_rects.append(rect)
	_set_shader_parameters()


# Set overlay shader uniforms to highlight components.
func _set_shader_parameters():
	for i in range(0,MAX_RECTS):
		var param = highlighted_rects[i] if i in range(0,highlighted_rects.size()) else Rect2(0,0,0,0)
		overlay_background.material.set_shader_parameter(str("rect",i), param)
	
	overlay_background.queue_redraw()


## Configure and popup overlay.
func _show_overlay():
	overlay_popup.position = get_window().position
	overlay_popup.size = get_window().size
	overlay_popup.popup()
