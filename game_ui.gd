extends GridContainer

@onready var power_label: Label = $PowerLabel

func _on_player_ball_power_changed(new_value):
	power_label.text = str(new_value)
