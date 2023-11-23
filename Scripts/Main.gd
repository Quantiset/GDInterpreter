extends Node2D

@onready var console = $TextEdit

var can_interpret := true
var queue_interpret := false

func _ready():
	pass
#	for vari in Interpreter.included_variables:
#		console.add_theme_color_override(vari, Color(0.463179, 0.171402, 0.933594))
#
#	for operator in Interpreter.operations:
#		console.add_keyword_color(operator, Color(0.785156, 0.723816, 0.392578))
#
	for ternary in Interpreter.ternaries:
		console.syntax_highlighter.keyword_colors[ternary] = Color(0.878906, 0.267792, 0.310761)
	for operator in Interpreter.space_operators:
		console.syntax_highlighter.keyword_colors[operator] = Color(0.878906, 0.267792, 0.310761)
#
#	console.add_keyword_color("true", Color(0.878906, 0.267792, 0.310761))
#	console.add_keyword_color("false", Color(0.878906, 0.267792, 0.310761))
#	console.add_keyword_color("null", Color(0.878906, 0.267792, 0.310761))
#
#	console.add_color_region('"', '"', Color(0.91653, 0.921875, 0.237671))
#	console.add_color_region("#", '', Color(0.452961, 0.480469, 0.427917))

func _on_TextEdit_text_changed():
	
	if can_interpret:
		interpret()
		can_interpret = false
	else:
		queue_interpret = true


func _on_Timer_timeout():
	can_interpret = true
	if queue_interpret:
		interpret()
		queue_interpret = false

func interpret():
	var error = Interpreter.Interpret(console.text)
	
	$Members.text = "Members:"
	for vari in Interpreter.variables:
		$Members.text += "\n"
		$Members.text += vari + ": " + str(Interpreter.variables[vari])
	
	if error is Array:
		$ErrorLog.text = "Error (" + str(error[1]) + "): " + str(error[0])
		$ColorRect.position.y = (error[1]-1)*23
	else:
		$ErrorLog.text = ""
		$ColorRect.position.y = -25
