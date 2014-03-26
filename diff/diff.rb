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
   as, bs = a.size, b.size
   rs = [ Cand.new(0, 0, 0, []) ]

   until rs.empty? do
      rs = rs.map do |r|
         price, ai, bi, diff = r.values
#         as, bs = aa.size, bb.size

         if ai == as-1 && bi == bs-1
            compact(diff, w)
            compact(diff.reverse, w)
            return diff.map do |x| 
               if x.w == 0 
                  "...\n"
               elsif x.op < 0 
                  "- " + x.i.to_s + " " + b[x.i]
               else 
                 (x.op > 0 ? "+ " : "  ") + x.i.to_s + " " + a[x.i]
               end
#               ( (x.op > 0) ? "+" :(x.op < 0 ? "-" : " ")) + " " + x.w.to_s + " " + x.i.to_s + " " + x.line 
            end.chunk{|x| x}.map(&:first)
         end
          
         rs1 = []
         rs1 << Cand.new(price+1,   ai, bi+1, diff + [ Res.new(+1, bi, "+ " + b[bi], 0)]) if bi < bs
         rs1 << Cand.new(price+1, ai+1,   bi, diff + [ Res.new(-1, ai, "- " + a[ai], 0)]) if ai < as
         rs1 << Cand.new(price,   ai+1, bi+1, diff + [ Res.new( 0, ai, "  " + a[ai], 0)]) if ai < as && bi < bs &&  a[ai] == b[bi]
         rs1

      end.flatten.sort{ |x,y| x.price <=> y.price }[0..20]
   end
end

#print diff(IO.readlines(ARGV[0]), IO.readlines(ARGV[1])).map(&:line).join("")
a, b = IO.readlines(ARGV[0]), IO.readlines(ARGV[1])
#print diff(4, a, b).map { |x| "[" + x.w.to_s + "] " + x.line }.join("")
print diff(4, a, b).join("")
