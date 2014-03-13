Token = Struct.new(:type, :value, :ast);

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
#expr = "-10*(2+3)+2*-3"
expr = "325+7*3+48"

expr = "12-346+6789"
expr = "12-345"
tokens = expr.split('').map { |el| Token.new(el, el) } 

$grammar = [
   [ ['0'],         'D', ->(x) {     x.to_i } ],
   [ ['1'],         'D', ->(x) {     x.to_i } ],
   [ ['2'],         'D', ->(x) {     x.to_i } ],
   [ ['3'],         'D', ->(x) {     x.to_i } ],
   [ ['4'],         'D', ->(x) {     x.to_i } ],
   [ ['5'],         'D', ->(x) {     x.to_i } ],
   [ ['6'],         'D', ->(x) {     x.to_i } ],
   [ ['7'],         'D', ->(x) {     x.to_i } ],
   [ ['8'],         'D', ->(x) {     x.to_i } ],
   [ ['9'],         'D', ->(x) {     x.to_i } ],

   [ ['D', 'F'],    'F', ->(x,y) {   x*10 + y } ],
   [ ['D'],         'F', ->(x)   {   x } ],
   [ ['F','-','E'], 'E', ->(x,_,y) { x + y} ],
   [ ['F','+','E'], 'E', ->(x,_,y) { x + y} ],

=begin
   [ ['T','*','F'], 'T', ->(x,_,y) { x * y } ], 
   [ ['T','/','F'], 'T', ->(x,_,y) { x / y } ],
   [ ['F'],         'T', ->(x)     {   x } ],
   [ ['E','+','T'], 'E', ->(x,_,y) { x + y} ],
   [ ['E','-','T'], 'E', ->(x,_,y) { x - y} ],
   [ ['-','F'],     'F', ->(_,x)   {  -x } ],
   [ ['T'],         'E', ->(x)     { x } ],
   [ ['(','E',')'], 'F', ->(_,x,_) { x } ]
=end
]

def start_terms(types) 
   types.inject([]) { |acc, type| 
      starts = $grammar.select {|rule| rule[1] == type}.map {|rule| rule[0][0] }.uniq.select { |start| start != type }
      acc << (starts.empty? ? type : start_terms(starts))
      acc
   }.flatten
end

$grammar = $grammar.inject([]) do |acc_gr, rule|
   rule << acc_gr.select { |bzrule| ((bzrule[0][0..rule[0].size-1] <=> rule[0]) == 0) }
                 .map    { |bzrule| start_terms([ bzrule[0][rule[0].size] ]) }
                 .flatten
   acc_gr << rule
end

#print "E: ", start_terms(['E']), "\n"
#print "T: ", start_terms(['T']), "\n"
#print "F: ", start_terms(['F']), "\n"
#print "D: ", start_terms(['D']), "\n"
#print "1: ", start_terms(['1']), "\n"
#print $grammar.map{ |x| x[0].to_s + " " + x[1] + " " + x[3].to_s }.join("\n"), "\n"
#print "\n\n"


def is_term(type)
   $grammar.select{|rule| rule[1] == type}.empty?
end

def applyRule(tokens, rulezz)
    
   stack, i, result,stack2 = rulezz

   print "CURRENT RESULT: ", result, "\n"

   while ( !stack.empty? && i < tokens.size ) do
      top = stack[-1]
      if is_term(top[0]) then
         if (top[0] == tokens[i].value ) then
            stack.pop
            i = i + 1
         else
            i = -1
         end
      else
         i = ParseLL(stack, result, tokens, i)
      end
      
      break if i == -1
   end

   return i 
end


def ParseLL(stack, result, tokens, i=0)
   top = stack.pop 

   rules = $grammar.select {|rule| (rule[1] == top[0]) && start_terms([ rule[0][0] ])
                   .include?(tokens[i].value) }
                   .map do |rule| 
                                 rlz = rule[0].map {|r| [r] }
                                 [ stack.clone.push(*rlz.reverse), 
                                   i,
                                   result.clone.push(rlz) ,
                                   stack.clone.push(rlz.reverse) 
                                 ] 
                   end
   i = -1
   while (!rules.empty? && i < tokens.size) do
      i = applyRule(tokens, rules.pop) 
   end

   return i 
end

init = [["E"]]

stack = ParseLL(init, [init], tokens)


