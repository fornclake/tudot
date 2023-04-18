extends GutTest

@onready var tutorial = Tutorial.new()


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
















