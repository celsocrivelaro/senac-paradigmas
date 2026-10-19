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

## Dicas de implementação

As dicas 1 a 7 seguem os conceitos da nota 01 (o modelo de atores) e não
dependem da forma escolhida para escrever os processos. A dica 8 é para quem
usar GenServer.

1. **Comece pelo estado e pelas mensagens de cada ator.** Um ator é estado
   privado, caixa de correio e comportamento. Antes de escrever código, anote
   para a pessoa e para a sala qual é o estado e quais mensagens cada uma
   trata. Por exemplo, o estado da sala é a associação de nomes a PIDs, e
   `entrar` e `enviar` são duas das mensagens dela.
2. **O estado muda pela terceira ação.** O ator não altera uma variável: ele
   trata a próxima mensagem com o estado novo, como a memória da calculadora,
   que se chama de novo com o valor salvo. Isso vale para a lista de mensagens
   da pessoa e para o registro da sala. Se a lista for montada pela frente,
   ela precisa ser invertida antes de ser devolvida.
3. **A resposta é outra mensagem.** O envio não devolve valor. Toda operação
   que precisa de resposta (o resultado da entrada, a lista de mensagens) leva
   na mensagem o PID de quem vai receber a resposta, e esse processo espera
   com `receive`. Um `after` na espera mostra o erro em vez de travar o
   programa quando a resposta não vem.
4. **Uma mensagem por vez.** A sala trata um pedido de cada vez. Verificar se
   o nome está em uso e registrar o nome dentro do tratamento de uma mesma
   mensagem dispensa qualquer trava. Pense no que aconteceria se a verificação
   e o registro fossem feitos por mensagens separadas.
5. **Só se envia a quem se conhece o endereço.** Para repassar uma mensagem, a
   sala precisa do PID de cada pessoa, e por isso o PID vai junto no pedido de
   entrada. Para que ninguém receba a própria mensagem, a sala também precisa
   saber quem escreveu, e o pedido de envio tem de carregar essa informação.
6. **A ordem só vale entre o mesmo par.** As mensagens repassadas chegam à
   pessoa vindas da sala. Um pedido de lista que também chegue à pessoa vindo
   da sala entra na caixa de correio depois de todas elas. Se o pedido for
   direto do programa principal, ele vem de outro remetente, e nada garante a
   ordem.
7. **Criar atores a partir de dados.** Um ator pode criar outros. Com a lista
   de nomes, um `Enum.map` ou um `for` cria um processo por pessoa e guarda o
   PID de cada uma. Assim, uma pessoa nova não exige outra mudança no código.
8. **A sala pode ser um GenServer.** É um ator com estado (a associação de
   nomes a PIDs) que trata uma mensagem por vez, que é o que o GenServer
   oferece pronto. Siga a divisão do contador do arquivo
   `05-genserver-callback.exs`: uma interface pública (`entrar`, `enviar`),
   o estado criado em `init/1` e um callback por mensagem. Entrar precisa de
   resposta, porque pode ser recusado, e por isso é um `GenServer.call`
   tratado em `handle_call/3`. Enviar não precisa de resposta, e pode ser um
   `GenServer.cast` tratado em `handle_cast/2`. A pessoa pode continuar com
   `spawn`, `send` e `receive`.

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
