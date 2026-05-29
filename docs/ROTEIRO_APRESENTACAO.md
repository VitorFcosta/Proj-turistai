# Roteiro de Apresentacao

## 1. Objetivo da fala

Explicar o app funcionando no smartphone, sem slides, mostrando que ele atende geolocalizacao, mapa e IA via API.

Tempo recomendado: 3 a 5 minutos.

## 2. Abertura

Fala sugerida:

```text
Professor, nosso aplicativo se chama TouristAI. Ele ajuda o usuario a descobrir lugares proximos usando a localizacao atual do celular e inteligencia artificial.
```

## 3. Explicar o problema

Fala sugerida:

```text
O problema que pensamos e que uma pessoa em uma regiao desconhecida pode nao saber quais lugares proximos visitar. Um mapa comum mostra muitos pontos, mas nao necessariamente ajuda a escolher o que faz mais sentido para o perfil do usuario.
```

## 4. Demonstrar o uso

Sequencia da demonstracao:

1. Abrir o app no Android.
2. Mostrar a tela de preferencias.
3. Selecionar categoria, tempo, orcamento e deslocamento.
4. Permitir localizacao, se o app pedir.
5. Mostrar o mapa centralizado na posicao atual.
6. Mostrar os marcadores dos locais proximos.
7. Tocar para gerar recomendacao.
8. Mostrar a resposta da IA.

## 5. Explicar geolocalizacao

Fala sugerida:

```text
A geolocalizacao nao e usada apenas para mostrar o mapa. O app usa latitude e longitude para buscar locais proximos e enviar esse contexto para a IA. Se estivermos em outro lugar, as recomendacoes mudam.
```

## 6. Explicar IA

Fala sugerida:

```text
A IA recebe as preferencias do usuario, a localizacao e a lista de locais encontrados. Ela nao escolhe aleatoriamente: ela considera distancia, categoria, tempo disponivel, orcamento e forma de deslocamento para sugerir um roteiro.
```

## 7. Explicar arquitetura

Fala sugerida:

```text
O app Flutter chama uma API nossa hospedada na Vercel. Essa API chama a Gemini API. Fizemos assim para nao colocar a chave da IA dentro do aplicativo.
```

## 8. Conectar com os criterios de avaliacao

Fala sugerida:

```text
Sobre os criterios: temos interface mobile responsiva, mapa na tela, uso real de geolocalizacao, API com IA e exibicao do resultado no app. Tambem tratamos erros como permissao negada ou falta de resultados.
```

## 9. Se algo falhar na hora

### GPS negado

Fala:

```text
Esse caso mostra o tratamento de permissao. O app nao trava; ele avisa que precisa da localizacao para recomendar locais proximos.
```

### OpenStreetMap sem resultados

Fala:

```text
Como usamos dados ao vivo do OpenStreetMap, pode acontecer de uma categoria nao retornar lugares nessa regiao. Por isso o app informa o problema e orienta trocar categoria ou raio.
```

### IA demorando

Fala:

```text
Nesse momento o app esta chamando a nossa API, que por sua vez chama a Gemini API. A demora pode depender da internet.
```

## 10. Fechamento

Fala sugerida:

```text
Portanto, o TouristAI usa geolocalizacao para encontrar contexto real do usuario e IA para transformar esse contexto em recomendacoes praticas.
```

## 11. Checklist antes de entregar o celular

- Bateria acima de 50%.
- Internet funcionando.
- GPS ligado.
- App instalado.
- API publicada.
- Gemini API configurada.
- Pelo menos uma categoria testada no local.
- Volume/desbloqueio do celular sem atrapalhar.
