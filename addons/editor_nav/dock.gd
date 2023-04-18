@tool extends Control

var _editor_interface : EditorInterface

@onready var tree = $Tree

func _ready():
	add_children_to_tree(_editor_interface.get_base_control(), tree.create_item())

func add_children_to_tree(parent, tree_item):
	for child in parent.get_children():
		var new_item = tree.create_item(tree_item)
		new_item.set_text(0, child.name)
		new_item.set_text(1, child.get_class())
		
		add_children_to_tree(child, new_item)
