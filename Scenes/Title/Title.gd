extends Control

func _ready():
	$Buttons/Start.grab_focus()
	BGM.play("title")
	get_tree().paused = false
	if OS.get_name() == "HTML5":
		$Buttons/Quit.queue_free()

func _on_Start_pressed():
	BGM.stop()
	#assert(get_tree().change_scene("res://Scenes/Intro/WakeUp.tscn") == OK)
	var _scene = get_tree().change_scene("res://Scenes/Intro/WakeUp.tscn")# == OK

func _on_Quit_pressed():
	Transition.quit()

func _on_LinkButton_pressed():
	var _open = OS.shell_open("https://ldjam.com/events/ludum-dare/49/ruff-tuff-skies")
