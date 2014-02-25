Trie = Struct.new(:w, :t)

File.open(ARGV[0]).each do |word|
   dict = $trie ||= Trie.new(0, {}) 

   word.each_char do |c|
      dict.w += 1
      dict = dict.t[c] ||= Trie.new(0, {})
   end
end
puts 'Ready!';

Rambler = Struct.new(:todo, :done, :cost, :road) do
   def chance; Math.log((road.w+1)*(done.size+1))/(1<<cost); end
end

def rambiter(r)
   return r if r.road.t.keys.empty?

   team = []
   nxt  = r.todo.empty? ? "\n" : r.todo[0]
   todo = r.todo.empty? ? "" : r.todo[1..-1]

   if r.road.t.has_key?(nxt)
      team << Rambler.new(todo, r.done + nxt, r.cost, r.road.t[nxt])     # staight or finish
   end

   r.road.t.select { |x| x != nxt }.each do |dst, road|
      team << Rambler.new(todo, r.done + dst, r.cost + 1, road)           # replace 
      team << Rambler.new(r.todo, r.done + dst, r.cost + 1, road)         # insert
   end
   team << Rambler.new(todo, r.done, r.cost + 1, r.road) if nxt != "\n"   # delete   # this line is tricky, it contains implicit return, as it is the last in inject block
   team
end

def spellcheck(word, max_cost, team_size)
   stup = lambda do |walkers|; puts "Iteration #{walkers.size}"
      walkers2 = walkers.map{|r| rambiter(r)}.flatten
      if ( walkers2.size > walkers.size ) # something new in the crowd
         stup.call( walkers2.select{|r| r.cost <= max_cost}.sort{|a, b| b.chance <=> a.chance}[0..team_size] )
      else
          walkers
      end
   end

   stup.call([Rambler.new(word, "", 0, $trie)])
          .sort!{|a,b| (a.done <=> b.done) * 2 + (a.cost <=> b.cost) }
          .uniq!{|r| r.done}
          .sort!{|a,b| a.cost <=> b.cost}[0..10]
end

STDIN.each_line do |word|
    print "#{word}\n", spellcheck(word, word.size/2, 512).map{ |r| "\t#{r.done} #{r.cost} [#{r.road.t.keys}]" }.join("\n"), "\n"
end
