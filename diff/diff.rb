require 'digest/md5'

$cache = {}

class Diff
   def self.diff_impl(a,b)
     
      key = Digest::MD5.hexdigest(a.to_s + " " + b.to_s) 
      return $cache[key].clone if $cache.has_key? key

      as, bs = a.size, b.size

      r = []
      r = [a.size, a.map{|x| "-"+x}] if bs == 0
      r = [b.size, b.map{|x| "+"+x}] if as == 0

      if r.empty?
         plus = a[0] == b[0] ? 0 : 2

         c = [ diff_impl(a[1..as-1], b[1..bs-1]),
               diff_impl(a[0..as-1], b[1..bs-1]),
               diff_impl(a[1..as-1], b[0..bs-1]) ]
         c[0][0] += plus 
         c[1][0] += 1
         c[2][0] += 1
 

         c[0][1] = (plus==0 ? [a[0]] : [a[0] + '/' + b[0]]) + c[0][1]
         c[1][1] = ["+"+b[0]] + c[1][1]
         c[2][1] = ["-"+a[0]] + c[2][1]

         a01 = c[0][0] <= c[1][0]

         r = c[2] 
         r = c[0] if  a01 && (c[0][0] <= c[2][0])
         r = c[1] if !a01 && (c[1][0] <= c[2][0])
      end

      $cache[key] = r.clone
      r
   end

   def self.diff(a,b)
      $cache.clear
      diff_impl a.map(&:to_s), b.map(&:to_s)
   end

end



a, b = [1,2,3,4,5,7,8,9,1,2,3,4,5,6,7,8,9], [2,3,5,6,7,1,9,4,5,6,6,7,8]
#a,b = [1,2,3,4,5], [2,3,5,6]
print a, "\n", b, "\n"


print Diff.diff(a,b), "\n"



