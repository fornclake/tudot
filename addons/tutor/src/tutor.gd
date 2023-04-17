@tool
extends ScrollContainer

@export var tutorial : Tutorial

const MAX_RECTS = 4 # amount of shader uniforms in Overlay/BG

# holds up to 4 rectangles that will not be dimmed while the overlay is visible
var highlit_rects : Array[Rect2] = []:
	set(value):
		highlit_rects = value
		_set_shader_parameters()

# rectangle getter functions. can't store rects because of window size changes
var tutor_rect:
	get: return get_parent().get_global_rect()
var inspector_rect:
	get: return editor_interface.get_inspector().get_node("../../").get_global_rect()
var file_system_rect:
	get: return editor_interface.get_file_system_dock().get_parent().get_global_rect()
var scene_tree_rect:
	get: return _scene_tree_dock.get_parent().get_global_rect()
var import_rect:
	get: return _import_dock.get_parent().get_global_rect()

var editor_interface : EditorInterface
var _scene_tree_dock # _*_dock's are set by _find_hidden_docks
var _import_dock
var _node_dock

@onready var overlay = $Overlay
@onready var bg := $Overlay/BG
@onready var steps = %Steps

func _ready():
	highlit_rects = []
	_set_shader_parameters()
	_find_hidden_docks()


func _set_shader_parameters(): # set dim shader uniforms to highlit_rects
	for i in range(0,MAX_RECTS):
		var param = highlit_rects[i] if i in range(0,highlit_rects.size()) else Rect2(0,0,0,0)
		bg.material.set_shader_parameter(str("rect",i), param)
	
	bg.queue_redraw()


func _find_hidden_docks(): # brute searching for docks not exposed by the engine
	# searching from root would point us to the wrong "Scene" control
	var target_parent # we will manually search for a target parent we can search from
	for interface_child in editor_interface.get_base_control().get_children():
		if interface_child is VBoxContainer:
			for vbox_child in interface_child.get_children():
				if vbox_child is HSplitContainer:
					target_parent = vbox_child
	
	_scene_tree_dock = target_parent.find_child("Scene", true, false)
	_import_dock = target_parent.find_child("Import", true, false)


func _on_go_pressed():
	tutorial.refresh()
	steps.text = tutorial.text
	
	dim_screen()
	
	for step in tutorial.steps:
		var dialogs : Array = step.dialogs
		while dialogs.size() > 0:
			await create_dialog(dialogs[0].text, dialogs[0].title)
			dialogs.pop_front()
	
	overlay.hide()


func dim_screen():
	overlay.position = get_window().position
	overlay.size = get_window().size
	overlay.popup()


func undim_screen():
	overlay.hide()


func create_dialog(text, title): # popup dialogs that pause progression until dismissed
	var dialog = preload("res://addons/tutor/ui/next_dialog.tscn").instantiate()
	overlay.visibility_changed.connect(dialog.queue_free) # escape if overlay is closed
	overlay.add_child(dialog)
	
	var title_node : Label = dialog.get_node(dialog.get_meta("title"))
	var text_node : Label = dialog.get_node(dialog.get_meta("text"))
	
	title_node.text = title
	text_node.text = text
	
	await dialog.get_node(dialog.get_meta("button")).pressed
	
	dialog.queue_free()
