extends StaticBody2D


func _on_Visibility_screen_entered():
	$Timer.start()
	pass # Replace with function body.


func _on_Timer_timeout():
	$Collider.disabled = true
	pass # Replace with function body.
