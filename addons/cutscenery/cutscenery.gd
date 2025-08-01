@tool
extends EditorPlugin


var main_scene : Control = preload("res://addons/cutscenery/scenes/main_scene.tscn").instantiate()

func _enable_plugin() -> void:
	add_autoload_singleton("CutSceneryCutscenesManager", "res://addons/cutscenery/scripts/cutscenery_cutscenes_manager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("CutSceneryCutscenesManager")


func _enter_tree() -> void:
	EditorInterface.get_editor_main_screen().add_child(main_scene)
	_make_visible(false)


func _exit_tree() -> void:
	main_scene.queue_free()


func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	main_scene.visible = visible

func _get_plugin_name() -> String:
	return "CutScenery"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
