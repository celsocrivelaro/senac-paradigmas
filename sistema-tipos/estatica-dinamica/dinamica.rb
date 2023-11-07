class Aluno; end # definição de classe

i = 5 # interpretador infere neste momento que é Integer
puts(i.class)
i = "zé" # interpretador infere neste momento agora é string
puts(i.class)
i = Aluno.new # interpretador infere neste momento agora é Aluno
puts(i.class)
i = ->(x) { x + 1 }
puts(i.class) # interpretador infere neste momento agora é Proc (função anônima)