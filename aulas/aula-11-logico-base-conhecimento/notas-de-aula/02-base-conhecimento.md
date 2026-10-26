# Prolog: Base de Conhecimento, Unificação e Regras

Tema: Lógico

# Construindo a base de conhecimento

Usando a teoria visto anteriormente, podemos definir os fatos como predicados como fatos:

```prolog
gosta_de(jose, maria).
gosta_de(maria, jose).
gosta_de(maria, vinicius).
```

Esta base de conhecimento precisa ser salva em um arquivo ".pl".

Aqui estamos construindo nossa base de conhecimento com predicados e termos . Na primeira linha o predicado P(x,y) é

P = gosta_de

X = jose

Y = maria

Atenção, a ordem importa e não é associativa, entãp gosta_de(jose, maria) ≠ gosta_de(maria, jose).

Os fatos são afirmações, portanto, imutáveis.

Importante: 

1. No final, deve-se colocar "." assim como muitas linguagens tem o ";". 
2. Fatos e predicados devem ser textos em letra minúscula.

Salvar como "base-conhecimento.pl"

## Variáveis

A base de conhecimento deve ser armazenada em um arquivo com extensão ".pl". Para aplicarmos o processamento, vamos chamar o interpretador:

```bash
$ gprolog                                                                                                                                                                     ‹ruby-2.6.5›
GNU Prolog 1.4.5 (64 bits)
Compiled Aug 20 2018, 15:27:00 with clang
By Daniel Diaz
Copyright (C) 1999-2018 Daniel Diaz
| ?-
```

Este é o interpretador do Gnu Prolog. No prompt "?-" é onde aplicamos as consultas e as regras.

Carregar a base de conhecimento:

```prolog
?- ['nome-arquivo']. % atenção: aspas simples
```

O Prolog permite fazer consulta totais ou parciais na base de conhecimento usando variáveis. Por definição, as variáveis são strings que começam por letra maiúscula. Se no terminal do Prolog colocamos os fatos acima, vamos fazer uma consulta:

```prolog
?- gosta_de(maria, X).
```

O terminal do prolog vai retornar:

```prolog
?- gosta_de(maria,X)
X = jose
```

Para retornar mais valores, deve-se digitar ";":

```prolog
| ?- gosta_de(maria,X).
X = jose ? ;
X = vinicius
yes
```

Assim, se retornou todos os valores da base de conhecimento de quem "maria" gosta. 

Unificação.

## Regras

Como programação, queremos construir funções para cálculos dos valores. Assim, o Prolog permite criar regras usando as variáveis:

```prolog
amizade(X,Y) :- gosta_de(X, Y), gosta_de(Y, X).
```

Regra: amizade é a função que tem as variáveis X e Y . Esta regra é formada operador ":-" pelos predicados gosta_de(X, Y) e gosta_de(Y, X). A vírgula indica a conjunção ou regra "e". Como ler isto: amizade de X e Y é definida pelos fatos de X gostar de Y e Y gosta de X.

Importante: esta é uma regra declarativa. 

## Busca

Busca pode ser feita testando os fatos:

```prolog
?- amizade(maria,jose).
yes.

?- amizade(maria,vinicius).
no.
```

A afirmação é falsa para maria e vinicius porque não há o fato ''gosta_de(vinicius, maria)".

Também podemos fazer as unificações. Gostaria de saber quem é amigo de maria:

```prolog
?- amizade(maria,X).
X = jose ;
no.
```

O último item é false indicando que já fez toda a busca na base.

Aqui está o poder do paradigma lógico e do Prolog. Podemos definir fatos (a base de conhecimento BC), fazer regras e fazer perguntas que irá fazer uma busca sobre a base. Podemos construir regras complexas baseada no conhecimento adquirido por especialistas sem a necessidade de construir algoritmos imperativos com "ifs" e "loops".

## Negação

Em Prolog, a negação é \+ predicado

```clojure
feminino(X) :- \+ masculino(X).
```

## Predicados prontos - Standard Library

Cada dialeto do Prolog vai ter uma lista diferente de implementações de predicados conforme o seu uso. No caso do Gnu Prolog, conseguimos ver a lista em:

[http://www.gprolog.org/manual/gprolog.html](http://www.gprolog.org/manual/gprolog.html)

### Como o Prolog funciona

Podemos ver o processo de busca do Prolog com o trace

```clojure
| ?- trace
.
The debugger will first creep -- showing everything (trace)

{trace}
| ?- amizade(maria,X).
      1    1  Call: amizade(maria,_279) ?
      2    2  Call: gosta_de(maria,_279) ?
      2    2  Exit: gosta_de(maria,jose) ?
      3    2  Call: gosta_de(jose,maria) ?
      3    2  Exit: gosta_de(jose,maria) ?
      1    1  Exit: amizade(maria,jose) ?

X = jose ? ;
      1    1  Redo: amizade(maria,jose) ?
      2    2  Redo: gosta_de(maria,jose) ?
      2    2  Exit: gosta_de(maria,vinicius) ?
      3    2  Call: gosta_de(vinicius,maria) ?
      3    2  Fail: gosta_de(vinicius,maria) ?
      1    1  Fail: amizade(maria,_279) ?

no
{trace}
```

Mais detalhes: [http://www.gprolog.org/manual/html_node/gprolog013.html](http://www.gprolog.org/manual/html_node/gprolog013.html)

Bibliografia

[http://www.gprolog.org/manual/gprolog.html](http://www.gprolog.org/manual/gprolog.html)

[http://lpn.swi-prolog.org/lpnpage.php?pageid=online](http://lpn.swi-prolog.org/lpnpage.php?pageid=online)

[https://www.swi-prolog.org/pldoc/man?section=builtin](https://www.swi-prolog.org/pldoc/man?section=builtin)