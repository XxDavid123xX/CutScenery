@tool
extends Control

const CUTSCENE_TAB = preload("res://addons/cutscenery/scenes/cutscene_tab.tscn")

@onready var tab_container : TabContainer = $VBoxContainer/TabContainer

func _ready() -> void:
	var tab_bar : TabBar = tab_container.get_tab_bar()
	tab_bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
	tab_bar.tab_close_pressed.connect(close_tab)

func close_tab(tab : int):
	tab_container.get_tab_control(tab).queue_free()


func _on_new_cutscene_pressed() -> void:
	tab_container.add_child(CUTSCENE_TAB.instantiate())
