Trie = Struct.new(:w, :t)

File.open(ARGV[0]).each do |word|
   dict = $trie ||= Trie.new(0, {}) 

   word.each_char do |c|
      dict.w += 1
      dict = dict.t[c] ||= Trie.new(0, {})
   end
end
puts 'start!';

Rambler = Struct.new(:todo, :done, :cost, :road) do
   def chance; Math.log( (road.w+1)*(done.size+1))/(1<<cost); end
end

def spellcheck(word, max_cost, team_size)
  leaders, walkers = [], [Rambler.new(word, "", 0, $trie)] 

  until walkers.empty? do; puts "New iteration\n"
    team = []

    walkers.each do |r|
        #nxt = r.todo == "\n" ? "\n" : r.todo[0]
        nxt = r.todo[0]
        todo = r.todo == "\n" ? "\n" : r.todo[1..-1]
   
        r.road.t.each do |dst, road|
            if(nxt == dst) then
                team.push(Rambler.new( todo, r.done + dst, r.cost, road)) if nxt != "\n"
                leaders.push(r) if nxt=="\n" 
            else
                team.push(Rambler.new( todo, r.done + dst, r.cost + 1, road))
                team.push(Rambler.new(r.todo, r.done + dst, r.cost + 1, road))
            end
        end
        team.push(Rambler.new( todo, r.done, r.cost + 1, r.road)) if nxt #!= "\n"
    end
    walkers = team.select{ |r| r.cost < max_cost }.sort{ |a, b| b.chance <=> a.chance }[0..team_size]
  end

  if leaders.empty?
     leaders 
  else
    leaders.sort!{|a,b| (a.done <=> b.done) * 2 + (a.cost <=> b.cost) }
         .uniq!{|r| r.done}
         .sort!{|a,b| a.cost <=> b.cost}[0..10]
  end
end

STDIN.each_line do |word|
    print "#{word}\n", spellcheck(word, word.size/2, 512).map{ |r| "\t#{r.done} #{r.cost}" }.join("\n"), "\n"
end

























exit

fib = Fiber.new do  
   x, y = 0, 1 
   loop do  
      Fiber.yield y 
      x,y = y,x+y 
   end 
end 

20.times { puts fib.resume }


f = g = nil
f = Fiber.new {|x|
    puts "f1: #{x}"
    x = g.transfer(x+1)
    puts "f2: #{x}"
    x = g.transfer(x+1)
    puts "f3: #{x}"
    x + 1
}

g = Fiber.new {|x|
    puts "g1: #{x}"
    x = f.transfer(x+1)
    puts "g2: #{x}"
    x = f.transfer(x+1)
}

puts f.transfer(1)





exit


STDIN.each_line do |a|
   puts a.chomp("\n").reverse
end

