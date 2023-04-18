@tool
extends EditorPlugin

var editor_interface : EditorInterface
var palette : EditorCommandPalette

func _enter_tree():
	editor_interface = get_editor_interface()
	palette = editor_interface.get_command_palette()
	palette.add_command("Re-enable plugins", "re-enable", re_enable)


func _exit_tree():
	palette.remove_command("re-enable")


func re_enable():
	editor_interface.set_plugin_enabled("tutor", false)
	#editor_interface.set_plugin_enabled("editor_nav", false)
	await project_settings_changed
	editor_interface.set_plugin_enabled("tutor", true)
	#editor_interface.set_plugin_enabled("editor_nav", true)
