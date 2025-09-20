@tool
extends Tree

@onready var root = create_item()
@export var item_structure : Dictionary[String, Array]
@export var category_order : Array[int]
@export var category_colors : PackedColorArray
var items : Dictionary[String, TreeItem]

func _ready() -> void:
	setup()
	#print(items)

func setup():
	for number in category_order: # first for
		var item = item_structure.keys()[number]
		items[item] = (create_item(root) as TreeItem)
		items[item].set_text(0, item)
		items[item].set_custom_color(0, category_colors[number])
	for i in category_order: # second for
		var item = item_structure.keys()[i]
		for j in item_structure[item]:
			var child = create_item(items[item])
			items[j] = child
			child.set_text(0, j)
			child.get_parent().collapsed = true
