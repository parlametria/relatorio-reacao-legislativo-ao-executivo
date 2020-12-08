## Como usar o parlametria para processar os dados de proposições

Este é um tutorial básico para usar o Parlametria para capturar, processar e exportar os dados relacionados a um conjunto de proposições de interesse. 

Neste tutorial será possível executar e gerar os dados que o Parlametria utiliza para criar os paineis de análise das proposições do Congresso.

## Instalação de dependências
Você precisará instalar o [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) e o [docker-compose](https://docs.docker.com/compose/install/) para a execução do processamento.

Com tudo instalado, vamos prosseguir.

## Passo 1

O processamento dos dados do Parlametria assumem como entrada uma lista de proposições de interesse. Essa lista deve ser um CSV no formato dessa [planilha].(https://docs.google.com/spreadsheets/d/1ErZBSZ6WlgUAQKfr5-X52JSdnbWgWQ9VQg3juh5WQEo/edit?usp=sharing)

As colunas `id_camara` e `id_senado` precisam estar preenchidas com os identificadores das proposições nas suas respectivas casas.

Neste passo você deve gerar ou atualizar uma lista de proposições neste formato. Essa lista será usada em passos seguintes.

## Passo 2

Baixe os repositórios [leggo-geral](https://github.com/parlametria/leggo-geral) e do [leggoR](https://github.com/parlametria/leggor). 

O repositório [rcongresso](https://github.com/analytics-ufcg/rcongresso) deve ser clonado dentro da pasta do leggoR para ser usado durante o processamento.

O **leggoR** é reponsável por empacotar as funções que capturam os processam os dados de proposições e das entidades envolvidas no processo (parlamentares, comissões).

O **leggo-geral** é responsável por orquestrar os diferentes módulos do processamento e executá-los de maneira coordenada.

## Passo 3

Baixe o CSV da planilha que foi gerada no passo 1 e salve em `inst/extdata/proposicoes_local.csv`

Crie um arquivo CSV em `inst/extdata/interesses_local.csv` com o conteúdo

```csv
interesse,url,nome,descricao
painel,./inst/extdata/proposicoes_local.csv,Proposições,Lista de proposições
```

## Passo 4

Crie um arquivo .env na raiz do repositório **leggo-geral** com o seguinte conteúdo:

```
URL_INTERESSES=./inst/extdata/interesses_local.csv
PLS_FILEPATH=./leggo_data/pls_interesses.csv
WORKSPACE_FOLDERPATH=../
EXPORT_FOLDERPATH=./leggo_data
LEGGOR_FOLDERPATH=./leggoR
LEGGOTRENDS_FOLDERPATH=./leggoTrends
VERSOESPROPS_FOLDERPATH=./versoes-de-proposicoes
LEGGOCONTENT_FOLDERPATH=./leggo-content
LOG_FOLDERPATH=./logs/
BACKUP_FOLDERPATH=./backups/
PROD_BACK_APP=production_app_name
DEV_BACK_APP=production_app_name
URL_LISTA_ANOTACOES=
```

## Passo 5

Realize o build do serviço de execução do processamento via docker.

Na raiz do leggo-geral, execute:
```
./update_leggo_data.sh -build-leggor
```

## Passo 6

Inicie o processamento dos dados para as proposições de interesse:

```
./update_leggo_data.sh -run-basic-pipeline
```

## Passo 7

Salve os CSV's processados.

Use o comando de gerar backup para exportar a pasta com os csvs processados pelo leggoR.

```
./update_leggo_data.sh -generate-backup
```

Note que a pasta com o csvs foi copiada para a pasta `./backup`, que está no mesmo nível do diretório que contém os repositórios do leggoR e do leggo-geral.

Copie os csvs para o diretório `data/leggo_data`

Pronto! O processamento dos csvs usando o Parlametria foi concluído.
