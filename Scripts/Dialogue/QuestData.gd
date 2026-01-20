extends Resource
class_name QuestData

enum QuestType {
	Delivery,
	Kill,
}

@export var quest_type : QuestType
@export_multiline var quest_desc : String
@export var dialogue_start_data : DialogueData
@export var dialogue_end_data : DialogueData
@export var object_names : Array[String]

var available_object_names : Array[String] = object_names.duplicate()
