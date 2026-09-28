# Exercícios em sala — Paradigmas de Programação — Aula 07: Funções parciais, tipos algébricos e tipos polimórficos

Dois exercícios **independentes**, cada um com seu arquivo. Quem travar no
primeiro pode começar o segundo sem prejuízo.

O primeiro trata de função e de aplicação parcial; o segundo, do que acontece
com funções já escritas quando o **tipo** sobre o qual elas trabalham muda. Em
nenhum dos dois o algoritmo é a dificuldade — os dois são curtos de propósito, e
o que se cobra são os registros pedidos por escrito.

---

# Exercício 1 — Funções, aplicação parcial e funções não-totais

Arquivo: [`exercicio-1-cartas.hs`](exercicio-1-cartas.hs). Os tipos `Naipe`,
`Valor` e `Carta` e a lista `maoBaralho` já estão declarados; são os mesmos da
exposição.

## Parte 1 — Uma função sobre o tipo

Implemente `mesmoNaipe :: Naipe -> Carta -> Bool`, que responde se a carta é do
naipe dado.

Uma equação só, casando o padrão do construtor `Carta`.

## Parte 2 — Fixar o primeiro argumento

Defina `soEspadas :: Carta -> Bool` **sem escrever o argumento da carta**:
nenhum dos dois lados do `=` pode mencionar uma carta, nem um nome de variável
que represente uma.

Registre em comentário, no topo: quantos argumentos `mesmoNaipe` recebe de fato,
e o que é o valor `mesmoNaipe Espadas` — qual o tipo dele, e por que ele existe
sozinho.

## Parte 3 — A ordem dos argumentos decide o que se pode fixar

O arquivo traz `mesmoNaipeInv :: Carta -> Naipe -> Bool`, já escrita, que faz a
mesma pergunta com os argumentos trocados.

Tente definir `soCopas :: Carta -> Bool` a partir dela, do mesmo jeito da Parte
2 — sem escrever argumento nenhum, e sem usar função da biblioteca padrão que
troque a ordem.

Não vai dar. Registre por quê.

## Parte 4 — Uma função não-total

Implemente `primeiraDoNaipe :: Naipe -> [Carta] -> Carta`, que devolve a
primeira carta do naipe pedido.

A assinatura promete uma carta para **toda** entrada. Encontre uma entrada para
a qual a função não entrega, execute, e registre a entrada e a mensagem exata.

Não corrija a função. O tipo que resolveria isso é assunto do Bloco 4.

## Entregável e verificação

O arquivo ao final da Parte 4, executando, com os três registros em comentário
no topo.

1. `soEspadas` está definida por aplicação parcial, sem argumento escrito.
2. Os três registros estão presentes, e o da Parte 4 traz a mensagem que o
   programa de fato produziu.

---

# Exercício 2 — O que acontece com as funções quando o tipo muda

Arquivo: [`exercicio-2-arvore.hs`](exercicio-2-arvore.hs). A árvore binária de
busca e as funções `tamanho`, `emOrdem` e `inserir` já estão escritas: são as
mesmas da exposição.

A atividade **não é** reescrevê-las. É observar o que acontece com elas nas
Partes 2 e 3, e registrar.

## Parte 1 — Uma função a mais sobre o mesmo tipo

Implemente `descrever :: Arv -> String`, que devolve a árvore entre parênteses,
com `.` no lugar da subárvore vazia. O arquivo traz um exemplo do formato
esperado.

Uma equação por construtor.

## Parte 2 — Acrescentar um construtor

Uma folha é um nó cujas duas subárvores são vazias. Guardá-la como
`No Vazia v Vazia` gasta dois construtores à toa, e é comum o tipo trazer uma
alternativa própria para ela.

Acrescente `Folha Int` a `Arv`, e reescreva `equilibrada` usando `Folha` nas
quatro posições em que hoje aparece `No Vazia v Vazia`.

**Não altere nenhuma função.** Execute.

O programa compila. Ele **não** termina. Registre no topo quais funções
falharam, em que ordem, e com que mensagem. Só então corrija cada uma.

Responda também, em uma frase: por que o compilador deixou passar uma função que
não trata todos os construtores do tipo?

## Parte 3 — Generalizar o tipo

Troque o `Int` de `Folha` e de `No` por uma variável de tipo, de modo que `Arv`
passe a ser `Arv a`.

Ajuste **apenas** o que o compilador recusar. Uma restrição de contexto que ele
não pediu é erro de resposta, ainda que o programa compile.

Registre no topo, em duas listas:

- as funções que atravessaram a generalização **sem exigir contexto nenhum**;
- as funções que passaram a exigir contexto, e **qual classe** cada uma exige.

Espere mais de uma resposta na segunda lista: as funções não se dividem em "com"
e "sem" contexto, e sim em três grupos, com classes distintas.

Uma dica sobre a primeira mensagem que vai aparecer: ela não é sobre nenhuma das
funções, e sim sobre `equilibrada`. Leia-a com atenção — ela diz, com todas as
letras, o que `Arv` passou a ser.

## Entregável e verificação

O arquivo ao final da Parte 3, executando, com os registros das Partes 2 e 3 em
comentário no topo.

1. O tipo da árvore está na forma paramétrica, e `equilibrada` continua
   funcionando.
2. Nenhuma função carrega restrição de contexto que o compilador não tenha
   exigido.
3. Os registros das Partes 2 e 3 estão presentes e correspondem ao que o
   compilador e o programa de fato apontaram.
