# Paradigmas de Programação — Aula 11: Base de conhecimento — Unificação e recursão

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- definir unificação e calcular o unificador mais geral de dois termos;
- descrever como o Prolog usa a unificação para casar uma consulta com a cabeça de uma cláusula e como o retrocesso (*backtracking*) produz as respostas seguintes;
- distinguir unificação (`=`), comparação aritmética (`>`) e negação por falha (`\+`);
- escrever predicados recursivos com cláusula de parada e cláusula recursiva;
- identificar a recursão à esquerda como causa de não terminação.

## Desenvolvimento teórico

### Termos

Em Prolog, todo dado é um **termo**. Há quatro formas:

| Forma | Exemplo | Regra léxica |
|---|---|---|
| **Átomo** | `maria`, `sao_paulo` | começa por letra minúscula |
| **Número** | `22`, `3.14` | literal numérico |
| **Variável** | `X`, `CIDADE`, `_` | começa por letra maiúscula ou `_` |
| **Termo composto** | `candidato(maria, 22, sao_paulo)` | functor seguido de argumentos |

Um termo composto é identificado pelo par **nome/aridade**: `candidato/3` é o functor `candidato` com três argumentos. Dois termos com o mesmo nome e aridades diferentes são predicados distintos.

Uma variável em Prolog não é uma posição de memória que recebe valores sucessivos. É uma incógnita: começa **livre** e, uma vez **ligada** a um termo, permanece ligada até que o retrocesso desfaça a ligação. Não há atribuição destrutiva.

### Unificação

Uma **substituição** θ é um conjunto finito de pares `{X₁/t₁, …, Xₙ/tₙ}` que associa variáveis a termos. Aplicar θ a um termo t, escrito tθ, troca cada ocorrência de Xᵢ por tᵢ.

Dois termos t₁ e t₂ são **unificáveis** se existe uma substituição θ tal que t₁θ = t₂θ. Essa substituição é um **unificador**. Entre os unificadores possíveis, o **unificador mais geral** (*most general unifier*, MGU) é o que liga o mínimo necessário: qualquer outro unificador é obtido dele por uma substituição adicional (ROBINSON, 1965).

O algoritmo compara os dois termos estruturalmente:

1. Uma variável livre unifica com qualquer termo, e passa a estar ligada a ele.
2. Dois átomos ou dois números unificam se forem idênticos.
3. Dois termos compostos unificam se tiverem o mesmo nome, a mesma aridade e se os argumentos unificarem dois a dois, da esquerda para a direita, acumulando as ligações.
4. Em qualquer outro caso, a unificação falha.

O operador `=` aplica esse algoritmo explicitamente. Saídas obtidas no SWI-Prolog 9.2.9:

```prolog
?- p(X, b) = p(a, Y).
X = a, Y = b.

?- f(X, g(X)) = f(a, Y).
X = a, Y = g(a).

?- p(a) = p(b).
false.
```

No segundo caso, a ligação `X = a`, feita no primeiro argumento, já vale ao unificar o segundo: `Y` recebe `g(a)`, e não `g(X)`.

```text
   f(  X  ,  g(X) )          θ = { }
       |      |
   f(  a  ,   Y   )

   1. X  com a     ->  θ = { X/a }
   2. g(X)θ = g(a) com Y  ->  θ = { X/a, Y/g(a) }
```

**Verificação de ocorrência** (*occurs check*). Pela definição, `X = f(X)` não tem unificador: nenhum termo finito é igual a si mesmo envolvido em `f`. Por eficiência, o Prolog padrão não faz essa verificação e aceita a unificação, criando um termo cíclico. A versão rigorosa existe como predicado próprio:

```prolog
?- unify_with_occurs_check(X, f(X)).
false.
```

A unificação é bidirecional. Ao contrário do casamento de padrões das linguagens funcionais, em que o padrão fica de um lado e o valor do outro, os dois termos podem conter variáveis, e qualquer lado pode fornecer valores ao outro.

### Unificação na resolução

A consulta ao Prolog é respondida por **resolução SLD** (*Selective Linear Definite clause resolution*). Dado um objetivo, o interpretador:

1. procura, na ordem do arquivo, uma cláusula cuja cabeça unifique com o objetivo;
2. aplica o MGU ao corpo da cláusula, que passa a ser a nova lista de objetivos;
3. resolve os objetivos do corpo da esquerda para a direita;
4. quando um objetivo falha, **retrocede** até o último ponto em que havia outra cláusula possível, desfaz as ligações feitas desde então e tenta a alternativa.

Cada resposta adicional, pedida com `;` no interpretador, é obtida pelo mesmo retrocesso.

O arquivo `codigo/02-unificacao.pl` define candidatos com idade e cidade, e regras de elegibilidade:

```prolog
candidato(joao,29,recife).
candidato(kelly,40,recife).
candidato(paula,34,recife).
candidato(fernando,32,olinda).

cidade(recife,pernambuco).
cidade(olinda,pernambuco).

prefeito(X,CIDADE) :- candidato(X, Y, CIDADE), Y > 21.
governador(X,ESTADO) :- candidato(X, Y, CIDADE), Y > 30, cidade(CIDADE,ESTADO).
```

A consulta `prefeito(P, recife)` unifica com a cabeça `prefeito(X, CIDADE)` com θ = `{X/P, CIDADE/recife}`. O corpo vira `candidato(P, Y, recife), Y > 21`. O primeiro objetivo unifica com `candidato(joao, 29, recife)`, liga `P = joao` e `Y = 29`, e `29 > 21` é verdadeiro. Nas respostas seguintes, o retrocesso volta a `candidato/3` e tenta as próximas cláusulas:

```prolog
?- prefeito(P, recife).
P = joao ;
P = kelly ;
P = paula.
```

Em `governador/2`, a variável `CIDADE` não aparece na cabeça. Ela é ligada por `candidato/3` e transporta o valor até `cidade(CIDADE, ESTADO)`, que só aceita cidades de Pernambuco. É assim que uma regra faz a junção de duas relações: duas ocorrências da mesma variável exigem o mesmo valor.

```prolog
?- governador(G, pernambuco).
G = kelly ;
G = paula ;
G = fernando.
```

**Três operações diferentes** aparecem no mesmo arquivo e não se confundem:

| Operação | Sintaxe | Comportamento |
|---|---|---|
| Unificação | `X = Y` | Liga variáveis para tornar os termos iguais. Não avalia expressões: `X = 2 + 3` liga `X` ao termo `+(2, 3)`. |
| Comparação aritmética | `Y > 21` | Avalia os dois lados. Exige que estejam ligados a números; com variável livre, lança erro de instanciação. |
| Negação por falha | `\+ (X = Y)` | É verdadeira se o objetivo **não** puder ser provado. Não liga variáveis. |

A regra de chapa usa a negação para impedir que a mesma pessoa ocupe os dois cargos:

```prolog
chapa_estado(X,Y,ESTADO) :- governador(X,ESTADO), vice_governador(Y,ESTADO), \+ (X = Y).
```

A posição do `\+` importa. No fim do corpo, `X` e `Y` já estão ligados, e `\+ (X = Y)` testa se são diferentes. Se a negação viesse antes de `governador/2`, com as duas variáveis livres, `X = Y` sempre unificaria, e a regra sempre falharia. Em Olinda há um só candidato, e a chapa não existe:

```prolog
?- chapa_prefeitura(X, Y, olinda).
false.
```

A **variável anônima** `_`, usada em `presidente(X) :- candidato(X, Y, _), Y > 35.`, unifica com qualquer termo e não guarda a ligação. Cada `_` é uma variável distinta.

### Recursão

Um predicado é **recursivo** quando uma de suas cláusulas tem, no corpo, um objetivo com o próprio predicado. Como Prolog não tem laço, a recursão é a forma de percorrer uma estrutura de tamanho não fixado em tempo de escrita. Um predicado recursivo tem duas partes:

- a **cláusula de parada**, que resolve o caso sem chamada recursiva;
- a **cláusula recursiva**, que reduz o problema a um caso menor.

O arquivo `codigo/03-recursao.pl` modela uma árvore genealógica:

```text
  serafim
     |
  orozimbo + cleia          joao + maria
          |                       |
        otavio        +         joana
                      |
                     luis
```

Cada `+` une um casal, e a linha vertical abaixo dele leva ao filho: `otavio` é filho de `orozimbo` e `cleia`, `joana` é filha de `joao` e `maria`, e `luis` é filho de `otavio` e `joana`.

Sem recursão, cada grau de parentesco precisa de uma regra própria, e a cadeia de objetivos cresce com o grau:

```prolog
avo_masculino(X,Y) :- (mae(W,Y) ; pai(W,Y)), pai(X,W).
bisavo_masculino(X,Y) :- avo_masculino(W,Y), pai(X,W).
```

O ponto e vírgula `;` é a disjunção: `mae(W,Y) ; pai(W,Y)` é verdadeiro se `W` for mãe **ou** pai de `Y`. A vírgula é a conjunção.

A relação de ancestral, em qualquer grau, é o **fecho transitivo** da relação de progenitor e se escreve com duas cláusulas:

```prolog
ancestral(X, Y) :- mae(X, Y); pai(X, Y).                     % parada
ancestral(X, Y) :- (mae(X, Z); pai(X, Z)), ancestral(Z, Y).  % recursiva
```

Formalmente: X é ancestral de Y se X é progenitor de Y, ou se X é progenitor de algum Z e Z é ancestral de Y. Cada chamada recursiva desce um nível na árvore, e a recursão termina porque a árvore é finita e sem ciclos.

```prolog
?- ancestral(X, luis).
X = joana ;
X = otavio ;
X = maria ;
X = cleia ;
X = joao ;
X = orozimbo ;
X = serafim.
```

A ordem das respostas segue a ordem da busca em profundidade: primeiro a cláusula de parada (os progenitores diretos, `joana` e `otavio`), depois a recursiva, que, para cada progenitor `Z` de `luis`, busca os ancestrais de `Z`. O mesmo predicado responde à pergunta inversa, sem nenhuma regra adicional, porque a unificação não distingue entrada de saída:

```prolog
?- ancestral(serafim, Y).
Y = orozimbo ;
Y = otavio ;
Y = luis.
```

### Recursão à esquerda e terminação

A leitura lógica de uma regra não depende da ordem dos objetivos, mas a execução depende. A versão abaixo é logicamente equivalente à anterior:

```prolog
ancestral_esq(X, Y) :- ancestral_esq(X, Z), (mae(Z, Y) ; pai(Z, Y)).
ancestral_esq(X, Y) :- mae(X, Y) ; pai(X, Y).
```

A consulta `ancestral_esq(maria, luis)` não termina. O primeiro objetivo do corpo é o próprio predicado, chamado com `Z` livre, que unifica de novo com a primeira cláusula, e assim indefinidamente, sem nunca chegar à cláusula de parada. No SWI-Prolog 9.2.9, a pilha estoura depois de cerca de 6,4 milhões de chamadas:

```text
ERROR: Stack limit (1.0Gb) exceeded
ERROR:   Probable infinite recursion (cycle):
ERROR:     [6,390,818] user:ancestral_esq(maria, _12787926)
ERROR:     [6,390,817] user:ancestral_esq(maria, _12787946)
```

Decorre daí uma regra prática para predicados recursivos em Prolog:

1. a cláusula de parada vem antes da recursiva;
2. na cláusula recursiva, um objetivo que liga variáveis (aqui, `mae/2` ou `pai/2`) vem antes da chamada recursiva, para que cada chamada receba um problema estritamente menor.

A semântica declarativa (o que a regra afirma) e a semântica procedural (como a busca a executa) coincidem nas respostas encontradas, mas só a segunda determina se a busca termina (STERLING; SHAPIRO, 1994).

## Fontes e leituras

BLACKBURN, Patrick; BOS, Johan; STRIEGNITZ, Kristina. **Learn Prolog Now!** London: College Publications, 2006. Capítulos 2 (unificação e resolução) e 3 (recursão). Disponível em: https://www.let.rug.nl/bos/lpn/. Acesso em: 25 out. 2026.

BRATKO, Ivan. **Prolog programming for artificial intelligence**. 4. ed. Harlow: Addison-Wesley, 2012.

ROBINSON, John Alan. A machine-oriented logic based on the resolution principle. **Journal of the ACM**, v. 12, n. 1, p. 23-41, 1965.

STERLING, Leon; SHAPIRO, Ehud. **The art of Prolog**: advanced programming techniques. 2. ed. Cambridge: MIT Press, 1994.

SWI-PROLOG. **SWI-Prolog reference manual**. Seção 4.7: comparison and unification of terms. Disponível em: https://www.swi-prolog.org/pldoc/man?section=compare. Acesso em: 25 out. 2026.
