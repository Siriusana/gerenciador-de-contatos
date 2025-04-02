# Gerenciador de Contatos

Este é um projeto Flutter para gerenciar contatos, desenvolvido no [Google Project IDX](https://idx.dev/). O objetivo é criar um aplicativo simples e funcional para cadastro, edição e remoção de contatos.

## Tecnologias Utilizadas
- **Flutter** (SDK para desenvolvimento multiplataforma)
- **Dart** (Linguagem de programação do Flutter)
- **SQLite** (Banco de dados local para armazenamento dos contatos)
- **Provider** (Gerenciamento de estado)

## Funcionalidades
- Adicionar novos contatos
- Editar informações de contatos existentes
- Excluir contatos
- Listar contatos salvos
- Busca e filtragem de contatos

## Como Configurar o Projeto

### 1. Clonar o repositório
```sh
  git clone https://github.com/Siriusana/gerenciador-de-contatos.git
  cd gerenciador-de-contatos
```

### 2. Instalar dependências
```sh
  flutter pub get
```

### 3. Executar o projeto
```sh
  flutter run
```

## Estrutura do Projeto
```
/gerenciador-de-contatos
│── lib/
│   ├── main.dart           # Arquivo principal
│   ├── models/             # Modelos de dados
│   ├── screens/            # Telas do app
│   ├── providers/          # Gerenciamento de estado
│   ├── database/           # Integração com SQLite
│   └── widgets/            # Componentes reutilizáveis
│
│── pubspec.yaml            # Configuração do projeto e dependências
│── README.md               # Documentação
```

## Dependências Principais
Certifique-se de que seu `pubspec.yaml` inclui as seguintes dependências:
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.2.8+4  # Gerenciamento de banco de dados local
  path_provider: ^2.1.2  # Acesso a diretórios do dispositivo
  provider: ^6.0.5  # Gerenciamento de estado
```




