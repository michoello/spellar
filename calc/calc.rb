Token = Struct.new(:type, :value, :ast);

#expr = "- 10 * 5 * ( 2 + - 4 ) - 20 / ( 2 * 10 ) + 8"
expr = "- 10 * ( 2 + 3 ) + 2 * - 3"
tokens = expr.split(' ').map { |el| Token.new( el.match(/\d+/) ? 'I' : el, el ) } 

grammar = [
   [ ['I'],         'F', lambda { |x| "AZAZ: [" + x[0].value + "]" } ],
   [ ['F','*','T'], 'T', nil ],
   [ ['F','/','T'], 'T', nil ],
   [ ['-','F'],     'F', nil ],
   [ ['F'],         'T', nil ],
   [ ['T','+','E'], 'E', nil ],
   [ ['T','-','E'], 'E', nil ],
   [ ['T'],         'E', nil ],
   [ ['(','E',')'], 'F', nil ]
]

grammar = grammar.inject([]) do |acc_gr, rule|
   rule << acc_gr.select { |bzrule| (rule[1] == bzrule[1]) && ((bzrule[0][0..rule[0].size-1] <=> rule[0]) == 0) }
                 .map    { |bzrule| bzrule[0][ rule[0].size ] }
   acc_gr << rule
end

def findrule(tokens, grammar)
   stack = []

   tokens.each_with_index.map do |token, i|
      print "#{i}: ", stack.map { |t| t.type }.join(" "), "\n"
      stack << token

      begin 
         print "#{i}: ", stack.map { |t| t.type }.join(" "), "\t"
         reduced = false
         grammar.each do |rule|
            from, to, todo, lookahead = rule 
            if ( stack.size >= from.size ) then
               if ( stack[ -from.size .. -1 ].map{|t| t.type} <=> from) == 0 
               then
                  unless (i < tokens.size-1) && lookahead.include?( tokens[i+1].type ) then
                     print "\t#{from} -> #{to}" 

                     if todo.is_a? Proc then
                         print "\tAHAHA!\t [", todo.call( stack[ -from.size .. -1 ] ), "]"
                     end
                       
                     stack[ -from.size .. -1 ] = [ Token.new( to, nil, stack[ -from.size .. -1 ]) ]
                     reduced = true
                     break
                  end
               end
            end
         end
         print "\n"
      end while reduced
   end

   
   


end


findrule(tokens, grammar)



