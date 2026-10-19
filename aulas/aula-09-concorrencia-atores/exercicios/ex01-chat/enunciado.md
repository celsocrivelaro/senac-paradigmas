# Exercício 1 — Paradigmas de Programação — Aula 09: Modelo de atores com Elixir

# Sala de chat

Uma sala de chat reúne quantas pessoas se quiser, e cada uma pode mandar
mensagens às outras: uma **mensagem pública** vai a todos da sala, menos a quem
a escreveu; uma **mensagem privada** vai a uma pessoa só.

Escreva o programa em um único arquivo `chat.exs`, sem biblioteca fora da
padrão (Elixir e OTP), projeto Mix, arquivo ou rede. Execução no compilador
online [JDoodle](https://www.jdoodle.com/execute-elixir-online), com a versão
**1.19.5** escolhida no menu de versões: o conteúdo do arquivo é colado no
editor e executado.

## Requisitos

1. **Cada pessoa é um processo.** O processo guarda, em ordem de chegada, as
   mensagens que recebeu, e as devolve quando pedidas.
2. **A sala é um processo.** Só ela sabe quem está na sala: guarda o nome de
   cada pessoa e o endereço (PID) do processo dela. Nenhum outro processo lê ou
   altera esse registro, a não ser por mensagem à sala.
3. **Entrar.** Uma pessoa entra na sala com um nome. Se o nome já está em uso,
   a entrada é recusada, e quem pediu recebe a recusa como resposta.
4. **Mensagem pública.** A sala repassa a mensagem a todos que estão nela,
   menos a quem a escreveu.
5. **Mensagem privada.** A sala repassa a mensagem só ao destinatário. Se ele
   não está na sala, quem enviou recebe um erro como resposta, e a sala continua
   funcionando.
6. **Quantas pessoas se quiser.** O número de pessoas não é fixo no código: as
   pessoas vêm de uma lista de nomes, e acrescentar um nome à lista basta para
   acrescentar uma pessoa.

A forma de escrever os processos é livre: com as primitivas `spawn`, `send` e
`receive`, como na calculadora e na memória, ou com GenServer. O formato das
mensagens trocadas entre os processos também é livre.

## Roteiro do programa principal

O programa principal, com as pessoas `ana`, `bruno`, `carla` e `davi`:

1. faz as quatro entrarem na sala;
2. tenta fazer entrar outra pessoa com o nome `ana`, e imprime a resposta;
3. `ana` envia a mensagem pública `oi, pessoal`;
4. `bruno` envia a `carla` a mensagem privada `almoco hoje?`;
5. `carla` envia a `zeca`, que não está na sala, a mensagem privada `oi`, e
   imprime a resposta;
6. `davi` envia a mensagem pública `cheguei`;
7. imprime, para cada pessoa, as mensagens que ela recebeu, em ordem.

A ordem das mensagens só é garantida entre um mesmo par remetente →
destinatário. O passo 7 precisa obter cada lista **depois** que a sala repassou
todas as mensagens; um pedido que vá do programa principal direto à pessoa pode
chegar antes de alguma mensagem repassada pela sala.

## O registro

Em comentário no topo do arquivo, em duas ou três frases cada:

1. como o programa garante que a lista impressa no passo 7 contém todas as
   mensagens enviadas antes, e na ordem certa;
2. por que a privada para quem não está na sala é respondida com um erro, e
   não derruba a sala.

## Entregável e verificação

O arquivo `chat.exs` executando, com o registro no topo. O texto exato da
saída é livre; o conteúdo, em toda execução, é este:

- a segunda entrada de `ana` é recusada;
- a privada para `zeca` volta com erro;
- `ana` recebeu: `davi: cheguei`;
- `bruno` recebeu: `ana: oi, pessoal`, `davi: cheguei`;
- `carla` recebeu: `ana: oi, pessoal`, `bruno (privada): almoco hoje?`,
  `davi: cheguei`;
- `davi` recebeu: `ana: oi, pessoal`.

Ninguém recebe a própria mensagem pública, e só `carla` recebe a privada de
`bruno`. Acrescentada uma quinta pessoa à lista, sem outra mudança no código,
ela entra na sala e recebe as duas mensagens públicas.
