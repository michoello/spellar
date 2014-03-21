Token = Struct.new(:type, :value, :ast)
Rule = Struct.new(:from, :to, :todo, :lookahead)

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
#expr = "-10*(2+3)+2*-3"
expr = "325+7*3+48"
expr = "100-10-35"  
expr = "100/10/2"  
tokens = expr.split('').map { |el| Token.new(el, el) } 

$grammar = [
   [ ['0'],         'D', ->(x) {      x.to_i } ],
   [ ['1'],         'D', ->(x) {     x.to_i } ],
   [ ['2'],         'D', ->(x) {     x.to_i } ],
   [ ['3'],         'D', ->(x) {     x.to_i } ],
   [ ['4'],         'D', ->(x) {     x.to_i } ],
   [ ['5'],         'D', ->(x) {     x.to_i } ],
   [ ['6'],         'D', ->(x) {     x.to_i } ],
   [ ['7'],         'D', ->(x) {     x.to_i } ],
   [ ['8'],         'D', ->(x) {     x.to_i } ],
   [ ['9'],         'D', ->(x) {     x.to_i } ],

   [ ['D', 'D'],    'F', ->(x,y) {   x*10 + y } ],
   [ ['F', 'D'],    'F', ->(x,y) {   x*10 + y } ],
   [ ['D'],         'F', ->(x)   {   x } ],

   [ ['F','*','T'], 'T', ->(x,_,y) { x * y } ], 
   [ ['T','/','F'], 'T', ->(x,_,y) { x / y } ],
   [ ['F'],         'T', ->(x)     {   x } ],
   [ ['E','+','T'], 'E', ->(x,_,y) { x + y} ],
   [ ['E','-','T'], 'E', ->(x,_,y) { x - y} ],
   [ ['-','F'],     'F', ->(_,x)   {  -x } ],
   [ ['T'],         'E', ->(x)     { x } ],
   [ ['(','E',')'], 'F', ->(_,x,_) { x } ]
]

def start_terms(types) 
   types.inject([]) { |acc, type| 
      starts = $grammar.select {|rule| rule[1] == type}.map {|rule| rule[0][0] }.uniq.select { |start| start != type }
      acc << (starts.empty? ? type : start_terms(starts))
      acc
   }.flatten
end

$grammar = $grammar.inject([]) do |acc_gr, rule|
   rule << acc_gr.select { |bzrule| ((bzrule[0].take( rule[0].size ) <=> rule[0]) == 0) }
                 .map    { |bzrule| start_terms([ bzrule[0][rule[0].size] ]) }
                 .flatten
   acc_gr << rule
end

print $grammar.map { |rule| rule.from.to_s + " " + rule.to + " " + rule.lookahead.to_s }.join("\n"), "\n"

class Array
   def tail n
      n < self.size ? self[-n .. -1] : self
   end
end


print $grammar.map{ |x| x[0].to_s + " " + x[1] + " " + x[3].to_s }.join("\n"), "\n"

def ParseLR(tokens)
   stack = []

   tokens.each_with_index.map do |token, i|
      stack << token

      begin 
         reduced = false
         $grammar.each do |rule|
            from, to, todo, lookahead = rule 
            if ( stack.tail(from.size).map{|t| t.type} <=> from) == 0 
            then
               unless (i < tokens.size-1) && lookahead.include?( tokens[i+1].type ) then
                  value = todo.is_a?(Proc) ? todo.call( *stack.tail(from.size).map(&:value) ) : 0 

                  print "#{i}: ", stack.map { |t| t.type  }.join(" "), "\n"
                  print "#{i}: ", stack.map { |t| t.value.to_s }.join(" "), "\t"
                  print "\t#{from} -> [#{to}] [#{value}]"
                  print "\n"

                  stack.push Token.new( to, value, stack.pop(from.size) ) 
                  reduced = true
                  break
               end
            end
         end
      end while reduced
   end

   stack
end


stack = ParseLR(tokens)

print "#", stack.map { |t| t.type  }.join(" "), "\n"
print " ", stack.map { |t| t.value.call.to_s }.join(" "), "\t"


