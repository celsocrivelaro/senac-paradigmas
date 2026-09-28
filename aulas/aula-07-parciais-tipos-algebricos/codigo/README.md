# Aula 07 — código de exemplo

Cinco arquivos. Os blocos 1, 2 e 4 têm um arquivo cada; o Bloco 3, que trata
de construção de tipos e de estruturas de dados, tem dois. Derivam de
`funcional-haskell/`, na raiz deste repositório (arquivos `03`, `04` e `05`),
com os defeitos daquela versão corrigidos e os exemplos comentados estendidos.

| Arquivo | Bloco | Assunto |
|---------|-------|---------|
| `01-funcoes.hs` | 1 | Definição por equações, casamento de padrão, variáveis de tipo, alta ordem, recursão |
| `02-parciais-e-currying.hs` | 2 | Função unária, aplicação parcial, *point-free*, `curry`/`uncurry`, função não-total |
| `03-tipos-algebricos.hs` | 3 | O que é `deriving`, soma, produto, soma de produtos, registro |
| `04-tipos-recursivos.hs` | 3 | Árvore binária de busca **monomórfica**, casamento exaustivo, a invariante fora do tipo, persistência, ordem de inserção |
| `05-tipos-polimorficos.hs` | 4 | Construtor de tipo, generalização, parametricidade, `=>`, classes de tipo, `deriving`, `Maybe` |

## Execução

Não há `ghc` no host; a disciplina executa interpretador por contêiner:

```sh
docker run --rm -v "$PWD":/w -w /w haskell:9.6-slim \
  runghc -Wincomplete-patterns 01-funcoes.hs
```

Nenhum exemplo usa biblioteca fora da `base`; nenhum exige Cabal ou Stack.

## Verificação

Os três foram executados em `haskell:9.6-slim` (GHC 9.6) e terminam com
código 0.

**Avisos esperados.** `01` e `02` emitem `-Wincomplete-patterns` para `cabeca` e
`cauda`, que não tratam a lista vazia. O aviso é parte da exposição: é o
compilador exibindo a lacuna que a assinatura `[a] -> a` não registra.
`03-tipos-algebricos.hs`, `04-tipos-recursivos.hs` e `05-tipos-polimorficos.hs` passam **sem nenhum
aviso** — é a demonstração da exaustividade que o plano promete no Bloco 3.

O `05` traz, comentada, a versão de `inserir` sem restrição de contexto
(`a -> Arv a -> Arv a`). Descomentá-la em sala é o que produz a mensagem de erro
do Bloco 4: o GHC nomeia a variável de tipo e a classe ausente. A exigência não
é ilustrativa — inserir numa árvore de busca precisa comparar.

**Saídas que merecem atenção antes da aula:**

- `fatorialQuebrado 10` devolve `550`, contra `3628800` de `fatorial 10`. O
  valor é `10 × fib 9`. O erro é deliberado e está documentado no arquivo: o
  corpo chama a função errada, a assinatura `Integer -> Integer` continua
  correta e nada é acusado em compilação.
- `logBase10 1000` imprime `2.9999999999999996`. É aritmética de ponto
  flutuante binária, sem relação com o assunto do bloco; convém antecipar a
  pergunta.
- `length baralho` devolve `52`, que é a contagem pedida pelo Bloco 3 para
  justificar o nome "produto". A lista de naipes e a de valores são escritas à
  mão no `03` de propósito; o `05` as substitui por `[minBound .. maxBound]`,
  e a substituição é a demonstração do que `deriving` compra.
- No `04`, as duas árvores são escritas **por extenso**, com os construtores à
  mão: `equilibrada` tem profundidade `3` e `degenerada` tem `7`, com `emOrdem`
  idêntico nos dois. Escrever a forma em vez de derivá-la de uma lista é o que
  torna a diferença visível. São duas linhas que mostram por que existe
  balanceamento, sem que nenhum algoritmo de balanceamento apareça.
- No `05`, `emOrdem (deLista [Paus, Espadas, Ouros, Copas])` devolve
  `[Espadas,Copas,Ouros,Paus]`. Com `Ord` derivado, um tipo declarado na aula
  passa a ser utilizável por um algoritmo escrito antes dele.
