# Testes Manuais

## 1. Objetivo

Garantir que o TouristAI funcione no smartphone Android antes da apresentacao.

Esses testes devem ser feitos no aparelho que sera entregue ao professor.

## 2. Ambiente de teste

Preencher quando a implementacao estiver pronta:

```text
Celular:
Versao do Android:
Data do teste:
Rede usada:
Versao do APK:
Responsavel pelo teste:
```

## 3. Checklist principal

| Teste | Passou? | Observacoes |
| --- | --- | --- |
| App abre no Android fisico |  |  |
| App nao fecha sozinho na abertura |  |  |
| Tela inicial aparece corretamente |  |  |
| Usuario consegue escolher categoria |  |  |
| Usuario consegue escolher tempo disponivel |  |  |
| Usuario consegue escolher orcamento |  |  |
| Usuario consegue escolher deslocamento |  |  |
| App pede permissao de localizacao |  |  |
| Usuario permite localizacao |  |  |
| App obtem latitude e longitude |  |  |
| Mapa aparece na tela |  |  |
| Mapa centraliza perto do usuario |  |  |
| Locais proximos aparecem no mapa |  |  |
| App chama backend |  |  |
| Backend chama Gemini API |  |  |
| Recomendacao aparece no app |  |  |
| APK instalado funciona sem computador |  |  |

## 4. Testes de erro

| Cenario | Resultado esperado | Passou? |
| --- | --- | --- |
| Usuario nega localizacao | App explica que precisa da permissao. |  |
| GPS desligado | App mostra mensagem orientando ativar localizacao. |  |
| Internet desligada | App mostra erro de conexao. |  |
| OpenStreetMap nao retorna locais | App sugere trocar categoria ou aumentar raio. |  |
| Backend fora do ar | App mostra erro amigavel. |  |
| Gemini API falha | App informa que nao conseguiu gerar recomendacoes. |  |

## 5. Teste de apresentacao completa

Executar exatamente como sera feito no dia:

1. Fechar o app completamente.
2. Abrir o app.
3. Escolher categoria.
4. Escolher tempo.
5. Escolher orcamento.
6. Escolher deslocamento.
7. Permitir localizacao.
8. Esperar mapa carregar.
9. Conferir marcadores.
10. Gerar recomendacao.
11. Ler a resposta da IA.
12. Explicar ao professor o que aconteceu.

Resultado esperado:

```text
O professor consegue ver mapa, localizacao, locais proximos e recomendacao gerada por IA.
```

## 6. Teste com redes diferentes

Testar em:

- Wi-Fi;
- internet movel;
- local parecido com o da apresentacao.

Motivo: mapa, OpenStreetMap e Gemini dependem de internet. Um app que funciona apenas no Wi-Fi de casa ainda nao esta pronto para apresentacao.

## 7. Criterio final

O app so deve ser considerado pronto quando passar pelo teste de apresentacao completa pelo menos duas vezes seguidas no mesmo celular.
