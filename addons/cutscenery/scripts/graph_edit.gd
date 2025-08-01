@tool
extends GraphEdit


func _ready() -> void:
	add_valid_connection_type(1, 1)



func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if !is_node_connected(from_node, from_port, to_node, to_port):
		connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if is_node_connected(from_node, from_port, to_node, to_port):
		disconnect_node(from_node, from_port, to_node, to_port)


func _on_copy_nodes_request() -> void:
	get_node
