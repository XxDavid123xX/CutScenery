@tool
extends Window

@export var nodes : Dictionary[String, CutsceneNodeMetadata]
signal  passing_node(packed_node : CutsceneNodeMetadata)

func _ready() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = EditorInterface.get_editor_settings().get_setting("interface/theme/base_color")
	$Control/PanelContainer.add_theme_stylebox_override(&"panel", background)



func _on_close_requested():
	visible = false
	queue_free()


func _on_add_pressed() -> void:
	var node
	if nodes.has(%Tree.items.find_key(%Tree.get_selected())):
		node = nodes[%Tree.items.find_key(%Tree.get_selected())]
	if node:
		passing_node.emit(node)
		close_requested.emit()
