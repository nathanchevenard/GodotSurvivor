extends CanvasLayer
class_name DialogueManager

enum DialogueType {
	QuestStart,
	QuestEnd,
}

@export var event_name_label : Label
@export var event_icon : TextureRect
@export var event_desc_label : Label
@export var event_text_label : RichTextLabel
@export var accept_quest_buttons : Control
@export var end_quest_buttons : Control

static var object_text_color : Color = Color.CORNFLOWER_BLUE
static var planet_text_color : Color = Color.LIGHT_SALMON
static var value_text_color : Color = Color.AQUAMARINE

var current_dialogue : DialogueData = null
var current_quest : Quest = null


func _init() -> void:
	SignalsManager.dialogue_start.connect(start_dialogue)


func _ready() -> void:
	hide()


func start_dialogue(type : DialogueType, data : DialogueData, planet : Planet, quest : Quest):
	PauseSystem.instance.start_pause(true)
	
	current_dialogue = data
	current_quest = quest
	
	event_name_label.text = planet.planet_name
	event_icon.texture = planet.planet_icon
	event_desc_label.text = planet.planet_desc
	
	match type:
		DialogueType.QuestStart:
			accept_quest_buttons.show()
			end_quest_buttons.hide()
			event_text_label.text = replace_text_words(data.event_text, current_quest)
		DialogueType.QuestEnd:
			end_quest_buttons.show()
			accept_quest_buttons.hide()
			event_text_label.text = replace_text_words(data.event_text, current_quest)
	
	show()


static func replace_text_words(text : String, quest : Quest) -> String:
	if quest == null:
		return text
	
	text = text.replace("{OBJECT}", "[color=" + object_text_color.to_html() + "]" + quest.object_name + "[/color]")
	text = text.replace("{PLANET}", "[color=" + planet_text_color.to_html() + "]" + quest.planet.planet_name + "[/color]")
	if quest.target_planet != null:
		text = text.replace("{TARGET_PLANET}", "[color=" + planet_text_color.to_html() + "]" + quest.target_planet.planet_name + "[/color]")
	text = text.replace("{TARGET_VALUE}", "[color=" + value_text_color.to_html() + "]" + str(quest.quest_data.target_value) + "[/color]")
	return text


func _on_accept_button_pressed() -> void:
	SignalsManager.emit_quest_accept(current_quest)
	current_dialogue = null
	current_quest = null
	PauseSystem.instance.stop_pause()
	hide()


func _on_ignore_button_pressed() -> void:
	PauseSystem.instance.stop_pause()
	hide()


func _on_end_quest_button_pressed() -> void:
	SignalsManager.emit_quest_end(current_quest)
	PauseSystem.instance.stop_pause()
	hide()
