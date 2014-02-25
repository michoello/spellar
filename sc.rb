Trie = Struct.new(:w, :t)

h = { 'a' => 1, 'b' => 2}




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

   team = r.road.t.map { |dst, road| Rambler.new(r.todo, r.done + dst, r.cost + 1, road) }         # insert

   return team if r.todo.empty?

   if r.road.t.has_key?(r.todo[0])
      team << Rambler.new(r.todo[1..-1], r.done + r.todo[0], r.cost, r.road.t[r.todo[0]])     # staight or finish
   end

   team += r.road.t.map { |dst, road| Rambler.new(r.todo[1..-1], r.done + dst, r.cost + 1, road)  }          # replace 
   team << Rambler.new(r.todo[1..-1], r.done, r.cost + 1, r.road)  # delete   # this line is tricky, it contains implicit return, as it is the last in inject block
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
