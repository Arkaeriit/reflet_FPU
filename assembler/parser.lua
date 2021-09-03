--[[--------------------------------------------------
|This file contain code used to transform a line     |
|of assembly code into a structure containung the    |
|number of words in that line and their number. The  |
|functions in this file let us get rid of whitespace.|
|Furthermore, there is a function to convert a whole |
|file into such lines.                               |
----------------------------------------------------]]

require 'string'
require 'stringbuilder'

--constants
local max_number_of_words <comptime> = 50 --The maximum number of words in an line. If there is more words, they will be ignored. More words means that theire is a more serious issur somewhere else
local max_number_of_lines <comptime> = 4096 --The maximum number of lines in a file. TODO: Maybe use a linked list instead...
local comment_delimiter <comptime> = ";"

----------------------------------Data types------------------------------------

global pure_line = @record{
    len: integer,
    content: [max_number_of_words]string
}

global pure_file = @record{
    len: integer,
    content: [max_number_of_lines]pure_line
}

--------------------------------Data pretyfiers---------------------------------

function pure_line:__len()
    return self.len
end

function pure_line:__tostring()
   local builder: stringbuilder 
   builder:write("len = ")
   builder:write(#self)
   builder:write("; {")
   for i=0,<#self do
       builder:write(self.content[i])
       if i ~= #self - 1 then
           builder:write(", ")
       end
   end
   builder:write("}")
   return builder:promote()
end

--------------------------------Private symbols---------------------------------

--tells if a character is whitespace
local function is_whitespace(s: string): boolean
    local c = s:byte()
    return not (c > 0x20 and c < 0x7F)
end

--Transforms a line in a pure_line
--Stop if a comment_delimiter is found and saturates
--at max_number_of_words
local function purify_line(s: string): pure_line
    local in_word = false
    local ret: pure_line
    ret.len = 0
    local pointer = 1 --Note, strings are 1-indexed so the pointer is set to 1
    local curr_word_start: integer
    while pointer <= #s and #ret < max_number_of_words-1 do --Note: the -1 is to ensure that we can add an other word after the lop
        local curr_char = s:sub(pointer, pointer)
        if curr_char == comment_delimiter then
            break
        end
        if in_word then
            if is_whitespace(curr_char) then
                ret.content[#ret] = s:sub(curr_word_start, pointer-1)
                ret.len = #ret + 1
                in_word = false
            end
        else
            if not is_whitespace(curr_char) then
                in_word = true
                curr_word_start = pointer
            end
        end
        pointer = pointer + 1
    end
    if in_word then
        ret.content[#ret] = s:sub(curr_word_start, pointer-1)
        ret.len = #ret + 1
    end
    return ret
end

-----------------------------------Public API-----------------------------------

print("aaa")
local pure = purify_line("la aa bb;xDD")
print(pure)
pure = purify_line("la aa ;xDD")
print(pure)
pure = purify_line("          ")
print(pure)
