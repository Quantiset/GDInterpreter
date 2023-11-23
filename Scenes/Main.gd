extends Node2D

@onready var console = $TextEdit

var can_interpret = true
var queue_interpret = false



func _on_TextEdit_text_changed():
	if can_interpret:
		Interpreter.Interpret(console.text)
		can_interpret = false
	else:
		queue_interpret = true


func _on_Timer_timeout():
	can_interpret = true
	if queue_interpret:
		Interpreter.Interpret(console.text)
		queue_interpret = false
