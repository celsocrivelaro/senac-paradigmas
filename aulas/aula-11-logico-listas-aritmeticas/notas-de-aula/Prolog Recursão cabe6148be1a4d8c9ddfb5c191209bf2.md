# Prolog: Recursão

Tema: Lógico

Para trabalhar com estruturas de dados e árvores é interessante o uso de recursão. 

No Prolog, as regras podem ser recursivas. Vamos para um exemplo clássico de árvore familiar:

```prolog
mae(maria, joana).
mae(joana, luis).
mae(cleia, otavio).
pai(orozimbo, otavio).
pai(otavio, luis).
irmao(orozimbo, manuel).
```

Queremos verificar quem são os ancestrais de uma folha da árvore, no caso de "luis". Para isso podemos fazer uma regra simples de ancestral já sendo ou o pai ou a mãe:

```prolog
ancestral(X, Y) :- mae(X, Y); pai(X, Y).            /* ";" para "ou" */
```

Porém, a mãe ou o pai do ancestral, também são ancestrais da folha. Assim, podemos expandir a regra para 2:

```prolog
ancestral(X, Y) :- mae(X, Y); pai(X, Y). % * ";" para "ou". => Criterio de parada
ancestral(X, Y) :- (mae(X, Z); pai(X, Z)), ancestral(Z, Y). % "," para "e" => Regra recursiva
```

Na segunda linha a regra é recursiva e na primeira linha é o critério de parada. Assim, podemos fazer a consulta:

```prolog
?- ancestral(X, luis).
X = joana ;
X = otavio ;
X = maria ;
X = cleia ;
X = orozimbo ;
false.
```