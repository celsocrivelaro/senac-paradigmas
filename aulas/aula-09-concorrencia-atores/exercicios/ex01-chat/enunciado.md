# Exercício 1 — Paradigmas de Programação — Aula 09: Modelo de atores com Elixir

# Sala de chat

Uma sala de chat reúne quantas pessoas se quiser. Há uma sala só, e toda
mensagem é pública: o que uma pessoa escreve vai a todos da sala, menos a ela
mesma.

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
   a entrada é recusada, quem pediu recebe a recusa como resposta, e a sala
   continua funcionando.
4. **Enviar uma mensagem.** A pessoa envia a mensagem à sala, e a sala a
   repassa a todos que estão nela, menos a quem a escreveu.
5. **Quantas pessoas se quiser.** O número de pessoas não é fixo no código: as
   pessoas vêm de uma lista de nomes, e acrescentar um nome à lista basta para
   acrescentar uma pessoa.

A forma de escrever os processos é livre: com as primitivas `spawn`, `send` e
`receive`, como na calculadora e na memória, ou com GenServer. O formato das
mensagens trocadas entre os processos também é livre.

## Roteiro do programa principal

O programa principal, com as pessoas `ana`, `bruno`, `carla` e `davi`:

1. faz as quatro entrarem na sala;
2. tenta fazer entrar outra pessoa com o nome `ana`, e imprime a resposta;
3. `ana` envia `oi, pessoal`;
4. `bruno` envia `almoco hoje?`;
5. `davi` envia `cheguei`;
6. imprime, para cada pessoa, as mensagens que ela recebeu, em ordem.

A ordem das mensagens só é garantida entre um mesmo par remetente →
destinatário. O passo 6 precisa obter cada lista **depois** que a sala repassou
todas as mensagens; um pedido que vá do programa principal direto à pessoa pode
chegar antes de alguma mensagem repassada pela sala.

## O registro

Em comentário no topo do arquivo, em duas ou três frases cada:

1. como o programa garante que a lista impressa no passo 6 contém todas as
   mensagens enviadas antes, e na ordem certa;
2. por que duas pessoas não conseguem entrar com o mesmo nome, mesmo que os
   dois pedidos cheguem à sala ao mesmo tempo.

## Entregável e verificação

O arquivo `chat.exs` executando, com o registro no topo. O texto exato da
saída é livre; o conteúdo, em toda execução, é este:

- a segunda entrada de `ana` é recusada;
- `ana` recebeu: `bruno: almoco hoje?`, `davi: cheguei`;
- `bruno` recebeu: `ana: oi, pessoal`, `davi: cheguei`;
- `carla` recebeu: `ana: oi, pessoal`, `bruno: almoco hoje?`, `davi: cheguei`;
- `davi` recebeu: `ana: oi, pessoal`, `bruno: almoco hoje?`.

Ninguém recebe a própria mensagem. Acrescentada uma quinta pessoa à lista, sem
outra mudança no código, ela entra na sala e recebe as três mensagens.
