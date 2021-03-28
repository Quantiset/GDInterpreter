extends Node


var Variables := {}
const whitespace := " \t\n"
const declarators := PoolStringArray([
	"var", "int", "float", "str", "bool", "arr"
])
const operations := PoolStringArray([
	"^", "*", "/", "-", "+", "%", "=", "=="
])
const numbers := "0123456789."

class BaseType:
	var type : String
	var value
	
	var is_dynamic : bool
	
	func _operate(operator, basetype):
		match(operator):
			"+":
				return self._add(basetype)
			"*":
				return self._mul(basetype)
			"-":
				var _basetype = basetype
				if basetype.type == "int" or basetype.type == "float":
					_basetype.value *= -1
					return self._add(_basetype)
			"==":
				return self._equ(basetype)
			"^":
				return self._pow(basetype)
			_:
				return Error.new(Errors.BlankOperator)
	
	func _add(basetype):
		return Error.new(Errors.WrongOperation)
	
	func _mul(basetype):
		return Error.new(Errors.WrongOperation)
	
	func _equ(basetype):
		if self.type == basetype.type:
			if self.value == basetype.value:
				return true
			return false
		return Error.new(Errors.WrongOperation)
	
	func _pow(basetype):
		pass

class Int extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "int"
		self.is_dynamic = _dynamic
	
	func _add(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value+basetype.value)
			"float":
				return Float.new(self.value+basetype.value)
			_:
				return Error.new(Errors.WrongOperation)
	
	func _mul(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value*basetype.value)
			"float":
				return Float.new(self.value*basetype.value)
			_:
				return Error.new(Errors.WrongOperation)
	
	func _to_string():
		return " [int, " + str(self.value)+"]"

class Float extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "float"
		self.is_dynamic = _dynamic
	
	func _add(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value+basetype.value)
			"float":
				return Float.new(self.value+basetype.value)
			_:
				return Error.new(Errors.WrongOperation)
	
	func _mul(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value*basetype.value)
			"float":
				return Float.new(self.value*basetype.value)
			_:
				return Error.new(Errors.WrongOperation)
	
	func _to_string():
		return " [float, " + str(self.value)+"]"

class Str extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "str"
		self.is_dynamic = _dynamic
	
	func _add(basetype):
		match(basetype.type):
			"str":
				return Str.new(self.value+basetype.value)
			_:
				return Error.new(Errors.WrongOperation)
	
	func _mul(basetype):
		match(basetype.type):
			"int":
				var tempf = ""
				for i in range(basetype.value):
					tempf += self.value
				return tempf
			_:
				return Error.new(Errors.WrongOperation)
	
	func _to_string():
		return " [string, " + str(self.value)+"]"

class Bool extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "bool"
		self.is_dynamic = _dynamic
	
	func _add(basetype):
		return Error.new(Errors.WrongOperation)
	
	func invert():
		return !self.value
	
	func _to_string():
		return " [bool, " + str(self.value)+"]"

class Arr extends BaseType:
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "arr"
		self.is_dynamic = _dynamic
	
	func _to_string():
		return " [bool, " + str(self.value)+"]"


enum Errors {
	InvalidDeclaration,
	BlankOperator,
	WrongOperation,
	TooManyDots,
	NotDeclared
}

class Error:
	var type
	var ctx
	
	func _init(_type, _ctx=null):
		self.type = _type
		self.ctx = _ctx
	
	func _to_string():
		return " Error: "+str(self.type)

var ltokens := []
var lpossible_token := ""
var ldot_count := 0
var lis_num := false
var lis_string := 0

func Interpret(text):
	reInterpret()
	
	var line_idx = 1
	var lines : PoolStringArray = text.split("\n")
	for line in lines:
		var error = checkLine(line)
		if error is Error:
			print(error, " at line ", line_idx)
		line_idx += 1
	print(Variables)
	

func checkLine(line:String):
	var tokens := []
	
	
	for declarator in declarators:
		if line.begins_with(declarator+" "):
			line = line.trim_prefix(declarator+" ")
			tokens.append(declarator)
	
	var possible_tokens = determineToken(line)
	
	if possible_tokens is Error:
		return possible_tokens
	for _token in possible_tokens:
		tokens.append(_token)
	
	var error = processTokens(tokens)
	if error is Error:
		return error

func reInterpret():
	Variables = {}
	ltokens = []
	refreshTokenDetection()

func determineToken(line:String):
	var line_idx := 0
	
	var error 
	for character in line:
		line_idx += 1
		lpossible_token += character
		
		if character == "\"" and lis_string == 1:
			lis_string = 2
		
		if (character in numbers) and not \
		(lis_string == 1 or lis_string == 2):
			lis_num = true
			if character == ".":
				ldot_count += 1
		elif character == "\"" and lis_string==0:
			lis_string = 1
		
		if lis_string != 1:
			if lis_string == 2 or line_idx==line.length():
				error = assignType()
			elif character == " ":
				if lpossible_token != " ":
					error = assignType(lpossible_token.trim_suffix(" "))
			else:
				for operation in operations:
					if operation == character:
						#assignType(lpossible_token.trim_suffix(operation).replace(" ", ""))
						error = assignType(operation)
		else:
			if line_idx==line.length():
				lis_string = 2
				error = assignType()
		
		if error is Error:
			return error
	
	return ltokens

func refreshTokenDetection():
	lpossible_token = ""
	ldot_count = 0
	lis_num = false
	lis_string = 0

func assignType(item=lpossible_token):
	if lis_num:
		if ldot_count == 0:
			ltokens.append(Int.new(int(item)))
		elif ldot_count == 1:
			ltokens.append(Float.new(float(item)))
		else:
			return Error.new(Errors.TooManyDots)
	elif lis_string == 2:
		ltokens.append(Str.new(item))
	else:
		ltokens.append(item)
	
	refreshTokenDetection()

func processTokens(tokenlist : Array):
	print(tokenlist)
	if tokenlist.has("="):
		var splice_idx := tokenlist.find("=")
		
		var assignee = tokenlist.slice(0,splice_idx-1)
		var assignment = tokenlist.slice(splice_idx+1,tokenlist.size()-1)
		
		if assignee.size() >= 3:
			return Error.new(Errors.InvalidDeclaration)
		
		if assignee.size() == 1 and not Variables.has(assignee):
			return Error.new(Errors.NotDeclared)
		
		if assignee[0] == "var":
			var temp = compute(assignment)
			if temp is Error:
				return temp
			temp.is_dynamic = true
			Variables[assignee[1]]=temp

func compute(tokenlist : Array):
	print(tokenlist)
	if tokenlist.size()%2!=1:
		return Error.new(Errors.WrongOperation)
	if not tokenlist[0] is BaseType:
		return Error.new(Errors.WrongOperation)
	
	#every other operation
	for token_idx in range(int(tokenlist.size()/2)):
		tokenlist[token_idx+2] = tokenlist[token_idx]._operate(tokenlist[token_idx+1], tokenlist[token_idx+2])
	
	return tokenlist[tokenlist.size()-1]
