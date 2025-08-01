@tool
extends Tree

@onready var root = create_item()
@export var item_structure : Dictionary[String, Array]
@export var category_order : Array[int]
var items : Dictionary


func _ready() -> void:
	setup()

func setup():
	for number in category_order: # first for
		var item = item_structure.keys()[number]
		items[item] = create_item(root)
		items[item].set_text(0, item)
	for i in category_order: # second for
		var item = item_structure.keys()[i]
		for j in item_structure[item]:
			var child = create_item(items[item])
			items[j] = child
			child.set_text(0, j)
			child.add_button(0, null)
			child.get_parent().collapsed = true
