# Exercício 1 — Paradigmas de Programação — Aula 09: Modelo de atores com Elixir

# Sala de chat

Arquivo: [`exercicio-chat.exs`](exercicio-chat.exs). Nenhuma biblioteca fora da
padrão (Elixir e OTP), projeto Mix, arquivo ou rede: as pessoas e as mensagens
estão no próprio código.

Execução no compilador online [JDoodle](https://www.jdoodle.com/execute-elixir-online),
com a versão **1.19.5** escolhida no menu de versões: o conteúdo do arquivo é
colado no editor e executado.

Uma sala de chat reúne quantas pessoas se quiser, e cada uma pode mandar
mensagens às outras: uma **mensagem pública** vai a todos da sala, menos a quem
a escreveu; uma **mensagem privada** vai a uma pessoa só. Cada pessoa é um
processo, e a sala é um GenServer que conhece quem está nela e repassa as
mensagens:

```text
            publica / privada
   main  ----------------------->  Sala (GenServer)
                                   estado: %{"ana" => pid, "bruno" => pid, ...}
                                     |          |          |
                                send |     send |     send |
                                     v          v          v
                                   Pessoa     Pessoa     Pessoa
                                   (ana)      (bruno)    (carla)
```

O esqueleto já traz:

- `Pessoa`, pronta: um processo escrito com `spawn` e `receive`, que guarda em
  ordem as mensagens recebidas, no formato `{:publica, de, texto}` ou
  `{:privada, de, texto}`, e as devolve quando pedidas;
- a interface pública de `Sala` — `entrar/2`, `publica/2`, `privada/3` e
  `caixa/1` — e o *callback* do pedido de caixa, como modelo;
- o programa principal: quatro pessoas entram na sala, trocam três mensagens e,
  ao fim, cada caixa é impressa. A lista `nomes` aceita quantos nomes se quiser.

O esqueleto, executado antes de completado, cai na primeira entrada na sala:
`Sala` ainda não tem `init/1` nem o `handle_call/3` de `:entrar`.

## A sala

Complete `Sala` nos pontos marcados como `A COMPLETAR`:

- **Estado**: quem está na sala, como um *map* do nome da pessoa para o PID do
  processo dela. Começa vazio.
- **`init/1`**: devolve o estado inicial.
- **`handle_call/3`** para `{:entrar, nome, pid_pessoa}`: acrescenta a pessoa e
  responde `:ok`; se o nome já está na sala, responde `{:erro, :nome_em_uso}`
  e mantém o estado.
- **`handle_call/3`** para `{:publica, de, texto}`: envia `{:publica, de, texto}`
  a todos da sala, menos a `de`, e responde `:ok`.
- **`handle_call/3`** para `{:privada, de, para, texto}`: envia
  `{:privada, de, texto}` só a `para` e responde `:ok`; se `para` não está na
  sala, responde `{:erro, :destinatario_desconhecido}`.

Os *callbacks* novos ficam logo abaixo do comentário `A COMPLETAR`, antes do
*callback* de caixa já escrito: as cláusulas de `handle_call/3` precisam ficar
juntas.

Depois de completar, acrescente uma quinta pessoa à lista `nomes` e confira que
ela recebe as duas mensagens públicas.

## O registro

Preencha os dois itens do comentário no topo do arquivo, em duas ou três frases
cada:

1. por que as mensagens chegam a cada pessoa na ordem em que a sala as
   repassou, e por que o pedido de caixa passa pela sala em vez de ir direto do
   `main` para a pessoa;
2. por que a privada para quem não está na sala é respondida com
   `{:erro, :destinatario_desconhecido}`, e não derruba a sala.

## Entregável e verificação

O arquivo executando, com o registro no topo. Com as quatro pessoas do
esqueleto, o programa imprime, em toda execução:

```
ana entra de novo: {:erro, :nome_em_uso}
privada para zeca: {:erro, :destinatario_desconhecido}
ana recebeu: ["davi: cheguei"]
bruno recebeu: ["ana: oi, pessoal", "davi: cheguei"]
carla recebeu: ["ana: oi, pessoal", "bruno (privada): almoco hoje?", "davi: cheguei"]
davi recebeu: ["ana: oi, pessoal"]
```

Cada pessoa recebe as públicas dos outros, e não a própria; só carla recebe a
privada de bruno.
