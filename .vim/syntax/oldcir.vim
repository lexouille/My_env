  syntax case ignore

  syntax keyword CIRKWORDS Exclude
  highlight link CIRKWORDS String

  syntax region CIRCKT start=".subckt" end=".ends"
  highlight link CIRCKT Structure

  syntax match CIRCWORDS "^\*.*"
  syntax match CIRCWORDS "[ ]\*.*"
  highlight link CIRCWORDS Comment

  syntax match CIRCWORDD "^\#.*"
  syntax match CIRCWORDD "[ ]\#.*"
  highlight link CIRCWORDD function

  syntax match CIRCWORDE "^[CDEILRVX]\S*[ ]"
  highlight link CIRCWORDE define

syntax keyword CIRKWORD1 mprun step plotbus
highlight link CIRKWORD1 Character 

 syntax keyword CIRKWORD2 lib
  highlight link CIRKWORD2 Function 

 syntax keyword CIRKWORD3 connect
  highlight link CIRKWORD3 Statement 

syntax keyword CIRKWORD5 extract
  highlight link CIRKWORD5 Repeat

syntax keyword CIRKWORD6 plot
  highlight link CIRKWORD6 label 

syntax match CIRKWORD7 "\c.tran"
  highlight link CIRKWORD7 operator

 syntax keyword CIRKWORD8 sst
  highlight link CIRKWORD8 keyword

syntax keyword CIRKWORD9 option
  highlight link CIRKWORD9 exception

syntax keyword CIRKWORD10 temp
  highlight link CIRKWORD10 preproc

syntax keyword CIRKWORD11 include
  highlight link CIRKWORD11 include
 
syntax keyword CIRKWORD12 label
  highlight link CIRKWORD12 define

syntax keyword CIRKWORD13 ic
  highlight link CIRKWORD13 macro

syntax keyword CIRKWORD14 dc 
  highlight link CIRKWORD14 precondit

syntax keyword CIRKWORD15 ac
  highlight link CIRKWORD15 type

syntax keyword CIRKWORD16 XMN
  highlight link CIRKWORD16 storageclass

syntax keyword CIRKWORD17 i
  highlight link CIRKWORD17 typedef

syntax keyword CIRKWORD18 v
  highlight link CIRKWORD18 special

syntax keyword CIRKWORD19 list
  highlight link CIRKWORD19 specialcomment

syntax keyword CIRKWORD20 incr
  highlight link CIRKWORD20 debug

syntax keyword CIRKWORD21 w
  highlight link CIRKWORD21 underlined

syntax keyword CIRKWORD22 l
  highlight link CIRKWORD22 ignore

syntax keyword CIRKWORD23 nf
  highlight link CIRKWORD23 todo

syntax keyword CIRKWORD24 param
  highlight link CIRKWORD24 String

" Numbers, all with engineering suffixes and optional units
"==========================================================
"floating point number, with dot, optional exponent
syn match spiceNumber  "\<[0-9]\+\.[0-9]*\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
"floating point number, starting with a dot, optional exponent
syn match spiceNumber  "\.[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
"integer number with optional exponent
syn match spiceNumber  "\<[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="

highligh link spiceNumber number

"Comment
"Constant
"String
"Character
"Number
"Boolean
"Float
"Identifier
"Function
"Statement
"Conditional
"Repeat
"Label
"Operator
"Keyword
"Exception
"PreProc
"Include
"Define
"Macro
"PreCondit
"Type
"StorageClass
"Structure
"Typedef
"Special
"SpecialChar
"Tag
"Delimiter
"SpecialComment
"Debug
"Underlined
"Ignore
"Error
"Todo
