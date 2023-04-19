@tool class_name Tutorial extends Resource

## Stores tutorial step data from parsed markdown text.
##
## The tutorial script uses a simple markdown-like format to define tutorial steps and dialogs.
## It may contain headings, dialogs, and highlight commands.[br]
## [codeblock]
## # Step 1
## ## Dialog 1
## This text is displayed under the dialog box titled "Dialog 1"
## ## Dialog 2
## This dialog box highlights all available docks
## ;highlight scene_tree
## ;highlight file_system
## ;highlight inspector
## ;highlight tutor
## # Step 2
## ## 
## Dialogs with no titles will use the step's title.
## [/codeblock]

## Emitted when text has been parsed.
signal parsed

## Markdown text to be parsed.
@export_multiline var text : String

## Holds parsed step data.
var steps : Array[Step] = []

# Step class holds information about each step in the tutorial.
class Step:
	var title := "Tutorial"
	var dialogs : Array[Dialog] = []
	
	func _init(p_title := ""):
		title = p_title

# Dialog class holds information about the dialog within a tutorial step.
class Dialog:
	var title = ""
	var text = ""
	var highlights = [] # editor controls to highlight while dialog active
	
	func _init(p_title := ""):
		title = p_title


## Parses text and populates steps array. [member p_text] defaults to [member text] property.
func parse(p_text : String = text) -> void:
	if p_text.is_empty():
		push_error("Text property is empty. Skipping parsing.")
		return
	
	steps = []
	
	# Ensure text begins with new line for heading tags.
	p_text = "\n" + p_text.strip_edges()
	p_text = _tag_headings(p_text)
	
	# Split text by step and create step objects.
	var step_split := p_text.split("</s>", false)
	for step_text in step_split:
		if not step_text.strip_escapes().is_empty():
			steps.append(_create_step_from_text(step_text))
	
	parsed.emit()


# Mark headings with temporary tags.
func _tag_headings(text : String) -> String:
	return text.replace("\n## ", "</d>").replace("\n# ", "</s>") # dialog, step tag


# Constructs a step object from a string.
func _create_step_from_text(step_text : String) -> Step:
	var title = step_text.get_slice("\n", 0).get_slice("</d>", 0).strip_edges()
	var new_step = Step.new(title)
	
	# Skip this loop if no dialog tags are found.
	var dialog_split = [] if step_text.find("</d>") == -1 else step_text.right(-step_text.find("</d>")).split("</d>", false)
	for dialog_text in dialog_split:
		var new_dialog = _create_dialog_from_text(title, dialog_text)
		new_step.dialogs.append(new_dialog)
		title = new_dialog.title
	
	return new_step


# Constructs a dialog object from a string.
func _create_dialog_from_text(dialog_title : String, dialog_text : String) -> Dialog:
	var lines := dialog_text.split("\n")
	
	if not lines[0].is_empty():
		dialog_title = lines[0].strip_edges()
		lines.remove_at(0)
	
	var new_dialog = Dialog.new(dialog_title)
	
	for line in lines:
		line = line.strip_escapes()
		if line.begins_with(";highlight ") and not line.split(" ")[1].is_empty():
			new_dialog.highlights.append(line.trim_prefix(";highlight ").strip_edges())
		else:
			new_dialog.text += line
	
	return new_dialog
