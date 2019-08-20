
syn keyword pythonBuiltinObj  __dict__, __class__
syn keyword pythonImport      as with return
syn match pythonBuiltinType    '\v\.@<!<%(object|bool|int|float|tuple|str|list|dict|set|frozenset|bytearray|bytes)>'
syn match pythonClassDef        '\v(^[ \t]*class[ \t]+)@<=\w+'
" syn match pythonArgument 		'\v\(@<=\w
