extends Label
class_name GameStatistic

static var timer : float
var game_ended : bool = false

static var seconds : int = 0
static var minutes : int = 0
static var hours : int = 0


func _ready() -> void:
	timer = 0


func _process(delta):
	if game_ended == true:
		return
	
	timer += delta
	text = time_convert(floori(timer))


static func time_convert(time: int) -> String:
	var previous_seconds = seconds
	
	seconds = time%60
	minutes = (time/60)%60
	hours = (time/60)/60
	
	if previous_seconds != seconds:
		SignalsManager.emit_timer_seconds_update(seconds + minutes * 60 + hours * 3600)
	
	if floori(hours) == 0:
		return "%02d:%02d" % [minutes, seconds]
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func _on_game_end():
	game_ended = true
