extends Node


var Variables := {}
const whitespace := " \t\n"
const operations := PoolStringArray([
	"^", "*", "/", "-", "+", "%", "=", "==", "(", ")", 
	";", "&", "|", ">", "<", "<=", ">="
])
const space_operators := PoolStringArray([
	"or", "and", "equals", "greaterthan", "lessthan"
])
const ternaries := PoolStringArray([
	"if", "in", "elif", "else", "repeat", "do", "for"
])
const numbers := "0123456789."
var included_variables := {
	"pi" : Float.new(PI),
	"tau": Float.new(2*PI),
	"grav": Float.new(pow(PI,2)),
	"eul" : Float.new(2.7182818),
	"inf": Inf.new(INF)
}

class BaseType:
	
	var type : String
	var value
	
	var is_dynamic : bool
	
	func _operate(operator, basetype):
		if self is Inf or basetype is Inf:
			return Error.new("Cannot compute on base infinite")
		
		if not operator is String:
			return Error.new("Wrong Operation")
		
		if not basetype is BaseType:
			return Error.new("Base '"+str(basetype)+"' is not an operable base")
		elif not (operator in operations or operator in space_operators):
			return Error.new("Operator '"+str(operator)+"' is not an operable operator")
		
		match(operator):
			"+":
				return self._add(basetype)
			"*":
				return self._mul(basetype)
			"/":
				return self._div(basetype)
			"-":
				return self._sub(basetype)
			"^":
				return self._pow(basetype)
			"==", "equals":
				return self._equ(basetype)
			"<", "lessthan":
				return self._les(basetype)
			">", "greaterthan":
				return self._gtr(basetype)
			">=": 
				return Bool.new(true)
			"&", "and":
				return self._and(basetype)
			"|", "or":
				return self._or(basetype)
			_:
				return Error.new("Operator is Blank")
	
	func _add(basetype):
		return Error.new("Cannot add base " + str(self.type) + " to base " + str(basetype.type))
	
	func _mul(basetype):
		return Error.new("Cannot multiply base " + str(self.type) + " to base " + str(basetype.type))
	
	func _equ(basetype):
		return Error.new("Cannot equate base " + str(self.type) + " to base " + str(basetype.type))
	
	func _pow(basetype):
		return Error.new("Cannot power base " + str(self.type) + " to base " + str(basetype.type))
	
	func _sub(basetype):
		return Error.new("Cannot subtract base " + str(self.type) + " to base " + str(basetype.type))
	
	func _div(basetype):
		return Error.new("Cannot divide base " + str(self.type) + " to base " + str(basetype.type))
	
	func _and(basetype):
		return Error.new("Cannot logically AND base " + str(self.type) + " to base " + str(basetype.type))
	
	func _or(basetype):
		return Error.new("Cannot logically OR base " + str(self.type) + " to base " + str(basetype.type))
	
	func _les(basetype):
		return Error.new("Cannot compare base " + str(self.type) + " to base " + str(basetype.type))
		
	func _gtr(basetype):
		return Error.new("Cannot compare base " + str(self.type) + " to base " + str(basetype.type))

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
				return Error.new("Cannot add base int to base " + str(basetype.type))
	
	func _sub(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value-basetype.value)
			"float":
				return Float.new(self.value-basetype.value)
			_:
				return Error.new("Cannot subtract base int to base " + str(basetype.type))
	
	func _mul(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value*basetype.value)
			"float":
				return Float.new(self.value*basetype.value)
			_:
				return Error.new("Cannot multiply base int to base " + str(basetype.type))
	
	func _div(basetype):
		match(basetype.type):
			"int":
				if is_zero_approx(basetype.value):
					return Error.new("Divison by zero in operator '/'")
				return Float.new(self.value/float(basetype.value))
			"float":
				if is_zero_approx(basetype.value):
					return Error.new("Divison by zero in operator '/'")
				return Float.new(self.value/float(basetype.value))
			_:
				return Error.new("Cannot add base int to base " + str(basetype.type))
	
	func _pow(basetype):
		match(basetype.type):
			"int":
				return Int.new(pow(self.value, basetype.value))
			"float":
				return Float.new(pow(self.value, basetype.value))
			_:
				return Error.new("Cannot power base int to base " + str(basetype.type))
	
	func _equ(basetype):
		match(basetype.type):
			"int":
				if self.value == basetype.value:
					return Bool.new(true)
				return Bool.new(false)
			"float":
				if is_equal_approx(self.value, basetype.value):
					return Bool.new(true)
				return Bool.new(false)
			_:
				return Error.new("Cannot equate base int to base " + str(basetype.type))
	
	func _les(basetype):
		match(basetype.type):
			"int", "float":
				return Bool.new(self.value<basetype.value)
	
	func _gtr(basetype):
		match(basetype.type):
			"int", "float":
				return Bool.new(self.value>basetype.value)
	
	func _to_string():
		return str(self.value)

class Float extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = float(_value)
		self.type = "float"
		self.is_dynamic = _dynamic
	
	func _add(basetype):
		match(basetype.type):
			"int":
				return Float.new(self.value+basetype.value)
			"float":
				return Float.new(self.value+basetype.value)
			_:
				return Error.new("Cannot add base float to base " + str(basetype.type))
	
	func _sub(basetype):
		match(basetype.type):
			"int":
				return Float.new(self.value-basetype.value)
			"float":
				return Float.new(self.value-basetype.value)
			_:
				return Error.new("Cannot subtract base int to base " + str(basetype.type))
	
	func _mul(basetype):
		match(basetype.type):
			"int":
				return Int.new(self.value*basetype.value)
			"float":
				return Float.new(self.value*basetype.value)
			_:
				return Error.new("Cannot multiply base float to base " + str(basetype.type))
	
	func _div(basetype):
		match(basetype.type):
			"int":
				if is_zero_approx(basetype.value):
					return Error.new("Divison by zero in operator '/'")
				return Float.new(self.value/float(basetype.value))
			"float":
				if is_zero_approx(basetype.value):
					return Error.new("Divison by zero in operator '/'")
				return Float.new(self.value/float(basetype.value))
			_:
				return Error.new("Cannot add base int to base " + str(basetype.type))
	
	func _pow(basetype):
		match(basetype.type):
			"int":
				return Float.new(pow(self.value, basetype.value))
			"float":
				return Float.new(pow(self.value, basetype.value))
			_:
				return Error.new("Cannot power base float to base " + str(basetype.type))
	
	func _equ(basetype):
		match(basetype.type):
			"int", "float":
				if self.value == basetype.value:
					return Bool.new(true)
				return Bool.new(false)
			_:
				return Error.new("Cannot equate base float to base " + str(basetype.type))
	
	func _to_string():
		return str(self.value)

class Str extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = str(_value)
		self.type = "str"
		self.is_dynamic = _dynamic
	
	func _add(basetype):
		match(basetype.type):
			"str":
				return Str.new(self.value+basetype.value)
			_:
				return Error.new("Cannot add base string to base " + str(basetype.type))
	
	func _mul(basetype):
		match(basetype.type):
			"int":
				return Str.new(self.value.repeat(basetype.value))
			_:
				return Error.new("Cannot multiply base string to base " + str(basetype.type))
	
	func _equ(basetype):
		match(basetype.type):
			"str":
				if self.value == basetype.value:
					return Bool.new(true)
				return Bool.new(false)
			_:
				return Error.new("Cannot equate base string to base " + str(basetype.type))
	
	func _to_string():
		return str(self.value)

class Bool extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = bool(_value)
		self.type = "bool"
		self.is_dynamic = _dynamic
	
	func invert():
		return !self.value
	
	func _and(basetype):
		match(basetype.type):
			"bool":
				return Bool.new(self.value and basetype.value)
	
	func _or(basetype):
		match(basetype.type):
			"bool":
				return Bool.new(self.value or basetype.value)
	
	func _to_string():
		return str(self.value)

class Inf extends BaseType:
	
	func _init(_value, _dynamic=false):
		self.value = _value #useless
		self.type = "inf"
		self.is_dynamic = _dynamic
	
	func _to_string():
		return str(self.value)

class Arr extends BaseType:
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "arr"
		self.is_dynamic = _dynamic
	
	func _to_string():
		return str(self.value)

class Null extends BaseType:
	func _init(_value, _dynamic=false):
		self.value = _value
		self.type = "null"
		self.is_dynamic = _dynamic
	
	func _to_string():
		return "null"


class Error:
	var type 
	var ctx 
	
	func _init(_type, _ctx:=[]):
		self.type = _type
		self.ctx = _ctx
	
	func _to_string():
		return str(self.type)

class RetValue:
	var rettype
	var type
	
	func _init(_type, _rettype="_"):
		self.type = _type
		self.rettype = _rettype

var ltokens := []
var lpossible_token := ""
var ldot_count := 0
var lis_num := false
var lis_string := 0

func Interpret(text):
	reInterpret()
	
	var has_just_been_raised = false
	var indentation_level = 0
	var next_indentation_level = 0
	var line_idx = 0
	var lines : PoolStringArray = text.split("\n")
	
	var dichotomy := {}
	
	#foreach line,
	for line in lines:
		line_idx += 1
		
		if line.dedent() == "":
			continue
		
		#compute indentations
		while line.begins_with("\t"):
			line = line.trim_prefix("\t")
			indentation_level += 1
		
		if has_just_been_raised and next_indentation_level>indentation_level:
			return [Error.new("Expected indented block after 'if'"), line_idx]
		
		if indentation_level > next_indentation_level:
			continue
		
		has_just_been_raised = false
		var retval = checkLine(line)
		if retval is Error:
			return [retval, line_idx]
		if retval is RetValue:
			if retval.rettype in ternaries:
				if retval.type == true:
					next_indentation_level = indentation_level + 1
				elif retval.type == false:
					next_indentation_level = indentation_level
				has_just_been_raised = true
		
		ltokens=[]
		refreshTokenDetection()
	

func checkLine(line:String):
	var tokens := []
	var possible_tokens
	
	possible_tokens = determineTokens(line)
	
	if possible_tokens is Error:
		return possible_tokens
	tokens=possible_tokens
	
	
	return processTokens(tokens)

func reInterpret():
	Variables = {}
	ltokens = []
	refreshTokenDetection()

func determineTokens(line:String):
	var line_idx := 0
	
	var error 
	for character in line:
		if character == "\t":
			return Error.new("Unexpected Indentation")
		
		line_idx += 1
		lpossible_token += character
		
		if character == "\"" and lis_string == 1:
			lis_string = 2
		
		if (character in numbers) and not \
		(lis_string == 1 or lis_string == 2):
			lis_num = true
			if character == ".":
				ldot_count += 1
		elif character == '"' and lis_string==0:
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
			
			if (not character in numbers) and lis_num and not (character == " "):
				assignType(lpossible_token.trim_suffix(character))
				lpossible_token = character
			
			if lpossible_token == "true" or lpossible_token == "false" or lpossible_token == "null":
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
					if lpossible_token.ends_with(operation):
						if not lpossible_token.replace(" ","")==operation:
							error = assignType(lpossible_token.trim_suffix(operation).replace(" ", ""))
						error = assignType(operation)
				if not character in numbers and lis_num:
					return Error.new("Variable '" + lpossible_token + "' not properly defined")
				if line_idx == line.length() and lpossible_token.dedent() != "":
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
	if item is String and item in operations and item == "="\
		and ltokens[-1] is String and ltokens[-1] in operations\
			and ltokens[-1] == "=":
				ltokens[-1] = "=="
	elif lis_num:
		if lis_string:
			return Error.new("Number '" + item + "' improperly defined")
		if ldot_count == 0:
			ltokens.append(Int.new(int(item)))
		elif ldot_count == 1:
			ltokens.append(Float.new(float(item)))
		else:
			return Error.new("Float '" + item + "' improperly defined")
	elif lis_string == 2:
		ltokens.append(Str.new(item))
	elif item == "true":
		ltokens.append(Bool.new(true))
	elif item == "false":
		ltokens.append(Bool.new(false))
	elif item == "null":
		ltokens.append(Null.new(null))
	else:
		ltokens.append(item)
	
	refreshTokenDetection()

func processTokens(tokenlist : Array):
	if tokenlist[-1] is String and tokenlist[-1] == ";":
		tokenlist.remove(tokenlist.size()-1)
	
	if tokenlist.size()>=2 and tokenlist[0] is String and tokenlist[0] in ternaries:
		if tokenlist[0] == "if":
			if not (tokenlist[-1] is String and (tokenlist[-1] == "do" or tokenlist[-1] == ":")):
				return Error.new("Expected 'do' after if statement")
			
			var test_bool = compute(tokenlist.slice(1,tokenlist.size()-2))
			
			if test_bool is Error:
				return test_bool
			
			if not test_bool is Bool:
				return Error.new("Expected boolean value in if statement")
			
			return RetValue.new(test_bool.value, "if")
		elif tokenlist[0] == "else":
			if tokenlist.size()>2:
				return Error.new("Errenous Tokens")
			
			if not (tokenlist[-1] is String and tokenlist[-1] == ":"):
				return RetValue.new(true, "else")
		return Error.new("Ternary misplaced")
	
	#assignment expression
	elif tokenlist.size()>=2 and tokenlist[0] is String and tokenlist.has("="):
		
		var splice_idx := tokenlist.find("=")
		
		var assignee := tokenlist.slice(0,splice_idx-1)
		var assignment := tokenlist.slice(splice_idx+1,tokenlist.size()-1)
		
		if assignee.size() > 1:
			return Error.new("Cannot Assign to Multiple Bases: " + str(assignee))
		elif assignee.size() < 1:
			return Error.new("Expected variable name")
		
		var temp
		if assignment == []:
			temp = Null.new(null)
		else:
			temp = compute(assignment)
			if temp is Error:
				return temp
		
		
		if assignee[0] in included_variables:
			return Error.new("Variable '" + assignee[0] + "' is already pre-declared")
		Variables[assignee[0]]=temp
	
	return RetValue.new(false, "_")

func compute(tokenlist : Array):
	
	if tokenlist.has("="):
		return Error.new("Unexpected Assignment")
	
	for tok_idx in range(tokenlist.size()):
		var val = tokenlist[tok_idx]
		if val is String and not val in operations:
			
			if included_variables.has(val):
				tokenlist[tok_idx] = included_variables[val]
			elif Variables.has(val):
				tokenlist[tok_idx] = Variables[val]
			elif not val in space_operators:
				return Error.new("Variable " + val + " not declared in current scope")
	
	var result
	var iters = 0
	while tokenlist.has("("):
		var start_idx = tokenlist.find("(")
		var end_idx := -1
		
		var open_statements := 0
		
		for _i in range(tokenlist.size()-start_idx):
			var temp_idx = _i + start_idx
			if tokenlist[temp_idx] is String and tokenlist[temp_idx]==")":
				open_statements -= 1
				end_idx = temp_idx
				if open_statements < 0:
					break
			elif tokenlist[temp_idx] is String and tokenlist[temp_idx]=="(":
				if end_idx != -1:
					open_statements += 1
		
		if end_idx == -1:
			return Error.new("Mismatched Parentheses")
		
		result = compute(tokenlist.slice(start_idx+1,end_idx-1))
		
		if result is Error:
			return result
		
		var lside : Array
		var rside : Array
		if start_idx == 0:
			lside = []
		else:
			lside = tokenlist.slice(0,start_idx-1)
		if end_idx == tokenlist.size()-1:
			rside = []
		else:
			rside = tokenlist.slice(end_idx+1, tokenlist.size()-1)
		
		tokenlist = lside + [result] + rside
		
		iters += 1
		if iters > 2:
			break
	if tokenlist.has(")"):
		return Error.new("Mismatched Parentheses")
	
	if tokenlist.size()%2!=1 and tokenlist.size() > 0:
		if tokenlist[-1] is BaseType:
			for token_idx in range(tokenlist.size()-1):
				if tokenlist[token_idx] is BaseType and tokenlist[token_idx+1] is BaseType:
					return Error.new("Cannot compute two simultaneous bases '" + \
					str(tokenlist[token_idx]) + "' and '" + str(tokenlist[token_idx+1]) + "'")
				if tokenlist[token_idx] is String and tokenlist[token_idx+1] is String:
					if tokenlist[token_idx] in operations and tokenlist[token_idx+1] in operations:
						return Error.new("Cannot compute two simultaneous operations '" + \
						str(tokenlist[token_idx]) + "' and '" + str(tokenlist[token_idx+1]) + "'")
			return Error.new("Invalid Tokens '" + str(tokenlist) + "'")
		elif tokenlist[-1] in operations:
			return Error.new("Misplaced: '" + str(tokenlist[-1]) + "'")
	if tokenlist.has(""):
		return Error.new("Tokenlist has blank operation: " + str(tokenlist))
	
	#every other operation
	if tokenlist.size()==1 and tokenlist[0] is BaseType:
		return tokenlist[0]
	elif tokenlist.size()==0:
		return Error.new("Cannot compute on blank operations")
	elif not tokenlist[0] is BaseType:
		return Error.new("Cannot operate on single operation: '"+ str(tokenlist[0])+ "'")
	for token_idx in range(int(tokenlist.size()/2)):
		token_idx *= 2
		
		if not tokenlist[token_idx] is BaseType:
			return Error.new("Cannot compute on operation: " + str(tokenlist))
		if token_idx+2 >= tokenlist.size():
			return Error.new("Misplaced '" + str(tokenlist[-1])+"'") 
		
		tokenlist[token_idx+2] = tokenlist[token_idx]._operate(tokenlist[token_idx+1], tokenlist[token_idx+2])
		if tokenlist[token_idx+2] is Error:
			return tokenlist[token_idx+2]
	
	return tokenlist[tokenlist.size()-1]
