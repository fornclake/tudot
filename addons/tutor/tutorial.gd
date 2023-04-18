@tool class_name Tutorial extends Resource
## Tutorial resource object.
##
## Parses steps and commands from markdown text.

signal updated

@export_multiline var text : String = ""

var steps : Array[Step] = []

class Step:
	var title := "Tutorial"
	var description := "Follow the on-screen prompts." # displays in dock
	var dialogs : Array[Dialog] = []
	var conditions : Array[Condition] = []

class Dialog:
	var title = ""
	var text = ""
	var highlights = []

class Condition:
	enum Type {ONE_SHOT, CONTINUOUS}
	enum Operator {EQUALS, GREATER_THAN, LESS_THAN, GREATER_EQUAL, LESS_EQUAL}
	var object : Object
	var property : String
	var operator : Operator = Operator.EQUALS
	var requires : Array[Condition] = []


## Parses text and populates steps array.
func parse(p_text : String = text) -> void:
	steps = []
	
	# Add a new line if there isn't one for heading tags
	if p_text.begins_with("# "):
		p_text = "\n" + p_text
	p_text = _tag_headings(p_text)
	
	# Split text by step and create step objects
	var step_split = p_text.split("</s>", false)
	for step_text in step_split:
		if step_text.strip_escapes().is_empty():
			continue
		var new_step = _create_step_from_text(step_text)
		steps.append(new_step)
	
	updated.emit()


# Mark headings with temporary tags
func _tag_headings(text : String) -> String:
	return text.replace("\n## ", "</d>").replace("\n# ", "</s>") # dialog, step tag


# Constructs a step object from a string.
func _create_step_from_text(step_text : String) -> Step:
	var new_step = Step.new()
	var title = step_text.split("\n", true, 2)[0].split("</d>")[0]
	new_step.title = title
	
	# Create dialog objects
	var dialog_split = [] if step_text.find("</d>") == -1 else step_text.right(-step_text.find("</d>")).split("</d>", false)
	while dialog_split.size() > 0:
		var new_dialog = _create_dialog_from_text(dialog_split[0], title)
		new_step.dialogs.append(new_dialog)
		title = new_dialog.title
		dialog_split.remove_at(0)
	
	return new_step


# Constructs a dialog object from a string.
func _create_dialog_from_text(dialog_text : String, dialog_title : String) -> Dialog:
	var new_dialog = Dialog.new()
	var title_split = dialog_text.split("\n", false, 1)
	print(title_split)
	
	# Update title if there is one
	if title_split.size() > 1:
		dialog_title = title_split[0]
		title_split.remove_at(0)
	
	# Read lines for commands
	var dialog_body = title_split[0]
	var lines = dialog_body.split("\n")
	for line in lines:
		if line.begins_with(";highlight "):
			# add parameters to highlights array, then remove line from displayed dialog text
			new_dialog.highlights.append(line.trim_prefix(";highlight ").strip_edges())
			dialog_body = dialog_body.replace(line, "").strip_escapes()
	
	new_dialog.title = dialog_title
	new_dialog.text = dialog_body
	
	return new_dialog
