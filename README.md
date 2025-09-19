# PictureDay - NASA APOD iOS App

Um aplicativo iOS que consome a API pública da NASA APOD (Astronomy Picture of the Day) e permite aos usuários visualizar, navegar e favoritar imagens astronômicas incríveis.

## 📱 Funcionalidades

### ✅ Implementadas

1. **Foto do Dia** - Exibe a foto astronômica do dia com título e descrição
2. **Navegação Temporal** - Navegar para dias anteriores e posteriores
3. **Lista de Fotos** - Visualizar as últimas 10 fotos disponíveis com scroll inifinito carregando a cada 10 imagens
4. **Detalhes da Foto** - Tela dedicada com imagem em tamanho maior, título, descrição e data
5. **Sistema de Favoritos** - Salvar fotos favoritas localmente usando Core Data
6. **Tela de Favoritos** - Visualizar todas as fotos favoritadas
7. **Interface Intuitiva** - Design moderno com tema escuro e navegação por abas

## 🏗️ Arquitetura

### Padrão MVVM (Model-View-ViewModel)

O aplicativo segue a arquitetura MVVM para garantir separação clara de responsabilidades:

- **Models**: `APODResponse`, `APODError`, `APODServiceConfig`
- **Views**: `APODMainView`, `APODListView`, `APODDetailView`, `FavoritesView`
- **ViewModels**: `APODViewModel`, `APODListViewModel`, `FavoritesViewModel`, `APODDetailViewModel`
- **Services**: `APODService`, `FavoritesService`, `MockFavoritesService`

### Estrutura de Pastas

```
PictureDay/
├── Models/
│   └── APODModel.swift
├── Services/
│   ├── APODService.swift
│   ├── FavoritesService.swift
│   └── MockFavoritesService.swift
├── ViewModels/
│   ├── APODViewModel.swift
│   ├── APODListViewModel.swift
│   └── FavoritesViewModel.swift
├── Views/
│   ├── APODMainView.swift
│   ├── APODListView.swift
│   ├── APODDetailView.swift
│   └── FavoritesView.swift
└── ContentView.swift
```

## 🛠️ Tecnologias Utilizadas

- **SwiftUI** - Interface de usuário moderna e declarativa
- **Combine** - Programação reativa para gerenciamento de estado
- **Core Data** - Persistência local para favoritos
- **URLSession** - Requisições de rede para API da NASA
- **Swift Package Manager** - Gerenciamento de dependências

## 🚀 Como Executar o Projeto

### Pré-requisitos

- Xcode 15.0 ou superior
- iOS 16.0 ou superior
- Conexão com a internet

### Passos para Execução

1. **Clone o repositório**
   ```bash
   git clone <url-do-repositorio>
   cd PictureDay
   ```

2. **Abra o projeto no Xcode**
   ```bash
   open PictureDay.xcodeproj
   ```

3. **Selecione o simulador ou dispositivo**
   - Escolha um simulador iOS ou conecte um dispositivo físico

4. **Execute o projeto**
   - Pressione `Cmd + R` ou clique no botão "Run"

### Configuração da API

O aplicativo já está configurado com uma chave de API da NASA. Se necessário, você pode:

1. Obter sua própria chave em: https://api.nasa.gov/
2. Substituir a chave em `APODServiceConfig.swift`

## 📊 Decisões Técnicas

### 1. Arquitetura MVVM
**Decisão**: Implementar MVVM com Combine para reatividade
**Justificativa**: 
- Separação clara entre lógica de negócio e interface
- Facilita testes unitários
- Padrão recomendado pela Apple para SwiftUI

### 2. Core Data para Favoritos
**Decisão**: Usar Core Data em vez de UserDefaults
**Justificativa**:
- Melhor para dados estruturados complexos
- Suporte nativo a relacionamentos
- Performance superior para grandes volumes de dados

### 3. Combine para Programação Reativa
**Decisão**: Usar Combine para gerenciamento de estado assíncrono
**Justificativa**:
- Integração nativa com SwiftUI
- Facilita tratamento de operações assíncronas
- Código mais limpo e legível

### 4. Tema Escuro
**Decisão**: Implementar tema escuro como padrão
**Justificativa**:
- Melhor experiência para visualização de imagens astronômicas
- Economia de bateria em dispositivos OLED
- Estética moderna e elegante

## 🧪 Testes

### Testes Unitários Implementados

O projeto inclui testes unitários abrangentes:

- **APODService**: Testes de requisições de rede
- **FavoritesService**: Testes de persistência local
- **Modelos**: Testes de decodificação JSON
- **Configuração**: Testes de URLs e parâmetros

### Executando os Testes

```bash
# No Xcode
Cmd + U

# Ou via terminal
xcodebuild test -scheme PictureDay -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 🔧 Pontos de Melhoria

### Funcionalidades Futuras

1. **Cache de Imagens**
   - Implementar cache local para melhor performance
   - Reduzir uso de dados móveis

2. **Compartilhamento**
   - Permitir compartilhar fotos via redes sociais
   - Salvar imagens no álbum do dispositivo

3. **Notificações**
   - Notificar sobre nova foto do dia
   - Lembretes personalizáveis

4. **Filtros e Busca**
   - Filtrar fotos por tipo de mídia
   - Buscar fotos por palavras-chave

5. **Modo Offline**
   - Cache inteligente para uso sem internet
   - Sincronização quando conectado

### Melhorias Técnicas

1. **Performance**
   - Implementar lazy loading para listas grandes
   - Otimizar carregamento de imagens

2. **Acessibilidade**
   - Adicionar VoiceOver support
   - Melhorar contraste e legibilidade

3. **Internacionalização**
   - Suporte a múltiplos idiomas
   - Localização de datas e textos

4. **Testes**
   - Adicionar testes de UI
   - Implementar testes de integração

## 📱 Capturas de Tela

*As capturas de tela serão adicionadas após a execução do aplicativo*

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Autor

**Kleyson Tavares**
- GitHub: [@kleysontavares](https://github.com/kleysontavares)

## 🙏 Agradecimentos

- NASA por fornecer a API APOD gratuitamente
- Comunidade Swift/SwiftUI por recursos e tutoriais
- Apple pela documentação e ferramentas de desenvolvimento

---

**Desenvolvido com ❤️ usando SwiftUI e Swift**
