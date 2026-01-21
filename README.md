# Links

### Linkedin:

### Youtube: https://youtu.be/L9iuU-hTAw4


# Finanças Together

Aplicativo Flutter para gestão financeira colaborativa com múltiplos perfis de usuário, totalmente offline.

## 🚀 Características

- ✅ **100% Offline**: Todos os dados armazenados localmente com SQFlite
- 👥 **Múltiplos Usuários**: Gerencie finanças de diferentes pessoas
- 🎨 **Temas Claro/Escuro**: Interface adaptável com paleta sóbria
- 📊 **Visualizações Interativas**: Gráficos de pizza e barras agrupadas
- 🏷️ **Categorias Personalizadas**: Cores únicas auto-atribuídas
- 📤 **Exportação**: PDF com compartilhamento
- 🌍 **Internacionalização**: PT-BR por padrão
- ♿ **Acessibilidade**: Contraste adequado e semantic labels
- 🔄 **Modo Compartilhado**: Visualize dados de todos os usuários com cores diferenciadas

## 📋 Pré-requisitos

- Flutter SDK ≥ 3.5.4
- Dart SDK ≥ 3.5.4
- Android Studio / Vs Code 

## 🛠️ Instalação e Execução

### 1. Instale as dependências

```bash
flutter pub get
```

### 2. Execute o aplicativo

```bash
flutter run
```

### 3. Build para produção

```bash
# Android
flutter build apk --release

```

---

## 📖 Especificação Técnica Completa

## Visão Geral
Aplicativo Flutter multiplataforma (iOS/Android) para gestão financeira colaborativa com múltiplos perfis, totalmente offline usando SQFlite como persistência local.

## Arquitetura

### Padrão: BLoC (Business Logic Component)
- **State Management**: flutter_bloc
- **Persistência**: SQFlite (100% local, sem backend)
- **Navegação**: Navigator 2.0 com BottomNavigationBar customizado

### Estrutura de Camadas
```
┌─────────────────────────────────────┐
│        UI Layer (Widgets)           │
│  Screens, Forms, Charts, Animations │
└─────────────────────────────────────┘
              ↓↑
┌─────────────────────────────────────┐
│         BLoC Layer                  │
│  TransactionBloc, CategoryBloc,     │
│  FilterBloc, UserBloc               │
└─────────────────────────────────────┘
              ↓↑
┌─────────────────────────────────────┐
│      Repository Layer               │
│  UserRepository, CategoryRepository,│
│  TransactionRepository              │
└─────────────────────────────────────┘
              ↓↑
┌─────────────────────────────────────┐
│       Data Layer (DAOs)             │
│  UserDAO, CategoryDAO,              │
│  TransactionDAO + SQFlite           │
└─────────────────────────────────────┘
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                   # Entry point
├── app_theme.dart              # Temas claro/escuro
├── blocs/                      # State management (BLoC)
│   ├── transaction/
│   ├── category/
│   ├── filter/
│   └── user/
├── models/                     # User, Category, Transaction
├── repositories/               # Camada de negócio
├── data/                       # SQFlite + DAOs
├── ui/                         # Telas e widgets
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── categories_screen.dart
│   │   ├── transaction_form_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/
│       ├── bottom_nav.dart
│       ├── category_pie_chart.dart
│       ├── period_bar_chart.dart
│       ├── shared_period_bar_chart.dart
│       └── transaction_history_list.dart
└── utils/                      # Helpers e constantes
```

## Modelagem de Dados

### Entidades

#### User
```dart
{
  id: String (UUID),
  name: String,
  colorHex: String,
  createdAt: DateTime
}
```

#### Category
```dart
{
  id: String (UUID),
  name: String,
  type: CategoryType (INCOME, OUTCOME, BOTH),
  colorHex: String (UNIQUE),
  createdAt: DateTime
}
```

#### Transaction
```dart
{
  id: String (UUID),
  userId: String (FK),
  categoryId: String (FK),
  type: TransactionType (INCOME, OUTCOME),
  amount: double,
  date: DateTime,
  note: String?,
  createdAt: DateTime
}
```

### Esquema SQFlite

```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT CHECK(type IN ('INCOME','OUTCOME','BOTH')) NOT NULL,
  color_hex TEXT UNIQUE NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  type TEXT CHECK(type IN ('INCOME','OUTCOME')) NOT NULL,
  amount REAL NOT NULL,
  date INTEGER NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_category ON transactions(category_id);
```

## Funcionalidades Principais

### 1. Navegação Inferior (3 Botões)

#### Botão Esquerdo: Menu
- **Entrada**: Form (valor, data, categoria, nota)
- **Saída**: Form (valor, data, categoria, nota)
- **Categorias**: CRUD completo com auto-atribuição de cor única

#### Botão Centro: Dashboard (Estatísticas)
- **Filtros de período**: Dia | Semana | Mês (default) | Ano
- **Modo Individual/Compartilhado**:
  - **Individual**: Dados apenas do usuário ativo
    - Gráfico de pizza por categorias
    - Gráfico de barras (entrada verde, saída vermelha)
  - **Compartilhado**: Dados de todos os usuários
    - Gráfico de barras com 4 barras por período (entrada/saída para cada usuário)
    - Cores diferenciadas por usuário (baseadas na cor cadastrada)
    - Legenda com nome e cores de cada usuário
- **Visualizações por período**:
  - **Dia** → Datas individuais (últimos 7 dias)
  - **Semana** → Por dia da semana (Dom-Sáb)
  - **Mês** → Por semana (intervalos 23/11-29/11)
  - **Ano** → Por mês (Jan-Dez)
- **Histórico**: Lista filtrada com data, valor, usuário, categoria (com cor), tipo, nota
- **Exportação**: Botão PDF do período visível
- **Refresh automático**: Ao clicar no botão Estatísticas

#### Botão Direita: Conta
- **Gerenciar perfis**: CRUD de usuários com cor
- **Switcher rápido**: Trocar perfil ativo
- **Visualização**: Lista de usuários com preview de cor

### 2. Regras de Negócio

#### Categorias Globais
- Visíveis a todos os perfis
- **Cor única obrigatória**: Sistema auto-seleciona cor não usada
- Validação de unicidade na inserção/edição
- Tipos: INCOME, OUTCOME, BOTH
- Categorias com transações não podem ser deletadas

#### Transações
- **Obrigatório**: usuário, categoria, valor, data
- Não permitir criar sem categoria
- Sempre vinculadas ao usuário ativo no momento da criação

#### Filtros e Agregações
- Por período: Dia, Semana, Mês, Ano
- Por usuário: individual (modo padrão) ou todos (modo compartilhado)
- Preservação de filtros após operações CRUD

## 🎯 Status de Implementação

### ✅ Implementado
- ✅ Modelos de dados completos
- ✅ Database SQFlite com migrations
- ✅ DAOs com queries complexas
- ✅ Repositories completos
- ✅ FilterBloc, CategoryBloc, TransactionBloc, UserBloc
- ✅ Temas claro/escuro com toggle instantâneo
- ✅ Navegação com 3 botões
- ✅ Todas as telas principais funcionais
- ✅ Forms de transação e categoria com validação
- ✅ Gráficos com fl_chart (Pizza e Barras)
- ✅ Gráfico compartilhado com cores por usuário
- ✅ Histórico de transações agrupado por data
- ✅ Filtros de período funcionais (Dia/Semana/Mês/Ano)
- ✅ Agregação correta por período (dias da semana, semanas do mês, meses do ano)
- ✅ Modo Individual/Compartilhado
- ✅ Refresh automático ao clicar em Estatísticas
- ✅ Botões FAB (Individual/Compartilhado extended e Exportar mini)
- ✅ Espaçamento adequado entre gráfico e legenda

### 🚧 Em Desenvolvimento
- 🚧 Exportação PDF completa (estrutura pronta)
- 🚧 Widget de menu animado (ExpandingMenu)
- 🚧 Testes unitários

## 🎨 Tema Visual

### Paleta Sóbria

#### Modo Claro
- **Primary**: `#3B5998` (Azul profundo)
- **Secondary**: `#50C878` (Verde esmeralda)
- **Accent**: `#E67E22` (Terracota)
- **Background**: `#F5F5F5` (Cinza claro)
- **Surface**: `#FFFFFF`
- **Text**: `#2C3E50` (Cinza escuro)

#### Modo Escuro
- **Primary**: `#5C7CFA` (Azul suave)
- **Secondary**: `#51CF66` (Verde claro)
- **Accent**: `#FF8C42` (Laranja suave)
- **Background**: `#1A1A1A`
- **Surface**: `#2C2C2C`
- **Text**: `#E0E0E0`

### Paleta de Cores para Categorias/Usuários
```dart
[
  '#4A90E2', // Azul
  '#50C878', // Verde
  '#E67E22', // Laranja
  '#9B59B6', // Roxo
  '#E74C3C', // Vermelho
  '#1ABC9C', // Turquesa
  '#F39C12', // Amarelo dourado
  '#34495E', // Azul acinzentado
  '#C0392B', // Vermelho escuro
  '#16A085', // Verde marinho
  '#D35400', // Abóbora
  '#8E44AD', // Roxo escuro
]
```

## BLoCs - Events e States

### TransactionBloc

**Events:**
```dart
- LoadTransactionsByFilter(fromDate, toDate, userId, type, categoryId)
- AddTransaction(Transaction transaction)
- UpdateTransaction(Transaction transaction)
- DeleteTransaction(String id)
```

**States:**
```dart
- TransactionsInitial
- TransactionsLoading
- TransactionsLoaded(List<Transaction> transactions)
- TransactionOperationSuccess
- TransactionsError(String message)
```

### CategoryBloc

**Events:**
```dart
- LoadCategories()
- AddCategory(Category category)
- UpdateCategory(Category category)
- DeleteCategory(String id)
- GetAvailableColor()
```

**States:**
```dart
- CategoriesInitial
- CategoriesLoading
- CategoriesLoaded(List<Category> categories)
- AvailableColorLoaded(String colorHex)
- CategoryOperationSuccess
- CategoriesError(String message)
```

### UserBloc

**Events:**
```dart
- LoadUsers()
- AddUser(String name, String? colorHex)
- UpdateUser(User user)
- DeleteUser(String id)
```

**States:**
```dart
- UsersInitial
- UsersLoading
- UsersLoaded(List<User> users)
- UserOperationSuccess(String message)
- UsersError(String message)
```

### FilterBloc

**Events:**
```dart
- SetPeriod(Period period)
- ResetFilters()
```

**State:**
```dart
FilterState {
  Period period // DAY, WEEK, MONTH, YEAR
}
```

## Agrupamento Temporal

| Período | Agrupamento | Exemplo |
|---------|-------------|---------|
| **Dia** | Últimos 7 dias | 17/11, 18/11, ..., 23/11 |
| **Semana** | Por dia da semana | Dom, Seg, Ter, Qua, Qui, Sex, Sáb |
| **Mês** | Por semana | 23/11-29/11, 16/11-22/11, ... |
| **Ano** | Por mês | Jan, Fev, Mar, ..., Dez |

## 📚 Principais Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  sqflite: ^2.3.3+2
  path: ^1.9.0
  uuid: ^4.5.1
  intl: ^0.19.0
  fl_chart: ^0.69.0
  shared_preferences: ^2.3.3
  csv: ^6.0.0
  pdf: ^3.11.1
  printing: ^5.13.3
  share_plus: ^10.0.3
```

## 🧪 Testes

```bash
flutter test
```

## 📝 Convenções do Semana Brasileira

- Semana começa no **Domingo** e termina no **Sábado**
- Dias da semana: Dom, Seg, Ter, Qua, Qui, Sex, Sáb
- Filtro "Semana" mostra a semana atual completa (domingo a sábado)

## 🚀 Como Executar

1. **Instalar dependências**:
   ```bash
   flutter pub get
   ```

2. **Executar app**:
   ```bash
   flutter run
   ```

3. **Executar testes**:
   ```bash
   flutter test
   ```

## 📱 Uso do Aplicativo

1. **Primeiro acesso**: Crie um usuário na aba "Conta"
2. **Crie categorias**: Acesse "Menu" → "Gerenciar Categorias"
3. **Adicione transações**: "Menu" → "Nova Entrada" ou "Nova Saída"
4. **Visualize estatísticas**: Aba "Estatísticas" (centro)
5. **Alterne entre modos**: 
   - Botão azul com ícone de pessoa = Individual (apenas seu usuário)
   - Botão roxo com ícone de pessoas = Compartilhado (todos os usuários)
6. **Exporte dados**: Botão de download menor (mini FAB abaixo do botão de modo)

## 🎯 Recursos Especiais

- **Refresh Pull-to-Refresh**: Arraste para baixo no dashboard
- **Refresh Automático**: Clique no botão "Estatísticas" para atualizar
- **Tema Persistente**: Preferência salva localmente
- **Filtros Preservados**: Mantidos após CRUD de transações
- **Cores Automáticas**: Sistema atribui cores únicas para categorias
- **Semana Brasileira**: Começa no domingo, respeita convenção local

## 💡 Notas de Implementação

- **SharedPreferences**: Armazena userId ativo e preferência de tema
- **Locale**: PT-BR default com suporte a internacionalização
- **Acessibilidade**: Contraste mínimo 4.5:1, semantic labels em todos widgets interativos
- **Performance**: Otimizações em agregações de dados
- **Offline First**: Funciona 100% sem internet

---

Desenvolvido com Flutter 🎯

