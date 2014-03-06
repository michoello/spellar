Token = Struct.new(:type, :value, :ast);

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
#expr = "-10*(2+3)+2*-3"
expr = "325+7*3+48"

expr = "32-7"
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

   [ ['D', 'D'],    'F', ->(x,y) {   x*10 + y } ],
   [ ['F', 'D'],    'F', ->(x,y) {   x*10 + y } ],
   [ ['D'],         'F', ->(x)   {   x } ],

   [ ['T','*','F'], 'T', ->(x,_,y) { x * y } ], 
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
   rule << acc_gr.select { |bzrule| ((bzrule[0][0..rule[0].size-1] <=> rule[0]) == 0) }
                 .map    { |bzrule| start_terms([ bzrule[0][rule[0].size] ]) }
                 .flatten
   acc_gr << rule
end

print "E: ", start_terms(['E']), "\n"
print "T: ", start_terms(['T']), "\n"
print "F: ", start_terms(['F']), "\n"
print "D: ", start_terms(['D']), "\n"
print "1: ", start_terms(['1']), "\n"


print $grammar.map{ |x| x[0].to_s + " " + x[1] + " " + x[3].to_s }.join("\n"), "\n"
print "\n\n"


def is_term(type)
   $grammar.select{|rule| rule[1] == type}.empty?
end


def ParseLL(stack, tokens, i=0)

   token = tokens[i]

   ruleto = stack[-1]


   if ( is_term(ruleto) ) then
      i = i + 1
      stack = sta

   else
      goodrules = $grammar.select {|rule| (rule[1] == ruleto) && start_terms([ rule[0][0] ]).include?(token.value) }.reverse

      print "CUR: #{ruleto} TOKEN:#{token.value} ", goodrules.map{|r| r[0].to_s + " " + r[1]}.join(", "), "\n"

      stack[-1..-1] = goodrules[0][0].reverse

      print "STACK: ", stack, "\n"

      if ( stack[-1] != ruleto ) then
         print "SHJIT #{stack[-1]} #{ruleto}\n"
         ParseLL(stack, tokens, i)
      end
   end

   stack
end

stack = ['E']
stack = ParseLL(stack, tokens)
#stack = ParseLL(stack, tokens)
#stack = ParseLL(stack, tokens)
#stack = ParseLL(stack, tokens)
#stack = ParseLL(stack, tokens)
exit

print "#", stack.map { |t| t.type  }.join(" "), "\n"
print " ", stack.map { |t| t.value.to_s }.join(" "), "\t"

exit



def ParseLR(tokens)
   stack = []

   tokens.each_with_index.map do |token, i|
      print "#{i}: ", stack.map { |t| t.type }.join(" "), "\n"
      stack << token

      begin 

         reduced = false
         $grammar.each do |rule|
            from, to, todo, lookahead = rule 
            if ( stack.size >= from.size ) then
               if ( stack[ -from.size .. -1 ].map{|t| t.type} <=> from) == 0 
               then
                  unless (i < tokens.size-1) && lookahead.include?( tokens[i+1].type ) then
                     value = todo.is_a?(Proc) ? todo.call( *stack[ -from.size .. -1 ].map(&:value) ) : 0 

                     print "#{i}: ", stack.map { |t| t.type  }.join(" "), "\n"
                     print "#{i}: ", stack.map { |t| t.value.to_s }.join(" "), "\t"
                     print "\t#{from} -> [#{to}] [#{value}]"
                     print "\n"

                     stack[ -from.size .. -1 ] = [ Token.new( to, value, stack[ -from.size .. -1 ]) ]
                     reduced = true
                     break
                  end
               end
            end
         end
         #if !reduced   #WRONG! think about it
         #   print "ERROR marked <---: ", tokens.each_with_index.select {|tok, ii| ii < i }.map{|tok,_| tok.value }.join("")
         #   print "<---", tokens.each_with_index.select {|tok, ii| ii >= i }.map{|tok,_| tok.value}.join(""), "\n"
         #   exit
         #end
      end while reduced
   end
   stack
end


stack = ParseLR(tokens)

print "#", stack.map { |t| t.type  }.join(" "), "\n"
print " ", stack.map { |t| t.value.to_s }.join(" "), "\t"


