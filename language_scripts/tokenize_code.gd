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
	var line_number: int = 0
	
	const EXPRESSION_SYMBOLS: Array[String] = [
		"*",
		"/",
		"+",
		"-",
		"%",
		"=",
		"(",
		")",
		".",
	]
	
	# Loop through characters and turn them into tokens with types that can then be compiled into a Script Tree
	for chr in text:
		# Check if it's a new line to increment the line number
		if chr == '\n':
			line_number += 1
		
		# Main checks
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
					tokenized_code.append(Token.new(working_token, line_number, [Token.Type.STRING, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, line_number, [Token.Type.STRING]))
				next_type.clear()
				working_token = ""
				continue
				
		elif next_type.has(Token.Type.EXPRESSION):
			if chr == ')':
				if next_type.has(Token.Type.INNER_EXPRESSION):
					next_type = [Token.Type.EXPRESSION]
				else:
					if not working_token.is_empty():
						tokenized_code.append(Token.new(working_token, line_number, [Token.Type.PARAMETER, Token.Type.EXPRESSION]))
					next_type = []
					working_token = ""
					continue
			elif chr == '(':
				next_type = [Token.Type.INNER_EXPRESSION, Token.Type.EXPRESSION]
			
			if not EXPRESSION_SYMBOLS.has(chr) and not chr.is_valid_float():
				next_type.clear()
				
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
			tokenized_code.append(Token.new("", line_number, [Token.Type.BREAK]))
			working_token = ""
			continue
			
		elif WHITESPAC_CHARS.has(chr):
			if Lang.KEYWORDS.has(working_token):
				tokenized_code.append(Token.new(working_token, line_number, [Token.Type.KEYWORD]))
				match working_token:
					Lang.KEYWORDS[Lang.Keywords.IF], Lang.KEYWORDS[Lang.Keywords.ELIF], Lang.KEYWORDS[Lang.Keywords.WHILE]:
						next_type = [Token.Type.BOOLEAN]
					Lang.KEYWORDS[Lang.Keywords.FOR]:
						pass
					Lang.KEYWORDS[Lang.Keywords.RETURN]:
						next_type = [Token.Type.OBJECT_NAME, Token.Type.EXPRESSION, Token.Type.STRING, Token.Type.BOOLEAN, Token.Type.NONE]
						
				working_token = ""
				continue
				
		elif chr == ".":
			if not working_token.is_valid_int():
				if not tokenized_code.is_empty() and tokenized_code.back().types.has(Token.Type.OBJECT_NAME):
					tokenized_code.append(Token.new(working_token, line_number, [Token.Type.OBJECT_NAME, Token.Type.PARAMETER]))
				else:
					tokenized_code.append(Token.new(working_token, line_number, [Token.Type.OBJECT_NAME]))
				next_type = [Token.Type.PROPERTY, Token.Type.METHOD_NAME]
				working_token = ""
				continue
				
		elif chr == "(":
			if next_type.has(Token.Type.METHOD_NAME):
				tokenized_code.append(Token.new(working_token, line_number, [Token.Type.METHOD_NAME]))
			else:
				tokenized_code.append(Token.new(working_token, line_number, [Token.Type.FUNCTION_NAME]))
			next_type = [Token.Type.PARAMETER, Token.Type.EXPRESSION]
			working_token = ""
			continue
			
		elif chr == ",":
			# TODO: Implement multiple parameters
			
			next_type = [Token.Type.PARAMETER]
			working_token = ""
			continue
			
		elif chr == ")":
			if not working_token.is_empty():
				tokenized_code.append(Token.new(working_token, line_number, [Token.Type.PARAMETER, Token.Type.OBJECT_NAME]))
			next_type = []
			working_token = ""
			continue
			
		
		working_token += chr
		print(working_token,"   ",tokenized_code,"   ",next_type,"    ",is_comment)
	
	tokenized_code.append(Token.new(working_token, line_number, [Token.Type.BREAK]))
	
	print(tokenized_code)
	for token in tokenized_code:
		print(token.types,"   ",token.string)
	return tokenized_code
