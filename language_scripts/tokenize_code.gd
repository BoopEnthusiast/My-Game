class_name LangTokenizeCode
extends Node
## External code for the Lang Singleton

## All possible unicode whitespace characters, there may be duplicates since it's hard to tell and better safe than sorry. This class does not need to be efficient.
const WHITESPAC_CHARS: Array[String] = [
	" ",
	" ",
	" ",
	"	",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	"　",
	"\n",
	"\t",
	"\v",
	"\f",
	"\r",
]


## Goes through each character and turns them into an array of Token objects
func tokenize_code(text: String) -> Array[Token]:
	var tokenized_code: Array[Token] = []
	var working_token: String = ""
	var next_type: Array[Token.Type]
	var is_comment := false
	
	const KEYWORDS: Array[String] = [
		"if",
		"elif",
		"else",
		"while",
		"for",
	]
	const OPERATORS: Array[String] = [
		"*",
		"/",
		"+",
		"-",
		"%",
		"=",
	]
	
	# Loop through characters and turn them into tokens with types that can then be compiled into a Script Tree
	for chr in text:
		if is_comment and chr == "\n":
			is_comment = false
			working_token = ""
			continue
			
		elif is_comment:
			continue
			
		elif next_type.has(Token.Type.STRING):
			if chr == "\\":
				pass # TODO: Implement something like newlines and tabs and whatnot
				
			elif chr == "\"":
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.STRING, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.STRING]))
				next_type.clear()
				working_token = ""
				continue
				
		elif chr == "\"":
			if next_type.has(Token.Type.PARAMETER):
				next_type = [Token.Type.STRING, Token.Type.PARAMETER]
			else:
				next_type = [Token.Type.STRING]
			working_token = ""
			continue
		
		elif chr == "#":
			is_comment = true
			continue
			
		elif chr == "\n":
			tokenized_code.append(Token.new(working_token, [Token.Type.BREAK]))
			working_token = ""
			continue
			
		elif WHITESPAC_CHARS.has(chr):
			if KEYWORDS.has(working_token):
				tokenized_code.append(Token.new(working_token, [Token.Type.KEYWORD]))
				match working_token:
					KEYWORDS[0], KEYWORDS[1], KEYWORDS[3]:
						next_type = [Token.Type.BOOLEAN]
					KEYWORDS[4]:
						pass
				
			elif OPERATORS.has(working_token):
				tokenized_code.append(Token.new(working_token, [Token.Type.OPERATOR]))
				next_type = [Token.Type.FLOAT, Token.Type.INT]
				
			elif working_token.is_valid_int():
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.INT, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.INT]))
				next_type = [Token.Type.INT, Token.Type.FLOAT]
				
			elif working_token.is_valid_float():
				if next_type.has(Token.Type.PARAMETER):
					tokenized_code.append(Token.new(working_token, [Token.Type.FLOAT, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.FLOAT]))
				next_type = [Token.Type.INT, Token.Type.FLOAT]
				
			
			working_token = ""
			continue
			
		elif chr == ".":
			if not working_token.is_valid_int():
				if not tokenized_code.is_empty() and tokenized_code.back().types.has(Token.Type.OBJECT_NAME):
					tokenized_code.append(Token.new(working_token, [Token.Type.OBJECT_NAME, Token.Type.PARAMETER]))
					
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.OBJECT_NAME]))
					
				next_type = [Token.Type.PROPERTY, Token.Type.METHOD_NAME]
				working_token = ""
				continue
			
		elif chr == "(":
			if next_type.has(Token.Type.METHOD_NAME):
				tokenized_code.append(Token.new(working_token, [Token.Type.METHOD_NAME]))
				
			else:
				tokenized_code.append(Token.new(working_token, [Token.Type.FUNCTION_NAME]))
				
			next_type = [Token.Type.PARAMETER]
			working_token = ""
			continue
			
		elif chr == ",":
			tokenized_code.append(_number_parameter(working_token))
			
			next_type = [Token.Type.PARAMETER]
			working_token = ""
			continue
			
		elif chr == ")":
			if not working_token.is_empty():
				var new_param_token = _number_parameter(working_token)
				if not new_param_token.types == [Token.Type.PARAMETER]:
					tokenized_code.append(new_param_token)
				else:
					tokenized_code.append(Token.new(working_token, [Token.Type.PARAMETER, Token.Type.OBJECT_NAME]))
			next_type = []
			working_token = ""
			continue
			
		elif OPERATORS.has(chr):
			var new_param_token = _number_parameter(working_token)
			if not new_param_token.types == [Token.Type.PARAMETER]:
				tokenized_code.append(new_param_token)
			
			tokenized_code.append(Token.new(chr, [Token.Type.OPERATOR]))
			
			next_type = [Token.Type.INT, Token.Type.FLOAT]
			working_token = ""
			continue
			
		
		working_token += chr
		print(working_token,"   ",tokenized_code,"   ",next_type,"    ",is_comment)
	
	tokenized_code.append(Token.new(working_token, [Token.Type.BREAK]))
	
	print(tokenized_code)
	for token in tokenized_code:
		print(token.types,"   ",token.string)
	return tokenized_code


func _number_parameter(working_token: String) -> Token:
	if working_token.is_valid_int():
		return Token.new(working_token, [Token.Type.PARAMETER, Token.Type.INT])
		
	elif working_token.is_valid_float():
		return Token.new(working_token, [Token.Type.PARAMETER, Token.Type.FLOAT])
		
	else:
		return Token.new(working_token, [Token.Type.PARAMETER])
