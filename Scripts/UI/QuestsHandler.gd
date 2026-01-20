extends Control
class_name QuestsHandler

@export var quest_title : Label
@export var quests_container : Container
@export var quest_scene : PackedScene

var quests_dictionary : Dictionary[Quest, RichTextLabel]


func _init() -> void:
	SignalsManager.quest_accept.connect(_on_quest_accepted)
	SignalsManager.quest_end.connect(_on_quest_ended)


func _ready() -> void:
	quest_title.hide()


func add_quest(quest : Quest):
	quest_title.show()
	var quest_text : RichTextLabel = quest_scene.instantiate() as RichTextLabel
	quest_text.text = DialogueManager.replace_text_words(quest.quest_data.quest_desc, quest)
	quests_container.add_child(quest_text)
	quests_dictionary[quest] = quest_text


func remove_quest(quest : Quest):
	quests_dictionary[quest].queue_free()
	quests_dictionary.erase(quest)
	if quests_dictionary.keys().size() == 0:
		quest_title.hide()


func _on_quest_accepted(quest : Quest):
	add_quest(quest)


func _on_quest_ended(quest : Quest):
	remove_quest(quest)
