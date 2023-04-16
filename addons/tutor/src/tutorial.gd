extends Resource

var steps : Array[Step] = []

func parse_text(text : String):
	var text_array := text.split("#", true) # delimited by # symbol
	var current_step : Step
	var hash_count = 0
	
	while text_array.size() > 0:
		# new step and dialog definitions are indicated by amount of # symbols
		if text_array[0].is_empty(): # empty strings are # symbols, split from text param
			hash_count += 1
			text_array.remove_at(0)
			continue
		
		if hash_count == 1: # new step
			current_step = Step.new()
			steps.append(current_step)
			current_step.title = text_array[0].strip_edges()
		elif hash_count == 2: ## new dialog
			var dialog = Dialog.new()
			current_step.dialogs.append(dialog)
			dialog.text = text_array[0].strip_edges()
			text_array.remove_at(0)
		
		if text_array.size() > 0:
			text_array.remove_at(0)

func get_steps_string():
	var string = ""
	
	for step in steps:
		string += step.title + "\n"
		for dialog in step.dialogs:
			string += "\t" + dialog.text + "\n"
	
	return string

class Step:
	var title := "Tutorial" # shown in contents and dialog titlebar
	var task := "Follow the on-screen prompts." # displays in dock
	var dialogs : Array[Dialog] = []
	var conditions : Array[Condition] = []

class Dialog:
	var text = ""
	var highlight = []

class Condition:
	enum Type {ONE_SHOT, CONTINUOUS}
	enum Operator {EQUALS, GREATER_THAN, LESS_THAN, GREATER_EQUAL, LESS_EQUAL}
	var object : Object
	var property : String
	var operator : Operator = Operator.EQUALS
	var requires : Array[Condition] = []
