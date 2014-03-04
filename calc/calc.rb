Token = Struct.new(:type, :value, :ast)
Rule = Struct.new(:from, :to, :todo, :lookahead)

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
expr = "-10*(2+3)+2*-3"
#expr = "325+7*3+48"
#expr = "-(100*14)"

tokens = expr.split('').map { |el| Token.new(el, el) } 

$grammar = [
   Rule.new( ['0'],         'D', "x[0].to_i" } } ),
   Rule.new( ['1'],         'D', "x[0].to_i" } ),
=begin
   Rule.new( ['2'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['3'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['4'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['5'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['6'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['7'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['8'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['9'],         'D', ->(x) { ->() { x[0].to_i } } ),
   Rule.new( ['D', 'D'],    'F', ->(x) { ->() { x[0].call*10 + x[1].call } } ),
   Rule.new( ['F', 'D'],    'F', ->(x) { ->() { x[0].call*10 + x[1].call } } ),
   Rule.new( ['D'],         'F', ->(x) { ->() { x[0].call } } ),
   Rule.new( ['F','*','T'], 'T', ->(x) { ->() { x[0].call * x[2].call } } ),
   Rule.new( ['F','/','T'], 'T', ->(x) { ->() { x[0].call / x[2].call } } ),
   Rule.new( ['F'],         'T', ->(x) { ->() { x[0].call } } ),
   Rule.new( ['T','+','E'], 'E', ->(x) { ->() { x[0].call + x[2].call } } ),
   Rule.new( ['T','-','E'], 'E', ->(x) { ->() { x[0].call - x[2].call } } ),
   Rule.new( ['-','T'],     'T', ->(x) { ->() { -x[1].call } } ),
   Rule.new( ['T'],         'E', ->(x) { ->() { x[0].call } } ),
   Rule.new( ['(','E',')'], 'F', ->(x) { ->() { x[1].call } } )
=end
]

def start_terms(types) 
   types.inject([]) { |acc, type| 
      starts = $grammar.select {|rule| rule.to == type}.map {|rule| rule.from[0] }.uniq.select { |start| start != type }
      acc << (starts.empty? ? type : start_terms(starts))
      acc
   }.flatten
end

$grammar = $grammar.inject([]) do |acc_gr, rule|
   rule.lookahead = acc_gr.select { |bzrule| ((bzrule.from[0..rule.from.size-1] <=> rule.from) == 0) }
                   .map    { |bzrule| start_terms([ bzrule.from[rule.from.size] ]) }
                   .flatten
   rule.todo = ->(x) { ->() { eval(rule.todo) } }
   acc_gr << rule
end

print $grammar.map { |rule| rule.from.to_s + " " + rule.to + " " + rule.lookahead.to_s }.join("\n"), "\n"

def ParseLR(tokens)
   stack = []

   tokens.each_with_index.map do |token, i|
      stack << token

      begin 
         reduced = false
         $grammar.each do |rule|

            from, to, todo, lookahead = rule.to_a 

            if ( stack.size >= rule.from.size ) &&
               ( (stack[-from.size..-1].map{|t| t.type} <=> from) == 0 ) &&
               ( (i == tokens.size-1) || !lookahead.include?( tokens[i+1].type )) then

               stack[-from.size..-1] = [ Token.new( to, 
                                                    #todo.call( *stack[-from.size..-1].map(&:value) ),
                                                    todo.call( stack[-from.size..-1].map(&:value) ),
                                                    stack[ -from.size .. -1 ]) ]

               print "#{i}: ", stack.map { |t| t.type  }.join(" "), "\n", "#{i}: ", "\t\t#{from} -> [#{to}] \n"

               reduced = true
               break
            end
         end
      end while reduced
   end

   stack
end


stack = ParseLR(tokens)

print "#", stack.map { |t| t.type  }.join(" "), "\n"
print " ", stack.map { |t| t.value.call.to_s }.join(" "), "\t"


