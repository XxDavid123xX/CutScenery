@tool
extends GraphNode
class_name CutsceneNode

# TODO: add documentation
const _CLOSE_SIGN = preload("res://addons/cutscenery/assets/close_sign.svgtex")
var _node_asingment_size : int
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

func _validate_property(property: Dictionary) -> void:
	if property["name"] == "node_properties_asingment":
		_node_asingment_size = node_properties_asingment.size()
		node_properties_asingment[node_properties_asingment.size() - 1] = ({
			"from_node" : NodePath(),
			"from_property" : "",
			"to_property" : ""
		})

func _delete_request():
	delete_request.emit()
	EditorInterface.get_editor_undo_redo().create_action("cutscene node deleted")
	EditorInterface.get_editor_undo_redo().add_undo_reference(self.duplicate())
	queue_free()
	EditorInterface.get_editor_undo_redo().commit_action()

func execute_expression(passed_properties : Dictionary[StringName, Variant] = {}):
	var executor := Expression.new()
	#region properties
	for key in passed_properties.keys():
		if properties.keys().has(key):
			properties[key] = passed_properties[key]
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
