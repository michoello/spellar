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

def spellcheck(word, max_cost, team_size)
   leaders, walkers = [], [Rambler.new(word, "", 0, $trie)] 

   until walkers.empty? do; puts "Iteration #{walkers.size} #{leaders.size}"
      walkers = walkers.inject([]) do |team, r|
         nxt, todo = r.todo[0], r.todo[1..-1]
         todo = "\n" if todo.empty? 

         r.road.t.each do |dst, road|
            if(nxt == dst) then
                nxt != "\n" ? team << Rambler.new( todo, r.done + dst, r.cost, road) # straight
                            : leaders << r                                           # finish
            else
                team << Rambler.new( todo, r.done + dst, r.cost + 1, road)           # replace 
                team << Rambler.new(r.todo, r.done + dst, r.cost + 1, road)          # insert
            end
         end
         team << Rambler.new( todo, r.done, r.cost + 1, r.road) #if nxt != "\n"      # delete

      end .select{ |r| r.cost <= max_cost }
          .sort{ |a, b| b.chance <=> a.chance }[0..team_size]
   end

   leaders.sort!{|a,b| (a.done <=> b.done) * 2 + (a.cost <=> b.cost) }
          .uniq!{|r| r.done}
          .sort!{|a,b| a.cost <=> b.cost}[0..10]
end

STDIN.each_line do |word|
    print "#{word}\n", spellcheck(word, word.size/2, 512).map{ |r| "\t#{r.done} #{r.cost}" }.join("\n"), "\n"
end
