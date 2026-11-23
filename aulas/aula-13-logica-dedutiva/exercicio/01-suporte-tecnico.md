# Exercício — Agente de suporte técnico

## Contexto

O agente de triagem do código da aula (`01-agente-triagem.pl`) conduz uma consulta: pergunta sintomas ao paciente e conclui um diagnóstico a partir das regras `doenca/2`. Este exercício usa o mesmo agente num domínio diferente: o atendimento de um usuário cujo computador não acessa a internet.

O arquivo [01-suporte-tecnico.pl](01-suporte-tecnico.pl) já traz os usuários simulados, o TELL (`informar/2`), as regras de ação, o ciclo e o predicado `atender/1`. Falta o conhecimento do domínio.

## O domínio

Um técnico de suporte investiga quatro falhas, nesta ordem, da verificação mais simples para a mais demorada:

1. **roteador desligado**: a luz do roteador está apagada;
2. **problema no provedor**: outros aparelhos da casa também estão sem internet e a luz de internet do roteador está vermelha;
3. **cabo desconectado**: o computador usa cabo e o ícone de rede aparece com um X;
4. **Wi-Fi desligado**: o computador usa Wi-Fi e o ícone de rede aparece com um X.

Os sintomas têm os nomes abaixo, os mesmos usados pelos usuários simulados:

| Sintoma | Átomo |
|---------|-------|
| a luz do roteador está apagada | `luz_do_roteador_apagada` |
| outros aparelhos estão sem internet | `outros_aparelhos_sem_internet` |
| a luz de internet do roteador está vermelha | `luz_de_internet_vermelha` |
| o computador usa cabo | `usa_cabo` |
| o computador usa Wi-Fi | `usa_wifi` |
| o ícone de rede aparece com um X | `icone_de_rede_com_x` |
| há cheiro de queimado | `cheiro_de_queimado` |

## Parte 1 — Base de conhecimento

Escreva os fatos `falha(Falha, Sintomas)`, um por falha, na ordem de investigação. Em seguida, rode `atender/1` para os cinco usuários abaixo e confira a conclusão:

| Consulta | Conclusão esperada |
|----------|--------------------|
| `?- atender(lia).` | `roteador_desligado` |
| `?- atender(marcos).` | `problema_no_provedor` |
| `?- atender(otavio).` | `cabo_desconectado` |
| `?- atender(nina).` | `wifi_desligado` |
| `?- atender(paula).` | `sem_diagnostico` |

Explique por que o atendimento de `nina` leva mais perguntas que o de `lia`.

## Parte 2 — O que mudou no agente

Compare o arquivo do exercício com `01-agente-triagem.pl`. Liste o que é diferente entre os dois e o que é igual. Relacione a resposta com a separação entre base de conhecimento e motor de inferência descrita na nota sobre agentes lógicos.

## Parte 3 — Regra de segurança

Cheiro de queimado exige desligar o equipamento da tomada antes de qualquer outra investigação. Acrescente a `melhor_acao/1` duas regras:

- concluir `desligar_da_tomada` quando `cheiro_de_queimado` estiver confirmado;
- perguntar sobre `cheiro_de_queimado` quando ainda não se souber nada sobre ele.

O usuário `rafael` sente cheiro de queimado e vê a luz do roteador apagada. Posicione as duas regras de modo que `atender(rafael)` conclua `desligar_da_tomada`.

Depois, mova as duas regras para logo antes de `melhor_acao(concluir(sem_diagnostico))`, rode `atender(rafael)` de novo e explique a conclusão obtida.
