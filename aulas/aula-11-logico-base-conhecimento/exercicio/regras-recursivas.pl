/*
EXERCÍCIO: REGRAS DE PARENTESCO SOBRE UMA ÁRVORE GENEALÓGICA

A base abaixo amplia a árvore genealógica do exemplo de recursão
(codigo/03-recursao.pl): acrescenta a geração acima de serafim, irmãos,
cônjuges e primos. Ela só contém dois fatos primitivos, quem é progenitor de
quem e quem é casado com quem; todo outro parentesco é deduzido por regras.
A base não registra sexo nem gênero, e as relações não dependem deles: cada
nome de relação usa a forma do português como genérica, de modo que sogro/2
cobre sogro e sogra, irmao/2 cobre irmão e irmã, e assim por diante.

Formato dos fatos
    progenitor(P, F)  <- P é progenitor (pai ou mãe) de F
    casados(X, Y)     <- X e Y são casados (cada casal aparece uma vez só, numa ordem qualquer)

Árvore representada pelos fatos. Cada "+" une um casal, e a linha abaixo dele
leva aos filhos. Quando só um progenitor aparece, a base não registra o outro.

                                   bento
                                     |
               +---------------------+---------------------+
               |                                           |
        serafim + dulce                                sebastiao
               |                                           |
       +-------+--------+                         +--------+--------+
       |                |                         |                 |
orozimbo + cleia   manuel + ines                jorge          maria + joao
       |                |                         |                 |
   +---+-----+          |                         |          +------+------+
   |         |          |                         |          |             |
 otavio  pedro+lucia  rosa+caio                 helena     joana    carla+ricardo
             |          |                         |                        |
           tiago       davi                     fabio                   beatriz

Falta no diagrama um casal: otavio e joana são casados, e o filho dos dois é
luis. Como otavio é bisneto de bento pelo lado de serafim, e joana é bisneta
de bento pelo lado de sebastiao, os dois são parentes entre si, e luis
descende de bento por dois caminhos diferentes.

         otavio + joana
                |
               luis

Enunciado

Escreva as regras pedidas abaixo neste arquivo, depois dos fatos. Cada regra
deve ser escrita a partir dos fatos e das regras dos itens anteriores, sem
acrescentar fatos novos. Depois de cada item, rode as consultas de verificação
indicadas e confira se o conjunto de respostas é o esperado. A ordem das
respostas pode variar, e uma mesma resposta pode aparecer mais de uma vez:
cada caminho de prova diferente produz uma resposta, fenômeno que o item b
pede para explicar.

a. Cônjuge.
   Defina conjuge(X, Y): X e Y são casados. A relação é simétrica, mas o fato
   casados/2 registra cada casal numa ordem só; a regra deve funcionar nas
   duas ordens.
       ?- conjuge(joana, Y).            Y = otavio
       ?- conjuge(otavio, Y).           Y = joana

b. Irmãos.
   Defina irmao(X, Y): X e Y têm ao menos um progenitor em comum e são pessoas
   diferentes. Use a negação por falha (\+) e atente para a posição dela no
   corpo da regra.
       ?- irmao(otavio, Y).             Y = pedro
       ?- irmao(joana, Y).              Y = carla
       ?- irmao(serafim, Y).            Y = sebastiao
       ?- irmao(otavio, otavio).        false
   Explique, num comentário, por que irmao(otavio, Y) devolve pedro duas
   vezes e irmao(serafim, Y) devolve sebastiao uma vez só.

c. Avós e tios-avós.
   Defina avo(A, N): A é progenitor de um progenitor de N.
   Defina tio_avo(T, N): T é irmão de um avô ou de uma avó de N.
       ?- avo(A, luis).                 A = orozimbo ; A = cleia ; A = joao ; A = maria
       ?- tio_avo(T, luis).             T = manuel ; T = jorge
       ?- tio_avo(jorge, N).            N = luis ; N = beatriz
       ?- tio_avo(T, otavio).           T = sebastiao
       ?- tio_avo(T, orozimbo).         false

d. Sogros.
   Defina sogro(S, X): S é progenitor do cônjuge de X.
       ?- sogro(S, joana).              S = orozimbo ; S = cleia
       ?- sogro(S, otavio).             S = joao ; S = maria
       ?- sogro(joao, X).               X = otavio ; X = ricardo

e. Cunhados.
   Defina cunhado(C, X): C é irmão do cônjuge de X, ou C é cônjuge de um
   irmão de X.
       ?- cunhado(C, otavio).           C = carla ; C = lucia
       ?- cunhado(C, joana).            C = pedro ; C = ricardo
       ?- cunhado(C, ricardo).          C = joana
   Explique, num comentário, por que ricardo não aparece entre os cunhados de
   otavio, embora os dois sejam casados com duas irmãs.

f. Primos de primeiro grau.
   Defina primo(X, Y): X e Y são primos diretos, isto é, um progenitor de X é
   irmão de um progenitor de Y.
       ?- primo(luis, Y).               Y = tiago ; Y = beatriz
       ?- primo(otavio, Y).             Y = rosa
       ?- primo(joana, Y).              Y = helena
       ?- primo(luis, davi).            false

g. (desafio) Primos de segundo e terceiro grau.
   Primos de segundo grau são pessoas cujos progenitores são primos de
   primeiro grau; primos de terceiro grau são pessoas cujos progenitores são
   primos de segundo grau.
   Defina primo_segundo_grau(X, Y) a partir de primo/2 e
   primo_terceiro_grau(X, Y) a partir de primo_segundo_grau/2, seguindo
   literalmente essas definições.
       ?- primo_segundo_grau(luis, Y).      Y = davi ; Y = fabio
       ?- primo_segundo_grau(otavio, Y).    Y = helena ; Y = joana ; Y = carla
       ?- primo_terceiro_grau(davi, Y).     Y = luis ; Y = beatriz ; Y = fabio
       ?- primo_terceiro_grau(luis, Y).     Y = tiago ; Y = beatriz ; Y = davi ; Y = fabio ; Y = luis
   A última consulta mostra luis como primo de terceiro grau de si mesmo.
   Explique, num comentário:
     1. por que otavio e joana aparecem como primos de segundo grau;
     2. por que luis aparece entre os próprios primos de terceiro grau, e por
        que tiago e beatriz, primos de primeiro grau dele, também aparecem;
     3. por que fabio é, ao mesmo tempo, primo de segundo e de terceiro grau
        de luis, e se isso é um erro da regra ou um fato da árvore.
   Corrija primo_terceiro_grau/2 para que nenhuma pessoa seja prima de si
   mesma. Depois da correção:
       ?- primo_terceiro_grau(luis, Y).     Y = tiago ; Y = beatriz ; Y = davi ; Y = fabio
   Por fim, descreva o padrão comum às três regras de primos e escreva em
   pseudocódigo um único predicado primo_de_grau(X, Y, N) que cubra qualquer
   grau N, indicando qual é a cláusula de parada.
*/

% filhos de bento
progenitor(bento, serafim).
progenitor(bento, sebastiao).

% filhos de serafim e dulce, e de sebastiao
progenitor(serafim, orozimbo).
progenitor(dulce, orozimbo).
progenitor(serafim, manuel).
progenitor(dulce, manuel).
progenitor(sebastiao, jorge).
progenitor(sebastiao, maria).

% filhos de orozimbo e cleia, manuel e ines, jorge, e maria e joao
progenitor(orozimbo, otavio).
progenitor(cleia, otavio).
progenitor(orozimbo, pedro).
progenitor(cleia, pedro).
progenitor(manuel, rosa).
progenitor(ines, rosa).
progenitor(jorge, helena).
progenitor(joao, joana).
progenitor(maria, joana).
progenitor(joao, carla).
progenitor(maria, carla).

% filhos de otavio e joana, pedro e lucia, carla e ricardo, rosa e caio, e helena
progenitor(otavio, luis).
progenitor(joana, luis).
progenitor(pedro, tiago).
progenitor(lucia, tiago).
progenitor(ricardo, beatriz).
progenitor(carla, beatriz).
progenitor(caio, davi).
progenitor(rosa, davi).
progenitor(helena, fabio).

% casais
casados(serafim, dulce).
casados(orozimbo, cleia).
casados(manuel, ines).
casados(joao, maria).
casados(otavio, joana).
casados(pedro, lucia).
casados(carla, ricardo).
casados(rosa, caio).

% Escreva as regras a partir daqui.
