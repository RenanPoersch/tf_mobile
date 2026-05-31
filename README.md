# TF Mobile - Gerenciador de Eventos

Aplicativo mobile desenvolvido em Flutter como trabalho da disciplina de Desenvolvimento Mobile. O projeto simula um sistema de gerenciamento de eventos com cadastro, edição, exclusão e consulta de **Usuários**, **Eventos** e **Inscrições**.

## Objetivo

O objetivo do app é demonstrar, na prática, conceitos de desenvolvimento mobile com Flutter, incluindo:

- organização em camadas com inspiração em MVVM;
- persistência local com SQLite (`sqflite`);
- navegação entre telas com `Navigator`, Drawer e abas;
- uso de componentes visuais como `GridView`, `ListView`, `PageView`, `Dialog`, `BottomSheet`, `Checkbox`, `Switch` e `TabBar`.

## Funcionalidades

- cadastro de usuários com status ativo/inativo;
- cadastro de eventos com data, tipo e imagem;
- listagem, edição e exclusão de eventos;
- criação e gerenciamento de inscrições;
- carrossel inicial com eventos em destaque;
- menu lateral para navegação entre as telas;
- tela com abas para visualizar os módulos principais;
- modal com detalhes do evento e botão para inscrição.

## Estrutura do projeto

- `lib/models/`: entidades do sistema, como `User`, `Event` e `Registration`;
- `lib/database/`: acesso ao banco local e DAOs;
- `lib/viewmodels/`: lógica de estado e operações com os dados;
- `lib/views/`: telas da aplicação;
- `assets/images/`: imagens utilizadas nos eventos.

## Arquitetura

O projeto segue uma separação por responsabilidade:

- **Models** representam os dados da aplicação;
- **DAOs** fazem o acesso ao SQLite;
- **ViewModels** concentram a lógica de atualização e filtragem;
- **Views** exibem a interface e interagem com o usuário.

Essa organização deixa o código mais fácil de manter e ajuda a demonstrar boas práticas em um projeto acadêmico.

## Principais telas

- **Home**: carrossel de eventos com destaque e acesso ao menu lateral;
- **Usuários**: lista de usuários com formulário de cadastro e edição;
- **Eventos**: grid de eventos com busca, edição e exclusão;
- **Inscrições**: lista de inscrições com confirmação e remoção;
- **Tabbed Pages**: exemplo de navegação por abas;
- **Modal do evento**: exibe os detalhes do evento e permite se inscrever.

## Tecnologias utilizadas

- Flutter
- Dart
- SQLite com `sqflite`
- `path`
- `intl`

### Obrigatório para rodar o app

- **Flutter SDK**: framework principal do projeto.
- **Git**: necessário para o Flutter e para baixar dependências.
- **Android Studio**: usado para instalar o Android SDK, criar emuladores e executar o app.
- **Android SDK / Platform Tools**: normalmente são instalados junto com o Android Studio.
- **Java Development Kit (JDK)**: o Android Studio já traz o necessário na maioria dos casos.

### Recomendado

- **Visual Studio Code**: editor leve para desenvolver e editar o projeto.
- **Extensão Flutter** no VS Code.
- **Extensão Dart** no VS Code.

### Opcional

- **Emulador Android** configurado no Android Studio.
- **Celular físico com depuração USB ativada**.
- **Visual Studio com workload de Desktop development with C++**, apenas se você quiser compilar também para Windows desktop.

### Verificação inicial

Depois de instalar tudo, abra o terminal e rode:

```bash
flutter doctor
```

Esse comando mostra se falta algum componente para desenvolver com Flutter no Windows.

## Como executar

1. Instale as dependências:

```bash
flutter pub get
```

2. Execute o aplicativo em um emulador ou dispositivo conectado:

```bash
flutter run
```

3. Para gerar um build Android:

```bash
flutter build apk
```

## Observações

- O app usa banco local, então os dados ficam salvos no dispositivo/emulador.
- As imagens dos eventos podem ser locais ou URLs válidas.
- Para a apresentação do trabalho, vale mostrar os fluxos de cadastro, navegação, carrossel e inscrições.

## Autor

Projeto desenvolvido para fins acadêmicos na disciplina de Mobile.
