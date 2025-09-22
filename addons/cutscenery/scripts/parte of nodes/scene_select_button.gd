@tool
extends Button


func _on_pressed() -> void:
	EditorInterface.popup_node_selector(get_node)

func get_node(path : NodePath):
	#get_tree().edited_scene_root.get_node(path)
	var root_name = get_tree().edited_scene_root.name as String
	%LineEdit.text = root_name + "/" + str(path)
