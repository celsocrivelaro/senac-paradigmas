function hipotenusa(a,b)
  a2 = a*a
  b2 = b*b
  return math.sqrt(a2 + b2)
end

print(hipotenusa(5,5))
print(a2) -- lua vaza o escopo das variáveis, deixando global

-- deixando as variáveis em escopo local
function bhaskara(a,b,c)
  local raiz = math.sqrt(b*b - 4*a*c)
  local bha1 = (-b + raiz) / (2*a)
  local bha2 = (-b - raiz) / (2*a)
  return bha1, bha2
end

print("\nLimitando o escopo:")
r1, r2 = bhaskara(1,12,-13)
print(r1)
print(r2)
print(bha1)