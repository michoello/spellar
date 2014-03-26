Cand = Struct.new(:price, :a, :b, :diff)
Res = Struct.new(:op, :i, :line, :w)

def compact(d, w)
   rr = 0
   d.each do |x| 
      rr = x.op != 0 ? w : rr-1; 
      rr = 0 if rr < 0; 
      x.w += rr 
   end
end

# w is amount of lines surrounding modified parts, a and b are compared arrays
def diff(w,a,b)
   rs = [ Cand.new(0, a, b, []) ]

   until rs.empty? do
      rs = rs.map do |r|
         price, aa, bb, diff = r.values
         as, bs = aa.size, bb.size

         if as == 0 && bs == 0
            compact(diff, w)
            compact(diff.reverse, w)
            return diff 
         end
          
         rs1 = []
         rs1 << Cand.new(price + 1, aa[0..as-1], bb[1..bs-1], diff + [ Res.new(+1, 666, "+ " + bb[0], 0)]) if bs > 0
         rs1 << Cand.new(price + 1, aa[1..as-1], bb[0..bs-1], diff + [ Res.new(-1, 666, "- " + aa[0], 0)]) if as > 0
         rs1 << Cand.new(price,     aa[1..as-1], bb[1..bs-1], diff + [ Res.new( 0, 666, "  " + aa[0], 0)]) if as > 0 && bs > 0 &&  aa[0] == bb[0]
         rs1

      end.flatten.sort{ |x,y| x.price <=> y.price }[0..20]
   end
end

#print diff(IO.readlines(ARGV[0]), IO.readlines(ARGV[1])).map(&:line).join("")
print diff(4, IO.readlines(ARGV[0]), IO.readlines(ARGV[1])).map { |x| "[" + x.w.to_s + "] " + x.line }.join("")
