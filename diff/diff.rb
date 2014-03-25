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

         r = diff_impl(a[0..as-1], b[1..bs-1])
         r = [ r[0]+1, ["+"+b[0]] + r[1] ]

         r2 = diff_impl(a[1..as-1], b[0..bs-1])
         r2 = [ r2[0]+1, ["-"+a[0]] + r2[1] ]

         r = r2 if r2[0] < r[0] 

         if a[0] == b[0]
            r2 = diff_impl(a[1..as-1], b[1..bs-1])
            r2[1] =  [a[0]] + r2[1]

            r = r2 if r2[0] < r[0] 
         end
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



