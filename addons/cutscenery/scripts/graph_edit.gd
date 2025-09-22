@tool
extends GraphEdit

var selected_nodes : Array[CutsceneNode]
var copied_node : GraphElement

func _ready() -> void:
	add_valid_connection_type(0, 0)
	var copy_button = Button.new()
	copy_button.icon = preload("uid://bxev6igavyqkx")
	copy_button.pressed.connect(button_actions.bind("copy"))
	get_menu_hbox().add_child(copy_button)
	var paste_button = Button.new()
	paste_button.icon = preload("uid://bw188q2k5bxks")
	paste_button.pressed.connect(button_actions.bind("paste"))
	get_menu_hbox().add_child(paste_button)
	var add_button = Button.new() 
	add_button.icon = preload("uid://crwkunr7krjr4")
	add_button.pressed.connect(button_actions.bind("add"))
	get_menu_hbox().add_child(add_button)
	

func button_actions(button :String):
	match button:
		"copy":
			copy_nodes_request.emit()
		"paste":
			paste_nodes_request.emit()
		"add":
			get_owner()._on_add_node_button_pressed()
		"":
			pass


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if !is_node_connected(from_node, from_port, to_node, to_port):
		prints("connect:", from_node, from_port, to_node, to_port)
		connect_node(from_node, from_port, to_node, to_port)



func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if is_node_connected(from_node, from_port, to_node, to_port):
		prints("disconnect:", from_node, from_port, to_node, to_port)
		disconnect_node(from_node, from_port, to_node, to_port)


func _on_copy_nodes_request() -> void:
	if selected_nodes[0]:
		copied_node = selected_nodes[0].duplicate()


func _on_paste_nodes_requested() -> void:
	if !copied_node:
		return
	node_deselected.emit(selected_nodes[0])
	copied_node.position_offset += Vector2(20,20)
	node_selected.emit(copied_node)
	add_child(copied_node)


func _on_node_selected(node: Node) -> void:
	set_selected(node)
	selected_nodes.push_back(node)


func _on_node_deselected(node: Node) -> void:
	node.selected = false
	selected_nodes.erase(node)


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	nodes.all(func(node):
		get_node(node).delete_request.emit()
		)
