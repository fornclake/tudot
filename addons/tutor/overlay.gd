@tool extends Popup

const MAX_RECTS = 4 # Maximum number of shader uniforms in Overlay/BG

# Rectangles passed to overlay shader
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
	
	if not _hidden_components_found:
		_find_hidden_components()
	
	for highlight in dialog.highlights:
		var rect : Rect2
		match highlight:
			"inspector": rect = _editor_interface.get_inspector().get_node("../../").get_global_rect()
			"tutor": rect = _tutor.dock.get_global_rect()
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
	
	# Set references accordingly
	_scene_tree_dock = target_parent.find_child("Scene", true, false)
	_import_dock = target_parent.find_child("Import", true, false)


# Set overlay shader uniforms to highlight components.
func _update_shader_parameters() -> void:
	for i in range(0,MAX_RECTS):
		var param = highlighted_rects[i] if i in range(0,highlighted_rects.size()) else Rect2(0,0,0,0)
		$BG.material.set_shader_parameter(str("rect",i), param)
	
	$BG.queue_redraw()


## Configure and popup overlay.
func show() -> void:
	position = _tutor.get_window().position
	size = _tutor.get_window().size
	popup()


# Create a dialog and wait until it is dismissed.
func create_and_play_dialog(dialog : Tutorial.Dialog) -> void:
	var new_dialog = _create_dialog(dialog)
	
	add_child(new_dialog)
	visibility_changed.connect(new_dialog.queue_free)
	
	await new_dialog.get_node(new_dialog.get_meta("button")).pressed
	
	new_dialog.queue_free()


# Create a dialog instance from a Tutorial.Dialog object
func _create_dialog(dialog: Tutorial.Dialog) -> PanelContainer:
	var new_dialog = preload("res://addons/tutor/dialog.tscn").instantiate()
	var text_node = new_dialog.get_node(new_dialog.get_meta("text"))
	
	text_node.text = dialog.text
	text_node.visible = !text_node.text.is_empty()
	new_dialog.get_node(new_dialog.get_meta("title")).text = dialog.title
	_highlight_from_dialog(dialog)
	
	return new_dialog



