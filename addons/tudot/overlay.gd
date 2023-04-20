@tool extends Popup
## This script handles the overlay functionality for the tutorial system,
## including highlighting editor components and managing tutorial dialogs.

const MAX_RECTS = 4 # Maximum number of shader uniforms in Overlay/BG

# Rectangles passed to shader uniforms
var highlighted_rects : Array[Rect2] = []

# Node references
var _tutor
var _editor_interface : EditorInterface

# Hidden components set by _find_hidden_components
var _hidden_components_found = false
var _scene_tree_dock
var _import_dock


# Get rects to highlight from dialog.
func _highlight_from_dialog(dialog : Tutorial.Dialog) -> void:
	highlighted_rects = []
	
	if not _editor_interface:
		printerr("Editor interface not initialized. Cannot highlight.")
		return
	if not _tutor:
		printerr("Tutor not initialized. Cannot highlight.")
		return
	
	if not _hidden_components_found:
		_find_hidden_components()
	
	for highlight in dialog.highlights:
		var rect : Rect2
		match highlight:
			"inspector": rect = _editor_interface.get_inspector().get_node("../../").get_global_rect()
			"tutor": rect = _tutor.dock.get_parent().get_global_rect()
			"file_system": rect = _editor_interface.get_file_system_dock().get_parent().get_global_rect()
			"scene_tree": rect = _scene_tree_dock.get_parent().get_global_rect()
			"import": rect = _import_dock.get_parent().get_global_rect()
		highlighted_rects.append(rect)
	
	_update_shader_parameters()


# Searches for editor components not exposed by the engine.
func _find_hidden_components() -> void:
	var target_parent # manually search for a target parent we can search from
	for interface_child in _editor_interface.get_base_control().get_children():
		if interface_child is VBoxContainer:
			for vbox_child in interface_child.get_children():
				if vbox_child is HSplitContainer:
					target_parent = vbox_child
					break
			if target_parent:
				break
	
	# Set references accordingly
	_scene_tree_dock = target_parent.find_child("Scene", true, false)
	_import_dock = target_parent.find_child("Import", true, false)
	
	if not _scene_tree_dock:
		printerr("Scene dock not found.")
	if not _import_dock:
		printerr("Import dock not found.")


# Set overlay shader uniforms to highlight components.
func _update_shader_parameters() -> void:
	for i in range(0,MAX_RECTS):
		var param = highlighted_rects[i] if i in range(0,highlighted_rects.size()) else Rect2(0,0,0,0)
		$BG.material.set_shader_parameter(str("rect",i), param)
	$BG.queue_redraw()


# Create a dialog instance from a Tutorial.Dialog object
func _create_dialog(dialog: Tutorial.Dialog) -> PanelContainer:
	var new_dialog = preload("res://addons/tudot/dialog.tscn").instantiate()
	var text_node = new_dialog.get_node(new_dialog.get_meta("text"))
	var title_node = new_dialog.get_node(new_dialog.get_meta("title"))
	
	if not text_node or not title_node:
		printerr("Dialog node paths not found. Aborting dialog.")
		return
	
	text_node.text = dialog.text
	text_node.visible = !text_node.text.is_empty()
	new_dialog.get_node(new_dialog.get_meta("title")).text = dialog.title
	_highlight_from_dialog(dialog)
	
	return new_dialog


# Create a dialog and wait until it is dismissed.
func create_and_play_dialog(dialog : Tutorial.Dialog) -> void:
	var new_dialog = _create_dialog(dialog)
	
	if not new_dialog:
		printerr("Failed to create dialog.")
		return
	
	var dialog_button = new_dialog.get_node(new_dialog.get_meta("button"))
	
	if not dialog_button:
		printerr("Dialog button node not found. Aborting dialog.")
		return
	
	add_child(new_dialog)
	visibility_changed.connect(new_dialog.queue_free)
	
	await new_dialog.get_node(new_dialog.get_meta("button")).pressed
	
	new_dialog.queue_free()


## Configure and popup overlay.
func show() -> void:
	position = _tutor.get_window().position
	size = _tutor.get_window().size
	if not visible:
		popup()
