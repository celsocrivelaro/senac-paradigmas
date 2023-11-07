print("---- Tabelas como Listas ----")
-- Tabelas em Lua podem ser listas
dias = {"Domingo", "Segunda", "Terça", "Quarta",
            "Quinta", "Sexta", "Sábado"}

print(dias[1]) -- em Lua, listas começam pelo índice 1
print(dias[4])

print("\nIterando sobre listas")
for count=1, #dias do 
  print(dias[count])
end

print("\n---- Tabelas como Dicionários ----")
-- Tabelas em Lua podem ser dicionários
a = {x=2, y=5}
print(a.x)
print(a["y"])

print("\nIterando sobre dicionários")
for k, v in pairs(a) do 
  print(k .. ":" .. v)
end

-- posso associar funções aos valores do dicionário
print("\nTabelas com funções")
multiplicador = {
  duplicador = function(num) return num*2 end, 
  triplicador = function(num) return num*3 end
}

for k, v in pairs(multiplicador) do
  print(k .. ":" .. v(2))
end