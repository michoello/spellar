Cand = Struct.new(:price, :ai, :bi, :diff)
Res = Struct.new(:op, :i, :w)

class Array
   def taint(w)
      self.each_cons(2) do |x,y|
         y.w += x.w - 1 if y.op == 0 && x.w > 0
      end
      self.reverse
   end
end

# w is amount of lines surrounding modified parts, a and b are compared arrays
def diff(a, b, f, w)
   as, bs, rs = a.size, b.size, [ Cand.new(0, 0, 0, []) ]

   until rs.empty? do
      rs = rs.map do |r|
         price, ai, bi, diff = r.values

         if ai == as-1 && bi == bs-1
            return diff.taint(w).taint(w).map do |x| 
               if x.w == 0 
                  "...\n"
               elsif x.op <= 0 
                  (x.op ==0 ? "  " : "- ") + (x.i+1).to_s + " " + a[x.i]
               else 
                  "+ " + (x.i+1).to_s + " " + b[x.i]
               end
            end.chunk{|x| x}.map(&:first) # uniq adjacent
               .join("")
         end
          
         rs1 = []
         rs1 << Cand.new(price+1,   ai, bi+1, diff + [Res.new(+1, bi, w)]) if bi < bs
         rs1 << Cand.new(price+1, ai+1,   bi, diff + [Res.new(-1, ai, w)]) if ai < as
         rs1 << Cand.new(price,   ai+1, bi+1, diff + [Res.new( 0, ai, 0)]) if ai < as && bi < bs && a[ai] == b[bi]
         rs1

      end.flatten.sort{|x,y| x.price <=> y.price}[0..f]
   end
end

a, b = IO.readlines(ARGV[0]), IO.readlines(ARGV[1])
print diff(a, b, 20, 4)
