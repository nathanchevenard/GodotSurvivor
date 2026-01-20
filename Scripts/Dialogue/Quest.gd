class_name Quest

var quest_data : QuestData
var planet : Planet
var is_accepted : bool = false
var object_name : String
var target_planet : Planet


func start_quest():
	match quest_data.quest_type:
		QuestData.QuestType.Delivery:
			if quest_data.available_object_names.size() == 0:
				quest_data.available_object_names = quest_data.object_names.duplicate()
			
			var object : String = quest_data.available_object_names.pick_random()
			quest_data.available_object_names.erase(object)
			object_name = object
			
			while target_planet == null || target_planet == planet:
				target_planet = PlanetManager.instance.planets.pick_random()
