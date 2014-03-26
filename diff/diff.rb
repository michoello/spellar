Cand = Struct.new(:price, :a, :b, :diff)
Res = Struct.new(:op, :line, :weight)

def diff(a,b)
   rs = [ Cand.new(0, a, b, []) ]

   until rs.empty? do
      rs = rs.map do |r|
         price, aa, bb, diff = r.values
         as, bs = aa.size, bb.size

         if as == 0 && bs == 0
            return diff
         end

          
         rs1 = []
         rs1 << Cand.new(price + 1, aa[0..as-1], bb[1..bs-1], diff + [ "+ " + bb[0] ]) if bs > 0
         rs1 << Cand.new(price + 1, aa[1..as-1], bb[0..bs-1], diff + [ "- " + aa[0] ]) if as > 0
         rs1 << Cand.new(price, aa[1..as-1], bb[1..bs-1], diff + [ "  " + aa[0] ]) if as > 0 && bs > 0 &&  aa[0] == bb[0]
         rs1

      end.flatten.sort{ |x,y| x.price <=> y.price }[0..20]
   end
end

def compact(arr)

   diff_i = -1
   arr.map do |el|
     
 

   end
end

print diff(IO.readlines(ARGV[0]), IO.readlines(ARGV[1])).join("")
