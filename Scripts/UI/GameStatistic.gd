extends Label
class_name GameStatistic

var seconds : float
var game_ended : bool = false

func _process(delta):
	if game_ended == true:
		return
	
	seconds += delta
	text = time_convert(floori(seconds))


func time_convert(time: int) -> String:
	var seconds = time%60
	var minutes = (time/60)%60
	var hours = (time/60)/60
	
	if floori(hours) == 0:
		return "%02d:%02d" % [minutes, seconds]
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func _on_game_end():
	game_ended = true
