@tool
extends ScrollContainer

@onready var overlay = %Overlay
@onready var bg := %Overlay/BG

var main_window : Window
var editor_interface : EditorInterface
var _scene_tree_dock
var _import_dock

var highlit_rects : Array[Rect2] = []:
	set(value):
		highlit_rects = value
		_set_shader_parameters()

var tutor_rect:
	get: return get_global_rect()

var inspector_rect:
	get: return editor_interface.get_inspector().get_global_rect()

var file_system_rect:
	get: return editor_interface.get_file_system_dock().get_global_rect()

var scene_tree_rect:
	get: return _scene_tree_dock.get_global_rect()

var import_rect:
	get: return _import_dock.get_global_rect()


func _enter_tree():
	var hsplit_node
	for interface_child in editor_interface.get_base_control().get_children():
		if interface_child is VBoxContainer:
			for vbox_child in interface_child.get_children():
				if vbox_child is HSplitContainer:
					hsplit_node = vbox_child
	_scene_tree_dock = hsplit_node.find_child("Scene", true, false)
	_import_dock = hsplit_node.find_child("Import", true, false)

func _on_next_pressed():
	main_window = get_window()
	
	overlay.position = main_window.position
	overlay.size = main_window.size
	overlay.popup()
	
	create_dialog("hey there!")
	highlit_rects = [scene_tree_rect]


func create_dialog(text):
	var dialog = preload("res://addons/tutor/ui/next_dialog.tscn").instantiate()
	overlay.add_child(dialog)
	
	var dialog_button : Button = dialog.get_node(dialog.get_meta("button"))
	var dialog_label : RichTextLabel = dialog.get_node(dialog.get_meta("label"))
	dialog_button.pressed.connect(overlay.hide)
	dialog_button.pressed.connect(dialog.queue_free)
	
	dialog_label.text = text


func _set_shader_parameters(): # map dimmer's uniforms to highlit rects
	var used_rects = highlit_rects.size()
	
	for i in used_rects:
		bg.material.set_shader_parameter(str("rect",i), highlit_rects[i])
	for i in range(used_rects,4):
		bg.material.set_shader_parameter(str("rect",i), Rect2(0,0,0,0))
	
	bg.queue_redraw()
