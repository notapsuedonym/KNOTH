'''
	KNOTH ~~is (Kind of) Not a fOrTH~~
        Is a Language I dont like the full-form name of anymore
a mostly stack-based language that is
					~~(accidentally)~~
				  ~~sort of a Forth~~
              weird ?

	reverse polish notation

    4 4 + 2 *                   ; -> 16
    (else#)
    (then#)
    (0) if                      ; -> "then" -> STDOUT

	neet terse functions

    m !o                        ; -> 109
    m !o !c                     ; -> "m"
    m !o 13 + !c                ; -> "z"
    :! world :  Hello, !j       ; -> "Hello, world!"

  silly unicode characters

    ⁐⁐⁐⁐                     ; clear the stack
    $"2 +" addTwo @ 2 addTwo 🝢  ; -> 4
    1 2 3 4 5 :+ 🜁              ; -> 15

  write code thats hard to read

    (. 2 =, 2, % 0 = ||) even@
    (
      ()
      (2 *)
      (. even🝢) ☯
    ) myFn@

    4 myFn🝢 #  ; => 8
    3 myFn🝢 #  ; => 3

  do the same thing in different ways (for fun)

    (Hello, world!)#
    ((Hello, )(world!))⚝,!j#

    ((o r,!j)⚝:!,ld,w!j)⚝
    ((, )((llo)(He))⚝!j)⚝
    #

  in summary

    ((,~,% gcd🝢) (⁐) (.0 =) ☯) gcd@
    27 9  gcd🝢# ; => 9
    18 12 gcd🝢# ; => 6
    15 30 gcd🝢# ; => 15

  (bad notes)
    - fix the formatter
      -> just make it better in general
      -> (make it an actual formatter)

'''

def special(t)
  (
    begin((t.peek).match(/[!|?|+|-|*|%|.|,|$|(|)|@|#|☯|⁐|🝠|🜁|⚝|ф|🝢| |\n|\0]/)) != nil
    rescue
      (t.to_s.match(/[!|?|+|-|*|%|.|,|$|(|)|@|#|☯|⁐|🝠|🜁|⚝|ф|🝢| |\n|\0]/)) != nil
    end
  )
end

def kraise(line ,err)
  puts "ERROR at line : #{line} :: #{err}"
  exit 1
end

def e(prog, stack=[], words={})
  prog += " "
  langvnstuff = "KNOTH (Is a Language I don't like the full-form name of anymore)\n\n  => v0.9\n"
  pn = prog.each_char
  line = 1
  strParsing = [false, ""]
  while true do
    begin
      case (zx = pn.next)
        when "♥"
          puts langvnstuff
        when "\n"
          line += 1
        when "+"
          stack.push (stack.pop + stack.pop)
        when "-"
          stack.push (stack.pop - stack.pop)
        when "/"
          begin
            stack.push (stack.pop / stack.pop)
          rescue ZeroDivisionError
            stack.push 0
          end
        when "*"
          stack.push (stack.pop * stack.pop)
        when "%"
          stack.push (stack.pop % stack.pop)
        when "^"
          stack.push (stack.pop ** stack.pop)
        when "="
          stack.push (stack.pop == stack.pop)
        when ":"
          m = pn.next
          m = m.to_i if m.to_i != 0 or m == "0"
          stack.push (m)
        when "."
          word = stack.pop
          stack.push word; stack.push word
        when ","
          thing1 = stack.pop
          thing2 = stack.pop
          stack.push thing1
          stack.push thing2
        when "~"
          thing1 = stack.pop
          thing2 = stack.pop
          stack.push thing2
          stack.push thing1
          stack.push thing2
        when ";"
          current = ""
          until pn.peek == "\n" or pn.peek == "|" and current != "/" do
            current = pn.next
          end
          pn.next
        when "!"
          m = pn.next
          stack.push(stack.pop != stack.pop) if m == "="
          stack.push((stack.pop).ord) if m == "o"
          stack.push((stack.pop).chr) if m == "c"
          sleep(stack.pop.to_i)       if m == "s"
          if m == "j"
            mj = []
            while stack.length != 0 do
              mj << stack.pop
            end
            stack.push mj.join
          end
        when ">"
          m = pn.next
          if m == "="
            stack.push(stack.pop >= stack.pop)
            next
          end
          stack.push(stack.pop > stack.pop)
        when "<"
          m = pn.next
          if m == "="
            stack.push(stack.pop <= stack.pop)
            next
          end
          stack.push(stack.pop < stack.pop)
        when "|"
          m = pn.next
          if m == "|"
            right = stack.pop
            left = stack.pop
            stack.push((left || right))
            next
          end
        when "&"
          m = pn.next
          if m == "&"
            right = stack.pop
            left = stack.pop
            stack.push((left && right))
            next
          end
        when "@"
          value = stack.pop
          word = stack.pop
          words[value] = word
        when "ф"
          word = stack.pop
          if words[word] != nil
            stack.push words[word]
          end
        when "🝢"
          word = stack.pop
          if words[word]
            result = e(words[word], stack, words)
          end
        when "⚝"
          e(stack.pop, stack, words)
        when "☯"
          # takes a condition,
          # executes the 1st block if it returns 0 or true,
          # the 2nd block if it returns anything else
          # form ->
          #   <block2> <block1> <condition> ☯
          cond   = stack.pop
          block1 = stack.pop
          block2 = stack.pop
          #puts "cond: #{cond}\nblock1: #{block1}\nblock2: #{block2}"
          e(cond, stack, words)
          #p stack
          result = stack.pop
          if result == 0 or result == true
            e(block1, stack, words)
          else
            e(block2, stack, words)
          end
        when "♲"
          # while loop
          # executes the body while its condition is true
          # form ->
          #  <block> <condition> ♲
          cond = stack.pop
          block = stack.pop
          while e(cond, stack, words) != true
            e(block, stack, words)
          end
        when "⁘"
          # each loop
          # executes a block on each element of an iterable
          # the iterable needs to support .each
          # form ->
          #  <block> <iterable> ⁘
          iter = stack.pop
          iter = iter.split('') if iter.class == String
          block = stack.pop
          iter.each do |el|
            stack.push el
            e(block, stack, words)
          end
        when "⁐"
          stack.pop
        when '$'
          # no longer for strings (obsolete)
          # now for special literal values
          value = stack.pop
          stack.push(true)  if value == "true"
          stack.push(false) if value == "false"
          stack.push(nil)   if value == "nil"
        when '('
          strblt = ""
          depth = 1
          current = ""
          strParsing = [true, 'unmatched (']
          until current == ')' and depth == 0 do
            depth += 1 if pn.peek == '('
            depth -= 1 if pn.peek == ')'
            #puts "#{depth}, #{pn.peek}"
            current = pn.next
            strblt += current if depth > 0
          end
          strParsing = [false, ""]
          #puts "ended at :: #{depth}, #{pn.peek}"
          #pn.next
          stack.push strblt
        when "🜁"
          op = stack.pop
          rs = stack.reduce { |uwu, owo|
            e(op, [uwu, owo], words) .pop
          }
          (0...stack.length).each do stack.pop end
          stack.push rs
        when "🝠"
          by = stack.pop
          str = stack.pop
          stack.push (str.split(by))
        when "⊞"
          block = stack.pop
          nscop = []
          stack.each do |s| nscop << s end
          stack.push (e(block, nscop, words))
        when "⊡"
          block = stack.pop
          stack.push (e(block, [], words))
        when "🞇"
          # parallel operator
          # performs the same block with an element from the same position in every enumerable on the stack
          offset = 0
          results = []
          block = stack.pop
          enums = []
          stack.each do |e| enums << e end
          (0...stack.length).each do stack.pop end
          enums[0].each_index do |i|
            nsta = []
            enums.each do |e|
              nsta << e[i]
            end
            result = (e(block, nsta, words))
            result.each do |r|
              results << r
            end
          end
          stack.push results
        when "‿"
          start = stack.pop
          nd = stack.pop
          stack.push (start..nd)
        when "?"
          p stack
        when "#"
          puts stack.pop
      	else
          if !(special(pn.peek)) and !(special(zx))
            until (special(pn.peek)) do
              zx += pn.next
            end
          end
          zx = zx.to_i if zx.to_i != 0 or zx == "0"
          stack.push(zx) if !(special(zx))
      end
    rescue StopIteration
      kraise(line, strParsing[1]) if strParsing[0] == true
      break
    end
  end
  p stack
  return stack
end

def fmt(s)
  recognized = {
    0 => [/var/, "ф"],
    1 => [/fn/, "🝢"],
    2 => [/eval/, "⚝"],
    3 => [/evoke/, "⚝"],
    4 => [/reduce/, "🜁"],
    5 => [/split/, "🝠"],
    6 => [/pop/, "⁐"],
    7 => [/⚞/, "("],
    8 => [/⚟/, ")"],
    9 => [/if/, "☯"],
    10 => [/range/, "‿"],
    11 => [/while/, "♲"]
  }
  recognized.each do |rgx|
    rg = rgx[1]
    s = s.sub(rg[0], rg[1]) or s
  end
  return s
end

def repl()
  while true do
    m = gets
    break if m == "exit"
    p e(fmt(m))
  end
end

# e '(#) 10 1 ‿ ⁘'

#e('(1 2 =) (1 1 =) ||')

gcd = fmt('''

; ((gcd🝢) () (0 =) if) gcd@
; ((⁐ , ~, % gcd🝢) () (0 =) if) gcd@

((,~,% gcd🝢) (⁐) (.0 =) ☯) gcd@

27 9  gcd🝢# ; => 9
18 12 gcd🝢# ; => 6
15 30 gcd🝢# ; => 15

''')

=begin
[b, a]

gcd(9, 27) == 9
[b=]
(
  (⁐ [27, 9]
  ,   [9, 27]
  ~,  [9, 9, 27]
  %   [9, 9]
  gcd🝢 [9, 9])
  ()
  (.0 =)    1: [27, 9, false]
  if
) gcd@

corrected;

(
  (,   [9, 27]
  ~,  [9, 9, 27]
  %   [9, 9]
  gcd🝢 [9, 9])
  (⁐) [9]
  (.0 =)    1: [27, 9]
  if
) gcd@
=end

=begin
prog = fmt('''

(. 2 =, 2, % 0 = ||) even@
(() (2 *) (even) if) myFn@

4 myFn fn

''')
=end

=begin
prog = '''

(. 2 =, 2, % 0 = ||) even@
4 even🝢 #  ; => true
2 even🝢 #  ; => true
3 even🝢 #  ; => false

'''
=end

#e('(. 2 =, 2, % 0 = ||) even @ 4 even 🝢')
=begin
(.  # [4, 4]
2 = # [4, true]
,   # [true, 4]
2   # [true, 4, 2]
,   # [true, 2, 4]
%   # [true, 0]
0 = # [true, true]
||  # [true]
)
=end

=begin
e('1 1 =')

e('(5 5 +) (2 2 +) (0) ☯')      # => 4
e('(5 5 +) (2 2 +) (1) ☯')      # => 10

e('(5 5 +) (2 2 +) (1 1 =) ☯')  # => 4
e('(5 5 +) (2 2 +) (1 1 !=) ☯') # => 10
e('(5 5 +) (2 2 +) (1 1 >) ☯')  # => 10
e('(5 5 +) (2 2 +) (1 1 >=) ☯') # => 4
=end

#e(fmt('⚞( . _ . )⚟ ♥ '))
#e('(1 2 +) ⚝')

=begin
# line count works now :3
e('haiii



(test (moo (moo (yay) moo) (m (moo) deng) testing) yippee ')
# =>
# ERROR at line : 4 :: unmatched (
=end

#e('haiii (test testing) yippee')

#e("4 4 + 2 *")                # 16
#e("m !o")                     # 109
#e("m !o !c")                  # "m"
#e("m !o 13 + !c")             # "z"
#e(":! world :  Hello, !j")    # "Hello, world!"
#e('$"Hello, world!" a @ a ф') # "Hello, world!"
#e('$"4 4 + 2" a @ a 𐠞')
#e('$"2 +" addTwo @ 2 addTwo 𐠞')# 4
#e('1 2 3 4 5 $"+" 𐠮')          # 15
=begin
e('''
4 4 + 2 *                      ; 16
m !o                           ; 109
m !o !c                        ; "m"
m !o 13 + !c                   ; "z"
⁐⁐⁐⁐ ; clear the stack
:! world :  Hello, !j          ; "Hello, world!"
$"Hello, world!" a @ a ф       ; "Hello, world!"
; $"4 4 + 2" a @ a 🝢
$"2 +" addTwo @ 2 addTwo 🝢     ; 4
⁐⁐⁐  ; clear the stack
1 2 3 4 5 $"+" 🜁               ; 15
''')
=end

