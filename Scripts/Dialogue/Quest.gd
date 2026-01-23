class_name Quest

var quest_data : QuestData
var planet : Planet
var object_name : String
var target_planet : Planet

var is_accepted : bool = false
var is_finished : bool = false
var current_value : float = 0


func init_quest():
	match quest_data.quest_type:
		QuestData.QuestType.Delivery:
			if quest_data.available_object_names.size() == 0:
				quest_data.available_object_names = quest_data.object_names.duplicate()
			
			var object : String = quest_data.available_object_names.pick_random()
			quest_data.available_object_names.erase(object)
			object_name = object
			
			while target_planet == null || target_planet == planet:
				target_planet = PlanetManager.instance.planets.pick_random()


func accept_quest():
	is_accepted = true
	
	match quest_data.quest_type:
		QuestData.QuestType.Stay:
			planet.stay_progress_bar.max_value = quest_data.target_value
			planet.quest_stay_area.show()
			planet.stay_progress_bar.show()


func end_quest():
	is_finished = true
	
	match quest_data.quest_type:
		QuestData.QuestType.Stay:
			planet.quest_stay_area.hide()
			planet.stay_progress_bar.hide()


func add_value(value : float):
	current_value += value
	
	if current_value >= quest_data.target_value:
		end_quest()
		target_planet = planet
		planet.set_quest_target(self)
