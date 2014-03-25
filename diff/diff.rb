require 'digest/md5'

$cache = {}

class Diff
   def self.diff_impl(a,b)
     
      key = Digest::MD5.hexdigest(a.to_s + " " + b.to_s) 
      return $cache[key].clone if $cache.has_key? key

      as, bs = a.size, b.size

      r = [666, []]
      r2 = [666,[]]

      if bs != 0
         r = diff_impl(a[0..as-1], b[1..bs-1])
         r = [ r[0]+1, ["+"+b[0]] + r[1] ]
      else
         r = [a.size, a.map{|x| "-"+x}] 
      end

      if as != 0
         r2 = diff_impl(a[1..as-1], b[0..bs-1])
         r2 = [ r2[0]+1, ["-"+a[0]] + r2[1] ]
      else
         r2 = [b.size, b.map{|x| "+"+x}] 
      end

      r = r2 if r2[0] < r[0] 

      if as != 0 && bs != 0 && a[0] == b[0]
         r2 = diff_impl(a[1..as-1], b[1..bs-1])
         r2[1] =  [a[0]] + r2[1]

         r = r2 if r2[0] < r[0] 
      end
      
       
      #r[1] = [firstel] + r[1] unless firstel == [] 

      $cache[key] = r.clone
      r
   end

   def self.diff(a,b)
      $cache.clear
      diff_impl a.map(&:to_s), b.map(&:to_s)
   end

end

Cand = Struct.new(:price, :a, :b, :way)

class Diff2
   def self.diff(a,b)
      a1, b1 = a.map(&:to_s), b.map(&:to_s)

      rs = [ Cand.new(0, a1, b1, []) ]

      until rs.empty? do
         newrr = []
         newrr2 = rs.map do |r|
            price, aa, bb, way = r.values
            as, bs = aa.size, bb.size

            if as == 0 && bs == 0
               return way
            end
            
            brr = []

            if bs > 0
               newrr << Cand.new(price + 1, aa[0..as-1], bb[1..bs-1], way + [ "+" + bb[0] ])
               brr << Cand.new(price + 1, aa[0..as-1], bb[1..bs-1], way + [ "+" + bb[0] ])
            end
            if as > 0
               newrr << Cand.new(price + 1, aa[1..as-1], bb[0..bs-1], way + [ "-" + aa[0] ])
            end
            if as > 0 && bs > 0 &&  aa[0] == bb[0]
               newrr << Cand.new( price, aa[1..as-1], bb[1..bs-1], way + [ aa[0] ])
            end

         end.flatten

         rs = newrr.sort{ |x,y| x.price <=> y.price }[0..100]
      end

   end
end



a, b = [1,2,3,4,5,7,8,9,1,2,3,4,5,6,7,8,9], [2,3,5,6,7,1,9,4,5,6,6,7,8]
#a, b = [1,2,3,4,5], [2,3,5,6]
#a, b = [1,2], [2,3]
print a, "\n", b, "\n"


print Diff.diff(a,b), "\n"
print Diff2.diff(a,b), "\n"



