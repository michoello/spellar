a = [2,3,4,1,2,3,4,5,6,7,8]
b = [3,4,5,6,8,9]

print a, b, "\n"



def diff(a,b)
   as, bs = a.size, b.size
   return [a.size, a.map{|x| "-"+x.to_s}] if bs == 0
   return [b.size, b.map{|x| "+"+x.to_s}] if as == 0

   plus = a[0] == b[0] ? 0 : 1
  
   c = [] 
   c[0] = diff(a[1..as-1], b[1..bs-1])
   c[1] = diff(a[0..as-1], b[1..bs-1])
   c[2] = diff(a[1..as-1], b[0..bs-1])
   c[0][0] += plus*2
   c[1][0] += 1
   c[2][0] += 1

   c[0][1] = (plus==0 ? [a[0]] : [a[0].to_s + '/' + b[0].to_s]) + c[0][1]
   c[1][1] = ["+"+b[0].to_s] + c[1][1]
   c[2][1] = ["-"+a[0].to_s] + c[2][1]



   r = 0

   a01 = c[0][0] <= c[1][0]
   a02 = c[0][0] <= c[2][0]
   a12 = c[1][0] <= c[2][0]

   return c[0] if a01 && a02
   return c[1] if !a01 && a12
   return c[2] if !a02 && !a12
end


print diff([1,2,3,4,5], [2,3,5,6])
