@tool class_name Tutorial extends Resource
## Tutorial resource object.
##
## Parses steps and commands from markdown text.

signal updated

@export_multiline var text : String = "":
	get:
		_parse_text(text)
		return text

var steps = []

class Step:
	var title := "Tutorial"
	var description := "Follow the on-screen prompts." # displays in dock
	var dialogs : Array[Dialog] = []
	var conditions : Array[Condition] = []

class Dialog:
	var title = ""
	var text = ""
	var highlight = []

class Condition:
	enum Type {ONE_SHOT, CONTINUOUS}
	enum Operator {EQUALS, GREATER_THAN, LESS_THAN, GREATER_EQUAL, LESS_EQUAL}
	var object : Object
	var property : String
	var operator : Operator = Operator.EQUALS
	var requires : Array[Condition] = []


func _parse_text(text : String):
	steps = []
	
	# mark headings with temporary tags; </d>:dialog </s>:step
	text = text.replace("\n## ", "</d>").replace("\n# ", "</s>")
	
	# split text by step and create step objects
	var step_split = text.split("</s>", false)
	for step_text in step_split:
		# create step object and set title
		var new_step = Step.new()
		var dialog_split := step_text.split("</d>", false)
		
		new_step.title = dialog_split[0]
		dialog_split.remove_at(0)
		
		var dialog_title = new_step.title
		
		# create dialog objects
		while dialog_split.size() > 0: # try for
			var new_dialog = Dialog.new()
			var title_split = dialog_split[0].split("\n", true, 1)
			
			# update title if there is one
			if not title_split[0].is_empty():
				dialog_title = title_split[0]
			
			new_dialog.title = dialog_title
			new_dialog.text = title_split[1]
			new_step.dialogs.append(new_dialog)
			
			dialog_split.remove_at(0)
		
		steps.append(new_step)
	
	updated.emit()
