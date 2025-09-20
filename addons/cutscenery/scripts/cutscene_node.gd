@tool
extends GraphNode
class_name CutsceneNode

# TODO: add documentation
const _CLOSE_SIGN = preload("res://addons/cutscenery/assets/close_sign.svgtex")
var _node_asingment_size
#region exports
@export_custom(PROPERTY_HINT_EXPRESSION, "") var expression : String

@export_group("style")
@export var icon: Texture2D
@export_group("parameters")
@export var properties : Dictionary[StringName, Variant] = {}
@export var passers : Dictionary[StringName,Variant.Type] = {}
@export var condition : String = ""
@export_group("asingment", "slot")
@export_subgroup("working")
@export var slot_to_properties : Dictionary[int, StringName] = {}
@export var slot_to_passers : Dictionary[int, StringName] = {}
@export var slot_main_return : StringName = &""
@export_subgroup("node")
@export var node_properties_asingment : Array[Dictionary]:
	set(value):
		node_properties_asingment = value
		if !node_properties_asingment.size() == _node_asingment_size:
			notify_property_list_changed()
#endregion

@onready var _titlebar : HBoxContainer = get_titlebar_hbox()

func _ready() -> void:
	var close_button : Button = Button.new()
	close_button.icon = _CLOSE_SIGN
	close_button.flat = true
	_titlebar.add_child(close_button)
	close_button.pressed.connect(_delete_request)

func _process(_delta : float):
	for port in get_input_port_count():
		update_properties_of_port(port)

func update_properties_of_port(port : int):
	var port_connection = get_connection_list_from_port(port)
	if !port_connection:
		var slot = get_input_port_slot(port)
		var property = slot_to_properties[slot]
		if node_properties_asingment == []:
			return
		for dict in node_properties_asingment:
			if dict["to_property"] == property:
				properties[property] = get_node(dict["from_node"]).get(dict["from_property"])
				get_node(dict["from_node"]).show()
				#print(properties[property])
				break
	elif port_connection:
		var slot = get_input_port_slot(port)
		var property = slot_to_properties[slot]
		for dict in node_properties_asingment:
			if dict["to_property"] == property:
				get_node(dict["from_node"]).hide()
				break


func get_property_of_node(node : StringName, port : int, is_input : bool):
	var node_access : CutsceneNode = get_parent().get_node(NodePath(node))
	var slot = get_input_port_slot(port) if is_input else get_output_port_slot(port)
	var property = node_access.slot_to_property[slot]
	var result
	if node_access.properties.has(property):
		result = node_access.properties.get(property)
	return result

func get_connection_list_from_port(port):
	if !get_parent() is GraphEdit:
		return 
	var connections = get_parent().get_connection_list_from_node(name)
	var result = []
	for connection in connections:
		var dict = {}
		if connection["from_node"] == name and connection["from_port"] == port:
			dict["node"] = connection["to_node"]
			dict["port"] = connection["to_port"]
			dict["type"] = "left"
			result.push_back(dict)
		elif connection["to_node"] == name and connection["to_port"] == port:
			dict["node"] = connection["from_node"]
			dict["port"] = connection["from_port"]
			dict["type"] = "right"
			result.push_back(dict)
	return result

func _validate_property(property: Dictionary) -> void:
	if property["name"] == "node_properties_asingment":
		_node_asingment_size = node_properties_asingment.size()
		if !_node_asingment_size:
			return
		if !node_properties_asingment[-1] == {}:
			return
		node_properties_asingment[-1] = ({
			"from_node" : NodePath(),
			"from_property" : "",
			"to_property" : ""
		})

func _delete_request():
	queue_free()

func get_singletons_dictionary() -> Dictionary[String, Object]:
	var dict
	for sin_name in Engine.get_singleton_list():
		dict[sin_name] = Engine.get_singleton(sin_name)
	return dict

func execute_expression(passed_properties : Dictionary[StringName, Variant] = {}):
	var executor := Expression.new()
	#region properties
	for key in passed_properties.keys():
		if properties.keys().has(key):
			properties[key] = passed_properties[key]
	properties.merge(get_singletons_dictionary())
	#endregion
	#region parsing
	var parsing = executor.parse(expression, properties.keys()) #parses the text
	if parsing:
		printerr(name, " cutscene error: ", executor.get_error_text()) #BUG print 1
		return
	#endregion
	#region execution
	var result 
	if check_subexpression(condition):
		result = executor.execute(properties.values(), self)
	else:
		print(" expression correct, but the condition isn't true")
		return
	if executor.has_execute_failed():
		printerr(name, " cutscene error: ", executor.get_error_text()) #BUG print 2
		return
	print(name, " result: ", result) #for checking the result
	return result
	#endregion

func check_subexpression(subexpression : String) -> Variant:
	var subexpression_checker = Expression.new()
	var error = subexpression_checker.parse(subexpression, properties.keys())
	if error : return
	var check_value = subexpression_checker.execute(properties.values(), self)
	if !subexpression_checker.has_execute_failed():
		return check_value
	else:
		return
