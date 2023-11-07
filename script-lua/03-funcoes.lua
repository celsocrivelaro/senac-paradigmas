-- como linguagem dinâmica, Lua não precisa definir tipos
-- nem para o retorno da função e nem para os argumentos de entrada
function triplicar(num)
  return 3 * num
end

print(triplicar(2))

-- fatos interessantes da sintaxe
-- Muitas linguagens de script não usam ";" como marcação de fim de expressão
-- Em Lua, é permitido até deixar a expressão in-line
function duplica(num) return 2*num end
print(duplica(2))

-- Em Lua é uma linguagem multiparadigma e implementa recursos de funcional
-- uma função é um valor qualquer, então posso associar a uma variável
-- este tipo de função é chamada de função anônima
mais_um = function(num) return num+1 end
print(mais_um(4))

-- posso até passar funções como argumentos
function chama_duas_vezes(f, valor)
  local resultado = f(valor)
  return f(resultado)
end
print(chama_duas_vezes(mais_um, 10)) -- 12
print(chama_duas_vezes(duplica, 10)) -- 20

function retorna_funcao()
  return function(a)
    return a / 4
  end
end

x = retorna_funcao()
print(x(444))

-- Flexibilidade nos argumentos
function imprime_amigos(amigo1, amigo2)
  print(amigo1)
  print(amigo2)
end
print "\nAmigos 1:"
imprime_amigos("Maria", "Zé")
print "Amigos 2:"
imprime_amigos("João")

-- retorno de múltiplos argumentos
function multiplo_retorno()
  return "1", "2"
end
a1, a2 = multiplo_retorno()
print "\nMúltiplos retornos"
print(a1)
print(a2)

-- Keyword arguments
function preco_refri(tabela)
  print("Refri médio custa: " .. tabela.medio)
end
print "\nKeyword arguments"
preco_refri({pequeno=2.0, medio=4.00, grande=6.00})