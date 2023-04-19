extends GutTest

@onready var tutorial = Tutorial.new()


func test_all_tutorials():
	var path = "res://tutorials/"
	var dir = DirAccess.open(path)
	var files = dir.get_files()
	
	for file in files:
		if file.ends_with(".tres"):
			var tutorial_file : Tutorial = load(path+file)
			tutorial_file.parse()
	
	assert_has(files, "dialogs.tres")
	assert_has(files, "highlights.tres")


func test_empty_tutorial_text():
	tutorial.parse("")
	assert_eq(tutorial.steps.size(), 0)


func test_single_step_no_dialogs():
	tutorial.parse("# Step 1\nNo dialogs here.")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].title, "Step 1")
	assert_eq(tutorial.steps[0].dialogs.size(), 0)


func test_multiple_steps_no_dialogs():
	tutorial.parse("# Step 1\nNo dialogs here.\n# Step 2\nNo dialogs here too.")
	assert_eq(tutorial.steps.size(), 2)
	assert_eq(tutorial.steps[0].title, "Step 1")
	assert_eq(tutorial.steps[0].dialogs.size(), 0)
	assert_eq(tutorial.steps[1].title, "Step 2")
	assert_eq(tutorial.steps[1].dialogs.size(), 0)


func test_single_step_multiple_dialogs():
	tutorial.parse("# Step 1\n## Dialog 1\nHello, World!\n## Dialog 2\nWelcome to the tutorial.")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].title, "Step 1")
	assert_eq(tutorial.steps[0].dialogs.size(), 2)
	assert_eq(tutorial.steps[0].dialogs[0].title, "Dialog 1")
	assert_eq(tutorial.steps[0].dialogs[0].text, "Hello, World!")
	assert_eq(tutorial.steps[0].dialogs[1].title, "Dialog 2")
	assert_eq(tutorial.steps[0].dialogs[1].text, "Welcome to the tutorial.")


func test_multiple_steps_and_dialogs():
	tutorial.parse("# Step 1\n## Dialog 1\nHello, World!\n# Step 2\n## Dialog 1\nWelcome to the tutorial.")
	assert_eq(tutorial.steps.size(), 2)
	assert_eq(tutorial.steps[0].title, "Step 1")
	assert_eq(tutorial.steps[0].dialogs.size(), 1)
	assert_eq(tutorial.steps[0].dialogs[0].title, "Dialog 1")
	assert_eq(tutorial.steps[0].dialogs[0].text, "Hello, World!")
	assert_eq(tutorial.steps[1].title, "Step 2")
	assert_eq(tutorial.steps[1].dialogs.size(), 1)
	assert_eq(tutorial.steps[1].dialogs[0].title, "Dialog 1")
	assert_eq(tutorial.steps[1].dialogs[0].text, "Welcome to the tutorial.")


func test_no_dialog_title():
	tutorial.parse("# Title\n## \nThis dialog's title should match the step's.")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].title, "Title")
	assert_eq(tutorial.steps[0].dialogs.size(), 1)
	assert_eq(tutorial.steps[0].dialogs[0].title, "Title")


func test_highlights():
	tutorial.parse("# Step 1\n## Dialog 1\nHello, World!\n;highlight scene_tree\n## Dialog 2\nWelcome to the tutorial.\n;highlight file_system")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].dialogs.size(), 2)
	assert_eq(tutorial.steps[0].dialogs[0].highlights, ["scene_tree"])
	assert_eq(tutorial.steps[0].dialogs[1].highlights, ["file_system"])


func test_empty_highlight_line():
	tutorial.parse("# Step 1\n## Dialog 1\nHello, World!\n;highlight \n;highlight inspector")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].dialogs.size(), 1)
	assert_eq(tutorial.steps[0].dialogs[0].highlights, ["inspector"])


func test_improper_highlight_line():
	tutorial.parse("# Step 1\n## Dialog 1\nHello, World!\n; highlight tutor\n;highlight scene_tree")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].dialogs.size(), 1)
	assert_eq(tutorial.steps[0].dialogs[0].highlights, ["scene_tree"])


func test_improper_markdown_headings():
	tutorial.parse("Step 1\n## Dialog 1\nHello, World!")
	assert_eq(tutorial.steps.size(), 1)


func test_extra_whitespace():
	tutorial.parse("   # Step 1   \n  ## Dialog 1  \n   Hello, World!  \n   ;highlight   inspector  ")
	assert_eq(tutorial.steps.size(), 1)
	assert_eq(tutorial.steps[0].dialogs.size(), 0)
