require 'digest/md5'

$cache = {}

class Diff
   def self.diff_impl(a,b,firstel = [])
     
      key = Digest::MD5.hexdigest(a.to_s + " " + b.to_s) 
      return $cache[key].clone if $cache.has_key? key

      as, bs = a.size, b.size

      r = []
      r = [a.size, a.map{|x| "-"+x}] if bs == 0
      r = [b.size, b.map{|x| "+"+x}] if as == 0

      if r.empty?

         r1 = diff_impl(a[0..as-1], b[1..bs-1])
         r2 = diff_impl(a[1..as-1], b[0..bs-1])

         r1[0] += 1
         r2[0] += 1

         
         r3 = diff_impl(a[1..as-1], b[1..bs-1])
         plus = a[0] == b[0] ? 0 : 2
         r3[0] += plus 
         r3[1] = (plus==0 ? [a[0]] : [a[0] + '/' + b[0]]) + r3[1]

         r1[1] = ["+"+b[0]] + r1[1]
         r2[1] = ["-"+a[0]] + r2[1]



         a01 = r3[0] <= r1[0]

         r = r2 
         r = r3 if  a01 && (r3[0] <= r2[0])
         r = r1 if !a01 && (r1[0] <= r2[0])



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



a, b = [1,2,3,4,5,7,8,9,1,2,3,4,5,6,7,8,9], [2,3,5,6,7,1,9,4,5,6,6,7,8]
#a,b = [1,2,3,4,5], [2,3,5,6]
print a, "\n", b, "\n"


print Diff.diff(a,b), "\n"



