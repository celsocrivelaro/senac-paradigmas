-- Tutorial de Metatables: https://www.youtube.com/watch?v=44Aemp2A-2E

x = {value = 5}
z = {value = 10}

-- https://www.tutorialspoint.com/lua/lua_metatables.htm
-- https://webserver2.tecgraf.puc-rio.br/lua/local/manual/5.4/manual.html#2.4
mt = {
  __add = function (a, b) -- "add" event handler
    return { value = a.value + b.value }
  end,
  __len = function(obj) 
    return 8
  end,
  __index = function(tabela, chave)
    if chave == "oi" then
       return "funciona de jeito diferente"
    else
       return tabela[chave]
    end
  end
}

setmetatable(x, mt) -- mt é a metatabela de x
setmetatable(z, mt) -- mt é a metatabela de x
y = x + z

print(y.value)
print(#z)
print(x["oi"])
