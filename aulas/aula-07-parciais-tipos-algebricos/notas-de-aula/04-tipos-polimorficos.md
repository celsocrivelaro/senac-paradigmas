# Paradigmas de Programação — Aula 07: Funções parciais, tipos algébricos e tipos polimórficos — Tipos polimórficos

## Introdução

Um **tipo polimórfico** é um tipo que carrega um ou mais parâmetros, e que
portanto descreve uma família de tipos em vez de um tipo só. A nota anterior
construiu `Arv`, uma árvore de busca de inteiros; esta trata da generalização dessa
declaração para uma árvore de elementos de tipo qualquer, e das consequências
dessa mudança.

São duas as consequências, e elas puxam em direções opostas. A generalização
**restringe** o que as funções sobre o tipo podem fazer, porque o tipo do
elemento deixa de ser conhecido. E, para as funções que precisam fazer algo com o
elemento, a linguagem oferece uma forma de recuperar exatamente as operações
necessárias — a **restrição de contexto**, escrita com `=>`, cuja leitura ocupa
uma seção própria desta nota.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Distinguir construtor de tipo de tipo, justificando por que `Arv` isolado
   não é um tipo e `Arv Int` é.
2. Generalizar um tipo monomórfico para a forma paramétrica e identificar quais
   das funções sobre ele passam a exigir restrição de contexto e quais
   atravessam a generalização sem alteração de assinatura.
3. Distinguir polimorfismo paramétrico de polimorfismo *ad-hoc*, e explicar o
   que `deriving` gera e por que a linguagem consegue gerá-lo para um tipo
   algébrico.

## Desenvolvimento teórico

### Construtor de tipo com parâmetro

A declaração paramétrica acrescenta uma variável à esquerda do `=`:

```haskell
data Arv a = Vazia | No (Arv a) a (Arv a)
  deriving (Show, Eq)
```

`Arv`, sozinho, **não é um tipo**. É uma função no nível dos tipos: recebe um
tipo e devolve um tipo. `Arv Int` é um tipo; `Arv String` é outro; `Arv` isolado
não pode anotar valor algum, e escrever `x :: Arv` é erro de compilação.

A classificação que distingue os dois casos chama-se ***kind***, e é o "tipo dos
tipos". Um tipo propriamente dito tem *kind* `*`; um construtor que espera um
tipo tem *kind* `* -> *`. No GHCi:

```
ghci> :kind Arv
Arv :: * -> *

ghci> :kind Arv Int
Arv Int :: *
```

A notação é deliberadamente a mesma das assinaturas de função, e a razão é que o
fenômeno é o mesmo. **Aplicar um construtor de tipo a menos argumentos do que
ele aceita é a aplicação parcial da nota anterior, um nível acima.** A linguagem
oferece a mesma construção nos dois níveis.

### A generalização, e o que ela separa

A passagem de `Arv` para `Arv a` é a substituição de `Int` por uma variável.
Nenhum dos corpos das funções existentes muda uma linha. O que muda são as
assinaturas — e elas não mudam todas da mesma forma:

| Função | Assinatura generalizada | Exige algo do elemento |
|---|---|---|
| `tamanho` | `Arv a -> Int` | não |
| `profundidade` | `Arv a -> Int` | não |
| `emOrdem` | `Arv a -> [a]` | não |
| `inserir` | `Ord a => a -> Arv a -> Arv a` | **sim** |
| `buscar` | `Ord a => a -> Arv a -> Bool` | **sim** |

A separação entre os dois grupos é o conteúdo central desta nota, e ela é
natural: contar níveis não exige nada do elemento; decidir para que lado descer
exige compará-lo. As três primeiras atravessam a generalização intactas; as duas
últimas ganham algo à esquerda de `=>`, cuja leitura ocupa uma seção adiante.

O ganho imediato é a eliminação de uma família de duplicações: uma estrutura, e
não uma por tipo de elemento.

### Polimorfismo paramétrico e parametricidade

O `a` de `profundidade` é desconhecido dentro do corpo: nenhuma operação se
aplica ao elemento, como já ocorria com `cabeca :: [a] -> a` na primeira nota.
Essa ignorância é precisamente o que torna a função aplicável a qualquer árvore.
A forma de polimorfismo em que **o mesmo código serve a todos os tipos** chama-se
**polimorfismo paramétrico**.

O caso mais eloquente da tabela anterior é `emOrdem :: Arv a -> [a]`. Ela **toca
em todos os elementos da árvore** e ainda assim dispensa contexto, porque apenas
os move de lugar: nenhuma comparação, nenhuma operação, nenhuma inspeção. Tocar
no elemento não exige saber o que ele é; **usar** o elemento é que exige.

A propriedade que daí decorre chama-se **parametricidade**, e pode ser enunciada
informalmente assim: **quanto mais geral o tipo de uma função, menos
implementações ele admite — e portanto mais ele informa sobre o que a função
faz.** O enunciado contraria a intuição corrente, segundo a qual generalidade e
informação são grandezas opostas.

A tabela mede o efeito sobre assinaturas conhecidas:

| Assinatura | Implementações totais |
|---|---|
| `a -> a` | exatamente **uma**: a identidade |
| `a -> b` | **nenhuma**: não há como fabricar um `b` |
| `[a] -> a` | **nenhuma**: a lista vazia não oferece elemento |
| `[a] -> Int` | infinitas: `length`, `const 0`, `const 1`, … |
| `[Int] -> Int` | infinitas, e muito mais variadas: `sum`, `maximum`, … |

A primeira linha é o caso mais forte. Uma função de tipo `a -> a` recebe um valor
de tipo desconhecido e precisa devolver um valor do mesmo tipo desconhecido. Não
há operação aplicável, não há constante construível, e o único valor daquele tipo
ao alcance é o que foi recebido. A assinatura determina a implementação.

### O limite da parametricidade

A mesma ignorância que generaliza também impede. `inserir` precisa decidir para
que lado o elemento desce, e essa decisão é uma **comparação**:

```haskell
-- Esta assinatura é impossível de implementar:
inserir :: a -> Arv a -> Arv a
inserir x Vazia = No Vazia x Vazia
inserir x t@(No esq v dir)
  | x < v     = No (inserir x esq) v dir
  | x > v     = No esq v (inserir x dir)
  | otherwise = t
```

O operador `<` não está disponível para um `a` qualquer. O compilador recusa o
programa, nomeando a variável de tipo e a classe ausente. A exigência não é
ilustrativa: ela vem do algoritmo, e sem ela não existe árvore de busca.

A saída não é abandonar o polimorfismo nem voltar ao tipo fixo. É declarar, na
própria assinatura, **quais operações o tipo do elemento precisa oferecer**.

### A leitura de `=>`

A notação que faz essa declaração é a seta dupla, e ela é lida de forma diferente
da seta simples. A assinatura completa é:

```haskell
inserir :: Ord a => a -> Arv a -> Arv a
```

A leitura, por partes:

- **À direita de `=>`** está o **tipo propriamente dito**: `a -> Arv a -> Arv a`.
  É isto que a função é. Toda a contagem de argumentos e de resultado se faz
  aqui.
- **À esquerda de `=>`** está o **contexto**: uma lista de exigências sobre as
  variáveis de tipo. `Ord a` não é um argumento, não é um valor, e não é passado
  em chamada alguma. É uma condição.
- **O `=>` separa os dois mundos.** Ele aparece no máximo uma vez, e sempre antes
  da primeira seta simples do tipo propriamente dito.

A assinatura inteira se lê: *"para todo tipo `a` que ofereça as operações da
classe `Ord`, esta é uma função que recebe um `a` e uma `Arv a`, e devolve uma
`Arv a`"*.

A confusão mais frequente é de contagem. A assinatura
`Ord a => a -> Arv a -> Arv a` descreve uma função de **dois** argumentos, não
de três. O contexto à esquerda do `=>` não entra na contagem, porque não é
argumento. A regra prática: para contar argumentos, contam-se apenas as setas
simples **à direita** do `=>`.

Um contexto pode exigir mais de uma classe, e a lista vai entre parênteses:

```haskell
descreverArvore :: (Ord a, Show a) => Arv a -> String
```

A restrição devolve à função exatamente as operações de que ela precisa, e nada
além. `Ord a` autoriza comparar; não autoriza somar nem imprimir, para o que
seriam necessários `Num a` e `Show a`.

### Classes de tipo

Uma **classe de tipo** é o conjunto dos tipos que oferecem um dado conjunto de
operações. `Num` reúne os tipos que oferecem `+`, `*` e afins; `Eq`, os que
oferecem `==`; `Ord`, os que oferecem `<`; `Show`, os que se convertem em texto.

Uma função cuja assinatura tem contexto exibe a segunda forma de polimorfismo:

```haskell
descrever :: Show a => a -> String
descrever x = "valor: " ++ show x
```

O `show` aplicado a um `Int` e o `show` aplicado a uma `Arv Int` são
**implementações diferentes**, e a escolha entre elas é feita em compilação, a
partir do tipo. A forma de polimorfismo em que a implementação **depende do
tipo** chama-se **polimorfismo *ad-hoc***.

| | Paramétrico | *Ad-hoc* |
|---|---|---|
| **Código executado** | o mesmo para todos os tipos | um por tipo, escolhido pelo tipo |
| **Aparece na assinatura como** | variável de tipo livre | variável de tipo com contexto (`=>`) |
| **Exemplo** | `emOrdem :: Arv a -> [a]` | `inserir :: Ord a => a -> Arv a -> Arv a` |
| **O que o corpo pode fazer com o elemento** | nada | as operações da classe exigida |
| **O que a assinatura informa** | muito, por exclusão | menos, mas o suficiente |

Os genéricos de Java com `extends` são um parente mais fraco da mesma ideia: eles
também condicionam o parâmetro a uma interface, mas a resolução se dá por
despacho dinâmico sobre objetos, e não por seleção estática de implementação.

### `deriving`

Escrever à mão as instâncias de `Show`, `Eq` e `Ord` para cada tipo declarado
seria trabalho mecânico e volumoso. A cláusula `deriving` as gera:

```haskell
data Naipe = Espadas | Copas | Ouros | Paus
  deriving (Show, Eq, Ord, Enum, Bounded)
```

A razão de a linguagem conseguir gerá-las está na nota anterior: **a estrutura do
tipo algébrico determina a implementação**. Comparar dois valores de uma soma de
produtos é comparar primeiro o construtor e, se coincidirem, os campos um a um —
procedimento que se lê diretamente da declaração. O mesmo vale para a ordem
(pela posição declarada dos construtores), para a conversão em texto (pelo nome
do construtor seguido dos campos) e para a enumeração.

Só é derivável porque é algébrico. Um tipo cuja estrutura interna a linguagem não
conhece não admite geração automática.

O efeito prático é imediato e duplo. Com `Enum` e `Bounded` derivados, a lista
de naipes escrita à mão na nota anterior torna-se supérflua:

```haskell
naipes :: [Naipe]
naipes = [minBound .. maxBound]
```

E com `Ord` derivado, `Naipe` passa a satisfazer o contexto de `inserir` — ou
seja, **um naipe pode entrar numa árvore de busca**, sem que uma única linha da
árvore tenha sido escrita pensando em naipes:

```haskell
emOrdem (deLista [Paus, Espadas, Ouros, Copas])
-- [Espadas,Copas,Ouros,Paus]
```

A ordem do resultado é a ordem de **declaração** dos construtores, que é o
critério que `deriving (Ord)` adota. Três linhas de declaração tornaram um tipo
próprio utilizável por um algoritmo escrito antes dele.

### `Maybe`, onde as duas notas se encontram

O tipo `Maybe` da biblioteca padrão é ao mesmo tempo algébrico e polimórfico, e
sua declaração não tem nada de especial:

```haskell
data Maybe a = Nothing | Just a
```

É uma **soma** de duas alternativas, parametrizada por `a`. Na notação de
cardinalidade, `|Maybe a| = 1 + |a|`.

O que ele resolve é o problema aberto na segunda nota. A função parcial
`cabeca :: [a] -> a` diverge para a lista vazia porque não há `a` a devolver. Com
`Maybe`, a ausência de resposta passa a ser um valor representável, e a função se
torna **total**:

```haskell
primeiro :: [a] -> Maybe a
primeiro []    = Nothing
primeiro (x:_) = Just x
```

Nenhuma entrada faz `primeiro` divergir, e o tipo de retorno agora **registra** a
possibilidade de não haver resposta — ao contrário de `[a] -> a`, que a omitia.

O preço aparece na composição. Encadear duas funções que devolvem `Maybe` obriga
a desempacotar e reempacotar a cada passo:

```haskell
dividir :: Int -> Int -> Maybe Int
dividir _ 0 = Nothing
dividir x y = Just (x `div` y)

dividirDuasVezes :: Int -> Int -> Int -> Maybe Int
dividirDuasVezes x y z =
  case dividir x y of
    Nothing -> Nothing
    Just r  -> case dividir r z of
                 Nothing -> Nothing
                 Just s  -> Just s
```

Os dois `case` têm estrutura idêntica. A repetição é real e cresce com o número
de passos encadeados; dar-lhe nome é o assunto da aula seguinte.

## Exemplos

O arquivo `codigo/05-tipos-polimorficos.hs` reúne os exemplos desta nota:

```sh
docker run --rm -v "$PWD":/w -w /w haskell:9.6-slim \
  runghc -Wincomplete-patterns 05-tipos-polimorficos.hs
```

O arquivo termina sem aviso algum. A versão impossível de `inserir` — assinatura
`a -> Arv a -> Arv a`, sem contexto — está presente, comentada; descomentá-la
produz a mensagem de erro discutida na seção sobre o limite da parametricidade.

Três saídas sustentam o argumento da nota. A mesma `deLista` constrói uma árvore
de `Int` e uma de `String`, e `emOrdem` devolve as duas ordenadas:

```
[1,2,3,4,5,6,7]
["figo","maca","pera","uva"]
```

As funções sem contexto operam sobre as duas sem qualquer alteração —
`(tamanho, profundidade)` devolve `(7,3)` para a primeira e `(4,3)` para a
segunda. E `buscar`, que tem contexto, funciona igualmente nas duas, com o
operador `<` de `Int` num caso e o de `String` no outro: duas implementações
distintas, escolhidas pelo tipo em tempo de compilação.

## Fontes e leituras

- LIPOVAČA, Miran. **Learn You a Haskell for Great Good!: a beginner's guide.**
  San Francisco: No Starch Press, 2011. Capítulo 3 (*Types and Typeclasses*),
  leitura prévia recomendada para esta nota; capítulo 8 (*Making Our Own Types
  and Typeclasses*), para tipos paramétricos e `deriving`. Versão online em
  https://learnyouahaskell.github.io/ (*fork* comunitário, licença Creative
  Commons BY-NC-SA 3.0; a autoria indicada acima provém da edição impressa e não
  consta do site).

- TATE, Bruce A. **Seven Languages in Seven Weeks: a pragmatic guide to learning
  programming languages.** Raleigh: Pragmatic Bookshelf, 2010. Capítulo 8
  (Haskell), dia 2. O tratamento de classes de tipo é curto e serve de segunda
  passagem sobre esta nota, não de primeira.
