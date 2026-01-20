extends Node2D
class_name Planet

@export_group("Quests")
@export var quest_delay_min : float = 5
@export var quest_delay_max : float = 10
@export var quest_data : QuestData
@export var quest_sprite : Node2D
@export var quest_target_sprite : Node2D

@export_group("References")
@export var animated_sprite : AnimatedSprite2D
@export var highlight_sprite : Node2D

var planet_name : String
var planet_desc : String
var planet_icon : Texture2D

var has_quest : bool = false
var quest_delay : float
var quest_timer : float = 0.0
var is_highlighted : bool = false
var is_player_colliding : bool = false
var current_quest : Quest = null

var targetted_quests : Array[Quest]
var is_quest_target : bool:
	get:
		return targetted_quests.size() > 0


func _init() -> void:
	SignalsManager.quest_accept.connect(_on_quest_accepted)
	SignalsManager.quest_end.connect(_on_quest_ended)
	
	quest_delay = randf_range(quest_delay_min, quest_delay_max)


func _process(delta: float) -> void:
	if has_quest == false && current_quest == null:
		quest_timer += delta
	
	if quest_timer >= quest_delay:
		start_quest()
		quest_timer = 0
		quest_delay = randf_range(quest_delay_min, quest_delay_max)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && is_highlighted == true && PauseSystem.instance.is_paused == false:
		if is_quest_target == true:
			end_quest_dialogue()
		else:
			start_quest_dialogue()


func start_quest_dialogue():
	SignalsManager.emit_dialogue_start(DialogueManager.DialogueType.QuestStart, current_quest.quest_data.dialogue_start_data, self, current_quest)


func end_quest_dialogue():
	SignalsManager.emit_dialogue_start(DialogueManager.DialogueType.QuestEnd, targetted_quests[0].quest_data.dialogue_end_data, self, targetted_quests[0])


func start_quest():
	has_quest = true
	
	current_quest = Quest.new()
	current_quest.quest_data = quest_data
	current_quest.planet = self
	current_quest.start_quest()
	
	if is_quest_target == false:
		quest_sprite.show()
		if is_player_colliding == true:
			highlight()


func finish_quest():
	has_quest = false
	current_quest = null
	quest_timer = 0
	quest_sprite.hide()
	unhighlight()


func set_quest_target(quest : Quest):
	quest_sprite.hide()
	quest_target_sprite.show()
	targetted_quests.append(quest)
	
	if is_player_colliding == true:
		highlight()


func highlight():
	highlight_sprite.show()
	Player.instance.interact_label.show()
	is_highlighted = true


func unhighlight():
	highlight_sprite.hide()
	Player.instance.interact_label.hide()
	is_highlighted = false


func _on_quest_accepted(quest : Quest):
	if quest.planet == self:
		quest.is_accepted = true
		quest_sprite.hide()
		has_quest = false
		unhighlight()
	if quest.target_planet == self:
		set_quest_target(quest)


func _on_quest_ended(quest : Quest):
	if current_quest == quest:
		finish_quest()
	if targetted_quests.has(quest):
		targetted_quests.erase(quest)
		if targetted_quests.size() == 0:
			quest_target_sprite.hide()
			if has_quest == true:
				quest_sprite.show()
				if is_player_colliding == true:
					highlight()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_colliding = true
		if has_quest == true || is_quest_target:
			highlight()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_colliding = false
		unhighlight()
