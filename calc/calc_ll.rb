Token = Struct.new(:type, :value, :ast);

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
#expr = "-10*(2+3)+2*-3"
expr = "325+7*3+48"

#expr = "123+45+6789"
expr = "12-346+6789"
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

$result = [['E']]

def ParseLL(stack, tokens, i=0)
   stackorig, iorig = stack.clone, i

   rules = $grammar.select {|rule| (rule[1] == stack[-1]) && start_terms([ rule[0][0] ]).include?(tokens[i].value) }.reverse

   rules.each do |rule|
      stack.pop 
      stack.push( *rule[0].reverse )
   
      $result.push( rule[0] )
      print "RESULT PSH: ", $result, "\n"

      while ( !stack.empty? ) do
         if is_term(stack[-1]) 
         then
            if ( stack[-1] == tokens[i].value ) then
               stack.pop
               print "#{i}: ---------------------------------------------- TERM IS OK, moving forward #{tokens[i].value}\n"
               i = i + 1
            else
               print "#{i}: ---------------------------------------------- TERM IS BAD NEXT IN TEXT [#{tokens[i].value}] NEXT IN RULE [#{stack[-1]}]\n"
               $result.pop
               print "RESULT PAP: ", $result, "\n"
               break
            end
         else
            ii = ParseLL(stack, tokens, i)
            if ( ii == -1 )
                $result.pop
                print "RESULT PUP: ", $result, "\n"
                break
            end
            i = ii
         end

         if (i == tokens.size) then
#            print "FINITA: [#{rule[0]}] -> [#{rule[1]}]\n"
            return i
         end
        
      end

      stack, i = stackorig.clone, iorig
   end

   return -1 
end

stack = ParseLL(['E'], tokens)
