@tool
extends Node


var cutscenes : Dictionary[StringName,Cutscene]

func save_cutscene(name : StringName, path : String, cutscene : Cutscene):
	cutscenes[name] = cutscene
	ResourceSaver.save(cutscene, path)
