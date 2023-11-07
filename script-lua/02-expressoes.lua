-- expressões matemáticas seguem as regras de precedência padrão
-- * e / têm precedência sobre + e -
print(6 + 5 * 4 - 3 / 2) -- Lua converte as operações de divisão para ponto flutuante

-- operaddores padrão de expressões lógicas
-- 
print(not(true or false) and false)

-- fato comum em linguagens dinâmicas:
-- expressões lógicas com curto cirtuito
-- verdadeiro ou executa algo
print(true or 10) -- retorna true
print(false or 13) -- retorna 13

-- expressões comparativas
print(10 > 93) -- false