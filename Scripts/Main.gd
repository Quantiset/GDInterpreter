extends Node2D

onready var console = $TextEdit

var can_interpret := true
var queue_interpret := false

func _ready():
	for vari in Interpreter.included_variables:
		console.add_keyword_color(vari, Color(0.405273, 0.320312, 1))
	
	console.add_keyword_color("true", Color(0.855469, 0.304092, 0.342861))
	console.add_keyword_color("false", Color(0.855469, 0.304092, 0.342861))
	
	console.add_keyword_color("=", Color(0.53125, 0.53125, 0.53125))
	
	console.add_color_region('"', '"', Color(0.91653, 0.921875, 0.237671))
	console.add_color_region("#", '', Color(0.452961, 0.480469, 0.427917))

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
