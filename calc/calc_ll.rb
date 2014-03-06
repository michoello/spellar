Token = Struct.new(:type, :value, :ast);

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
#expr = "-10*(2+3)+2*-3"
expr = "325+7*3+48"

expr = "123+45"
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

   [ ['F', 'D'],    'F', ->(x,y) {   x*10 + y } ],
   [ ['D'],         'F', ->(x)   {   x } ],
   [ ['F','+','E'], 'E', ->(x,_,y) { x + y} ],
#   [ ['F','-','E'], 'E', ->(x,_,y) { x + y} ],

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

$i = 0


$RULEST

def ParseLL(stack, tokens, i=0)
#   print "#{$i} WE ARE CALLED WITH STACK: #{stack}\n"; s = gets; exit if s == "q\n"

#   if 1 then
      stackorig, iorig = stack.clone, i

      rules = $grammar.select {|rule| (rule[1] == stack[-1]) && start_terms([ rule[0][0] ]).include?(tokens[i].value) }.reverse
#      print "WE HAVE ON TOP NOW #{stack[-1]}, and possible rules are ", rules.map{|rule| "[" + rule[0].to_s + "]"}.join(", "), "\n"

      rules.each do |rule|
       #  print "#{i}: NOW RULE: [ #{rule[0]} #{rule[1]} ]\nSTACK WAS: #{stack}\n"
         stack.pop 
         stack.push( *rule[0].reverse )
      #   print "#{i}: STACK NOW: #{stack}\n"

         while ( !stack.empty? ) do
     #       print "#{i} CALL WITH NEXT ELT OF STACK #{stack}\n"

            if is_term(stack[-1]) 
            then
    #           print "#{i}: TERM FOUND: #{tokens[i].value}\n"
               if ( stack[-1] == tokens[i].value ) then
                  stack.pop
                  print "#{i}: ---------------------------------------------- TERM IS OK, moving forward #{tokens[i].value}\n"
                  i = i + 1
               else
   #               print "#{i} TERM IS WRONG, EXPECTED [#{stack[-1]}]\n"
                  break
               end
            else
               i = ParseLL( stack, tokens, i)
            end

  #          print "[#{i}]: STACK OOO: #{stack}\n"
            if ( i == tokens.size ) then
               print "FINITA: [#{rule[0]}] -> [#{rule[1]}]\n"
               return i
            end
        
         end
 #        print "TRY NEXT RULE\n"

         stack, i = stackorig.clone, iorig
      end
#      print "NO MORE RULES AT THIS LEVEL\n"
#   end
#   print "LEVEL UP: #{i}!\n"
   return i
end

stack = ParseLL(['E'], tokens)
