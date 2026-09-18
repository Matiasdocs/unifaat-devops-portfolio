\# Aula 01 — Fundamentos de Git e Docker



\## O que aprendi



Antes eu usava Git só pra salvar código no GitHub, sem pensar muito no histórico. Nessa aula entendi que cada commit é tipo um "save point" do projeto, e que dá pra voltar nele depois se precisar.



A parte de branch fez mais sentido do que eu esperava: em vez de ficar editando tudo direto na main, eu abri uma branch separada (`feature/aula-01-app`) só pra montar a aplicação, e só juntei tudo de volta quando já estava funcionando. Evita deixar a main quebrada no meio do caminho.



Também usei o padrão de mensagem de commit (`feat:`, `docs:`, `fix:`) que o professor pediu. No começo achei meio burocrático, mas dá pra ver o ganho quando você olha o `git log` depois e sabe exatamente o que cada commit fez sem precisar abrir o diff.



Sobre Docker: a coisa que mais confundia minha cabeça era a diferença entre imagem e container. Ficou mais claro assim: a imagem é a "receita" pronta e congelada, e o container é essa receita executando de verdade, isolada do resto do meu PC. E o `.dockerignore` serve pra não empacotar lixo (tipo `node\_modules`) dentro da imagem.



\## Comandos Git praticados



\- `git clone`

\- `git checkout -b feature/aula-01-app`

\- `git add` / `git commit -m "..."`

\- `git checkout main` + `git merge feature/aula-01-app`

\- `git push origin main` e `git push origin feature/aula-01-app`

\- `git log --oneline`



\## Comandos Docker praticados



\- `docker build -t portfolio-aula01:1.0 .`

\- `docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0`

\- `docker ps`

\- `docker logs portfolio-test`

\- `docker stop portfolio-test` / `docker rm portfolio-test`



\## Como executar este container



```bash

cd aula-01/app

docker build -t portfolio-aula01:1.0 .

docker run -d -p 3000:3000 portfolio-aula01:1.0

curl http://localhost:3000

```



\## Dificuldades encontradas



O que demorei a perceber: salvei o Dockerfile pelo Bloco de Notas e ele virou `Dockerfile.txt` sem eu notar. O `git add` simplesmente não achava o arquivo, e demorei um pouco pra entender o motivo. Resolvi renomeando com `ren Dockerfile.txt Dockerfile`.

