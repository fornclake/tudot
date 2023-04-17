@tool extends Control

var _editor_interface : EditorInterface

@onready var tree = $Tree

func _ready():
	add_children_to_tree(_editor_interface, tree.create_item())

func add_children_to_tree(parent, tree_item):
	for child in parent.get_children():
		var new_item = tree.create_item()
		new_item.set_text(0, child.name)
		print(child.name)
		add_children_to_tree(child, tree_item)
