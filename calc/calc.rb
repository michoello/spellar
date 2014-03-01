Token = Struct.new(:type, :value, :ast);

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
#expr = "-10*(2+3)+2*-3"
expr = "125+18"
tokens = expr.split('').map { |el| Token.new(el, el) } 

$grammar = [
   [ ['0'],         'D', lambda { |x|     x.to_i } ],
   [ ['1'],         'D', lambda { |x|     x.to_i } ],
   [ ['2'],         'D', lambda { |x|     x.to_i } ],
   [ ['3'],         'D', lambda { |x|     x.to_i } ],
   [ ['4'],         'D', lambda { |x|     x.to_i } ],
   [ ['5'],         'D', lambda { |x|     x.to_i } ],
   [ ['6'],         'D', lambda { |x|     x.to_i } ],
   [ ['7'],         'D', lambda { |x|     x.to_i } ],
   [ ['8'],         'D', lambda { |x|     x.to_i } ],
   [ ['9'],         'D', lambda { |x|     x.to_i } ],

   [ ['D', 'D'],    'F', lambda { |x,y|   x*10 + y } ],
   [ ['D'],         'F', lambda { |x|     x.to_i } ],
   [ ['F','*','T'], 'T', lambda { |x,_,y| x * y } ], 
   [ ['F','/','T'], 'T', lambda { |x,_,y| x / y } ],
   [ ['-','F'],     'F', lambda { |_,x|  -x } ],
   [ ['F'],         'T', lambda { |x|     x } ],
   [ ['T','+','E'], 'E', lambda { |x,_,y| x + y} ],
   [ ['T','-','E'], 'E', lambda { |x,_,y| x - y} ],
   [ ['T'],         'E', lambda { |x|     x } ],
   [ ['(','E',')'], 'F', lambda { |_,x,_| x } ]
]


def start_terms(types) 
   types.inject([]) { |acc, type| 
      starts = $grammar.select {|rule| rule[1] == type}.map {|rule| rule[0][0] }.uniq
      acc << (starts.empty? ? type : start_terms(starts))
      acc
   }.flatten
end


print "E: ", start_terms(['E']), "\n"
print "T: ", start_terms(['T']), "\n"
print "F: ", start_terms(['F']), "\n"
print "D: ", start_terms(['D']), "\n"
print "D-(: ", start_terms(['D', '-', '(']), "\n"

#exit



$grammar = $grammar.inject([]) do |acc_gr, rule|
   rule << acc_gr.select { |bzrule| (rule[1] == bzrule[1]) && ((bzrule[0][0..rule[0].size-1] <=> rule[0]) == 0) }
                 .map    { |bzrule| start_terms([ bzrule[0][rule[0].size] ]) }
                 .flatten
   acc_gr << rule
end


print $grammar.map{ |x| x[0].to_s + " " + x[1] + " " + x[3].to_s }.join("\n"), "\n"
#exit

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
                     print "#{i}: ", stack.map { |t| t.type  }.join(" "), "\n"
                     print "#{i}: ", stack.map { |t| t.value.to_s }.join(" "), "\t"
                     print "\t#{from} -> #{to}"
                     print "\n"

                     value = todo.is_a?(Proc) ? todo.call( *stack[ -from.size .. -1 ].map(&:value) ) : 0 

                     stack[ -from.size .. -1 ] = [ Token.new( to, value, stack[ -from.size .. -1 ]) ]
                     reduced = true
                     break
                  end
               end
            end
         end
      end while reduced
   end
end


ParseLR(tokens)



