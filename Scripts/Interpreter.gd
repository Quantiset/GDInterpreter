extends Node


var Variables := {}
const whitespace := " \t\n"
const operations := PoolStringArray([
	"^", "*", "/", "-", "+", "%", "=", "==", "(", ")"
])
const numbers := "0123456789."
var included_variables := {
	"pi" : Float.new(PI),
	"tau": Float.new(2*PI),
	"grav": Float.new(pow(PI,2)),
	"eul" : Float.new(2.7182818)
}

class BaseType:
	var type : String
	var value
	
	var is_dynamic : bool
	
	func _operate(operator, basetype):
		if not basetype is BaseType:
			return Error.new(Errors.WrongOperation)
		elif not operator in operations:
			return Error.new(Errors.WrongOperation)
		
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
		return Error.new(Errors.WrongOperation)

class Int extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = int(_value)
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
	
	func _pow(basetype):
		match(basetype.type):
			"int":
				return Int.new(pow(self.value, basetype.value))
			"float":
				return Float.new(pow(self.value, basetype.value))
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
				return Float.new(self.value+basetype.value)
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
	
	func _pow(basetype):
		match(basetype.type):
			"int":
				return Float.new(pow(self.value, basetype.value))
			"float":
				return Float.new(pow(self.value, basetype.value))
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
				return Str.new(self.value.repeat(basetype.value))
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
	NotDeclared,
	WrongTypeAssignment,
	InvalidParse,
	ExpectedAssignment,
	UnexpectedIndent,
	NumberNotRight,
	MismatchedParentheses,
	NumAndStringIntertwined
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
		
		ltokens=[]
		refreshTokenDetection()
	print(Variables)
	

func checkLine(line:String):
	var tokens := []
	var possible_tokens
	
	possible_tokens = determineTokens(line)
	
	if possible_tokens is Error:
		return possible_tokens
	tokens=possible_tokens
	
	print(tokens)
	
	var error = processTokens(tokens)
	if error is Error:
		return error

func reInterpret():
	Variables = {}
	ltokens = []
	refreshTokenDetection()

func determineTokens(line:String):
	var line_idx := 0
	
	var error 
	for character in line:
		if character == "\t":
			return Error.new(Errors.UnexpectedIndent)
		
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
		
		#if is not in the middle of a string,
		#create a token with what you have so far
		if lis_string != 1:
			
			#do not worry about rest of line (is comment)
			if character == "#":
				error = assignType(lpossible_token.trim_suffix("#"))
				if error is Error:
					return error
				return ltokens
			#if is end of line or end of string, create a token
			if lis_string == 2:
				error = assignType()
			
			elif lpossible_token == "true" or lpossible_token == "false":
				error = assignType()
			
			#if is a space, create a token and do not create one
			#if the token is just more empty space
			elif character == " ":
				if lpossible_token != " ":
					error = assignType(lpossible_token.trim_suffix(" "))
				refreshTokenDetection()
			
			else:
				#else, if there is an operation, add it
				for operation in operations:
					if operation == character:
						if not lpossible_token.replace(" ","")==operation:
							error = assignType(lpossible_token.trim_suffix(operation).replace(" ", ""))
						error = assignType(operation)
				if not character in numbers and lis_num:
					return Error.new(Errors.NumberNotRight)
				if line_idx == line.length():
					error = assignType()
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
		if lis_string:
			return Error.new(Errors.NumAndStringIntertwined)
		if ldot_count == 0:
			ltokens.append(Int.new(int(item)))
		elif ldot_count == 1:
			ltokens.append(Float.new(float(item)))
		else:
			return Error.new(Errors.TooManyDots)
	elif lis_string == 2:
		ltokens.append(Str.new(item))
	elif item == "true":
		ltokens.append(Bool.new(true))
	elif item == "false":
		ltokens.append(Bool.new(false))
	else:
		ltokens.append(item)
	
	refreshTokenDetection()

func processTokens(tokenlist : Array):
	
	#assignment expression
	if tokenlist.size()>2 and tokenlist[0] is String and (tokenlist.has("=")):
		
		var splice_idx := tokenlist.find("=")
		
		var assignee : Array
		var assignment : Array
		if splice_idx != -1:
			assignee = tokenlist.slice(0,splice_idx-1)
			assignment = tokenlist.slice(splice_idx+1,tokenlist.size()-1)
		else:
			if tokenlist.size()==2:
				if not tokenlist[1] is String:
					return Error.new(Errors.ExpectedAssignment)
				Variables[tokenlist[1]] = null
			else:
				return Error.new(Errors.InvalidDeclaration)
		
		#print(assignee, " ", assignment)
		
		if assignee.size() >= 3:
			return Error.new(Errors.InvalidDeclaration)
		
		var temp = compute(assignment)
		if temp is Error:
			return temp
		
		Variables[assignee[0]]=temp

func compute(tokenlist : Array):
	
	for tok_idx in range(tokenlist.size()):
		var val = tokenlist[tok_idx]
		if val is String and not val in operations:
			if included_variables.has(val):
				tokenlist[tok_idx] = included_variables[val]
			elif Variables.has(val):
				tokenlist[tok_idx] = Variables[val]
			else:
				return Error.new(Errors.ExpectedAssignment)
	
	if tokenlist.size()%2!=1:
		return Error.new(Errors.WrongOperation)
	if tokenlist.has(""):
		return Error.new(Errors.WrongOperation)
	
	var result
	if tokenlist.has("("):
		
		while tokenlist.has("("):
			var start_idx = tokenlist.find("(")
			var end_idx = tokenlist.find_last(")")
			
			if end_idx == -1:
				return Error.new(Errors.MismatchedParentheses)
			
			result = compute(tokenlist.slice(start_idx+1,end_idx-1))
			
			while start_idx != end_idx:
				tokenlist.remove(start_idx)
				start_idx += 1
	
	#every other operation
	for token_idx in range(int(tokenlist.size()/2)):
		token_idx *= 2
		tokenlist[token_idx+2] = tokenlist[token_idx]._operate(tokenlist[token_idx+1], tokenlist[token_idx+2])
		if tokenlist[token_idx+2] is Error:
			return tokenlist[token_idx+2]
	
	return tokenlist[tokenlist.size()-1]
