@tool
extends Control

var cutscene_ref : Cutscene = Cutscene.new()
var first_time_saved : bool = true
var showed_name : String



func _ready() -> void:
	first_time_saved = !FileAccess.file_exists(cutscene_ref.resource_path)
	if first_time_saved:
		showed_name = "[unsaved]"
	else:
		showed_name = cutscene_ref.resource_name
	$"VBoxContainer/PanelContainer/HBoxContainer/Save button".pressed.connect(save_cutscene.bind(first_time_saved))

func _process(_delta: float) -> void:
	name = showed_name
	

#region cutscene managing
func save_cutscene(first_time : bool) -> void:
	var file_dialog_instance = EditorFileDialog.new()
	for node in %GraphEdit.get_children():
		if node is CutsceneNode or node is GraphFrame:
			cutscene_ref.add_node(node)
	if first_time:
		file_dialog_instance.title = "save a Cutscene"
		file_dialog_instance.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		EditorInterface.popup_dialog_centered(file_dialog_instance)
		await file_dialog_instance.dir_selected
		cutscene_ref.resource_path = file_dialog_instance.current_dir + cutscene_ref.resource_name
		showed_name = cutscene_ref.resource_name
		first_time_saved = false
		print("cutscene ", cutscene_ref.resource_name, " saved")
	
	
	CutSceneryCutscenesManager.save_cutscene(name, cutscene_ref.resource_path, cutscene_ref)


func _on_add_node_button_pressed() -> void:
	var cutscene_node_adder = preload("res://addons/cutscenery/scenes/add_cutscene_node.tscn").instantiate()
	EditorInterface.popup_dialog_centered(cutscene_node_adder, Vector2i(500, 500))
	cutscene_node_adder.passing_node.connect(add_node)

func add_node(packed_node: CutsceneNodeMetadata):
	var node : CutsceneNode = packed_node.scene.instantiate()
	%GraphEdit.add_child(node, true)
#endregion
