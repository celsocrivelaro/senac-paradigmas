# Paradigmas de Programação — Aula 08: Concorrência, gorrotinas e canais — Concorrência e paralelismo

## Introdução

O paradigma concorrente trata de programas compostos por várias atividades em
andamento ao mesmo tempo. Dois termos aparecem juntos nesse assunto e costumam
ser usados como sinônimos: **concorrência** e **paralelismo**. Não são. Um diz
respeito à forma como o programa é estruturado; o outro, à forma como ele é
executado pelo hardware. Esta nota define os dois, mostra que um não implica o
outro e separa as tarefas que se beneficiam de concorrência das que precisam de
paralelismo — distinção que sustenta o exemplo final da aula.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Distinguir concorrência de paralelismo.
2. Classificar um cenário dado como concorrente, paralelo, ambos ou nenhum.
3. Distinguir tarefa limitada por E/S de tarefa limitada por CPU, e explicar por
   que a primeira se beneficia de concorrência mesmo em um único núcleo.

## Desenvolvimento teórico

### Concorrência

**Concorrência** é uma propriedade da **estrutura** de um programa: ele é
composto por tarefas que podem estar em andamento no mesmo intervalo de tempo,
sem que uma precise terminar para a outra começar. Duas tarefas são
concorrentes quando os seus intervalos de execução se sobrepõem — a segunda
começa antes de a primeira acabar.

A definição não exige que as tarefas executem no mesmo instante. Em um
processador de um só núcleo, o sistema operacional alterna entre elas: executa
um trecho de uma, suspende-a, executa um trecho da outra. As duas estão em
andamento durante todo o intervalo, embora em cada instante só uma esteja de
fato executando.

### Paralelismo

**Paralelismo** é uma propriedade da **execução**: tarefas executando no mesmo
instante, em unidades de processamento distintas — núcleos de uma CPU,
processadores de uma máquina, máquinas de um *cluster*.

A formulação de Pike (2012) resume a diferença: concorrência é *lidar* com
muitas coisas ao mesmo tempo; paralelismo é *fazer* muitas coisas ao mesmo
tempo. A primeira é uma forma de organizar o programa; a segunda, uma forma de
executá-lo.

### A independência entre as duas

As duas propriedades são independentes:

| | Sem paralelismo | Com paralelismo |
|---|---|---|
| **Sem concorrência** | programa sequencial em um núcleo | a mesma operação sobre os elementos de um vetor, dividida entre núcleos |
| **Com concorrência** | várias tarefas intercaladas em um núcleo | várias tarefas distribuídas entre núcleos |

A linha do tempo abaixo mostra duas tarefas, `A` e `B`, em cada caso. Cada
colchete é uma fatia de tempo:

```
Concorrência em um núcleo (intercalação)
núcleo 1:  [A][B][A][B][A][B]

Paralelismo em dois núcleos
núcleo 1:  [A][A][A]
núcleo 2:  [B][B][B]
```

No primeiro caso, as duas tarefas terminam juntas, no fim da sexta fatia, e
cada uma usou metade do núcleo. No segundo, terminam na terceira fatia. O
programa pode ser exatamente o mesmo nos dois casos: a estrutura concorrente é
escrita pelo programador; o paralelismo depende de quantos núcleos estão
disponíveis quando o programa executa.

Decorre daí que estruturar um programa de forma concorrente é o que **permite**
paralelismo, mas não o garante. Um programa concorrente executado em um núcleo
continua correto, apenas sem o ganho de tempo do paralelismo.

### Tarefa que espera e tarefa que calcula

O ganho que a concorrência traz depende do que as tarefas fazem.

- Uma tarefa **limitada por E/S** (*I/O-bound*) passa a maior parte do tempo
  esperando: a resposta de um servidor, a leitura de um disco, a entrada de um
  usuário. Enquanto espera, não usa a CPU.
- Uma tarefa **limitada por CPU** (*CPU-bound*) passa a maior parte do tempo
  calculando: compressão, criptografia, multiplicação de matrizes.

Para tarefas limitadas por E/S, a concorrência reduz o tempo total **mesmo em um
único núcleo**: enquanto uma tarefa espera, outra usa o processador. Três
consultas de 100 ms, 250 ms e 180 ms feitas uma após a outra levam
100 + 250 + 180 = 530 ms; feitas de forma concorrente, levam o tempo da mais
lenta, 250 ms, porque as esperas se sobrepõem.

Para tarefas limitadas por CPU, a concorrência sozinha não reduz o tempo: em
um núcleo, intercalar duas tarefas de cálculo leva o mesmo tempo que
executá-las em sequência. O ganho só vem com paralelismo, e é limitado pelo
número de núcleos.

## Exemplos

- **Servidor web.** Atende muitas requisições ao mesmo tempo, e cada uma passa a
  maior parte do tempo esperando o banco de dados ou a rede. É concorrente por
  estrutura; o paralelismo, quando há vários núcleos, é um ganho adicional.
- **Renderização de uma imagem por faixas.** Cada núcleo calcula uma faixa da
  imagem. É paralelo; as faixas não interagem, e a estrutura do programa é a
  mesma operação repetida.
- **Interface gráfica.** A tela continua respondendo enquanto um arquivo é
  salvo. É concorrente, e o é mesmo em um processador de um núcleo.

## Fontes e leituras

- PIKE, Rob. **Concurrency is not Parallelism.** Palestra apresentada na
  Heroku Waza, São Francisco, 2012.
- DONOVAN, Alan A. A.; KERNIGHAN, Brian W. **The Go Programming Language.**
  Boston: Addison-Wesley, 2015. Capítulo 8.
