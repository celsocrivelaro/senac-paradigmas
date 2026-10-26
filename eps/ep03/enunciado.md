# EP03 — Chat server em Go

Neste EP você vai construir um chat em Go com três programas: um **servidor**, um **cliente** e um **bot**. O servidor aceita conexões de vários usuários ao mesmo tempo, repassa as mensagens entre eles e trata comandos. O bot se conecta como se fosse um usuário, mas responde automaticamente.

O ponto de partida é o código base desta pasta, visto na aula de concorrência com corrotinas:

- `chat_server.go`: servidor que aceita conexões TCP e faz broadcast das mensagens para todos os clientes;
- `chat_client.go`: cliente que conecta ao servidor, envia o que é digitado e imprime o que chega.

Os dois usam a porta fixa `4444` em `localhost`. Mantenha host e porta fixos no seu trabalho.

## O que será avaliado

### Servidor

O servidor faz a comunicação entre os usuários conectados e deve:

1. Quando um usuário entrar, exibir no console do servidor e para todos os usuários: `Usuário @abc acabou de entrar`.
2. Quando um bot entrar, exibir no console do servidor e para todos os usuários: `Bot @abc acabou de entrar`.
3. Quando um usuário mandar uma mensagem pública, exibir para todos os usuários: `@abc disse: …`.
4. Quando um usuário mandar uma mensagem privada, exibir no console do servidor e apenas para o destinatário: `@abc disse em privado: …`.
5. Quando um usuário sair ou desconectar, exibir: `Usuário @abc saiu`.
6. Quando um usuário trocar de apelido, exibir: `Usuário @abc agora é @xyz`.

Os bots **não** recebem mensagens públicas, apenas as privadas.

Exemplo do console do servidor:

```
Usuário @Zezinho acabou de entrar
Usuário @Hack3r acabou de entrar
Bot @Inversor acabou de entrar
Usuário @Hack3r agora é @GatoPreto
Usuário @GatoPreto saiu
```

Dicas de implementação:

- Crie um canal exclusivo para cada usuário. Assim fica simples enviar uma mensagem privada a um só usuário ou fazer broadcast para todos.
- Separe as responsabilidades em gorrotinas, por exemplo:
  - uma para o broadcast das mensagens públicas;
  - uma para as mensagens privadas;
  - uma para as mensagens dos bots;
  - uma para os comandos, como a troca de apelido.

### Cliente

O cliente é um programa separado do servidor: é autônomo, mas conhece o protocolo de comunicação do servidor.

Antes de entrar no chat, o usuário define o seu apelido. Depois, além de conversar, pode usar os comandos:

| Comando | Efeito |
|---|---|
| `\changenick <apelido>` | Troca o apelido do usuário. |
| `\msg <mensagem>` | Envia uma mensagem pública. |
| `\msg @<apelido> <mensagem>` | Envia uma mensagem privada para `@<apelido>`. |
| `\exit` | Encerra a sessão e sai do programa. |

Exemplo:

```
\msg @Zezinho Oi!
\msg Olá pessoal
\changenick GatoPreto
\exit
```

### Bot

O bot é um programa separado do servidor e do cliente, e não pode estar no código de nenhum deles. Ele se conecta ao servidor como um usuário, mas com alguma indicação de que é um bot, para o servidor anunciá-lo como `Bot @abc`.

O bot não tem entrada de texto: é apenas reativo. Recebe mensagens e responde com outra mensagem de acordo com a sua função.

Faça um bot que **inverte** o texto recebido e responde para quem enviou. No seu console, o bot imprime a mensagem recebida e a resposta:

```
Mensagem de: @abc
Recebi: abcdef
Resposta: fedcba
```

## Entrega

Use ambiente local para executar o trabalho. Serviços como o repl.it não permitem abrir conexões TCP.

A entrega tem três arquivos:

| Arquivo | Conteúdo |
|---|---|
| `server.go` | O servidor. |
| `client.go` | O cliente, com o qual um usuário se conecta, envia e recebe mensagens. |
| `bot.go` | O bot, que se conecta ao servidor e responde automaticamente. |

### Apresentação

Deve ser entregue um slide com as explicações DETALHADAS da sua implementação. A não entrega acarretará uma perda de 3 pontos.

É obrigatório o uso de um repositório público.

Este trabalho deve seguir:

[Política de uso de ferramentas generativas de IA](https://app.notion.com/p/Pol-tica-de-uso-de-ferramentas-generativas-de-IA-1b53bb4e12a54b4aa06eaa02e62192f4?pvs=21)

[Política antiplágio](https://app.notion.com/p/Pol-tica-antipl-gio-5187d7b1ab514bfb8424ac0fcfb59dba?pvs=21)
