# MobEngine

A modular and extensible AI framework for Roblox.

# Features

このライブラリでは、主に以下の5つの機能を提供しています

* **柔軟な行動システム**
  Behavior TreeやUtility AI、State Machineなど、自分の好きなAI方式をBehaviorとして実装可

* **抽象化された行動用関数**
  `Move()`や`Search()`などのMethodによって、AIの意思決定と実際の処理を分離

* **強力な挙動管理システム**
  同じMethodでも、状況や環境に応じて実行する処理を柔軟に変更可

* **Luauの型サポート**
  ライブラリ内部で厳密な型定義を行っているため、Roblox Studio上で型推論や自動補完を活用可

* **高い拡張性**
  モブAIだけでなく、NPC、武器、スキルなど、様々なゲームシステムへ応用が可能

# Core Concepts

MobEngineでは、以下の要素を中心にAIを構成します。

- **Engine**
  MobEngineの各コンポーネントを管理し、Mobの生成やBehavior、Provider、Adapterなどを統括する中核となる要素

- **Behavior**
  このライブラリにおける**意思決定**を行う要素

- **Method**
  Behaviorから使用される**抽象的な行動**を定義する要素

- **Adapter**
  Methodで指定された**抽象的な行動**を**具体的な処理**へ翻訳する、いわば「翻訳機」のような要素

- **Provider**
  Adapterによって選択された**具体的な処理**を実際に実行する要素

- **Plugin**
  イベント駆動によってモブに**独自の機能や振る舞い**を追加する拡張要素


# Components

**Core Concepts**で紹介した各コンポーネントについて、ここから詳しく解説します。

まず、これ以降の説明で多用する`ctx`について説明します。

```luau
ctx = {
	Blackboard: { [any]: any },
	Methods: { [string]: MethodInstance },
	Config: { [any]: any },
	Mob: {
		Model: Model?,
		Humanoid: Humanoid?,
		RootPart: BasePart?,
	},
	Plugin: {
		SendEventAsync: (EventName: string, ...any) -> (),
		InvokeEvent: (EventName: string, ...any) -> ...any,
	}
}
```

`ctx`は、BehaviorやProviderなどが、そのMobに関連する情報へアクセスするためのContextです。

---

## Engine

EngineはMobEngine全体を管理する**中核となる要素**です。

Blackboard、Methods、DefaultConfigをもとにEngineを作成し、ProviderやAdapterの登録、Behaviorのロード、Mobの生成など、MobEngineの主要な機能を管理します。

### EngineInstance

Engineを作成すると`EngineInstance`が返されます。

### API

#### `MobEngine.createEngine(Blackboard, Methods, DefaultConfig)`

MobEngineのEngineを作成します。

```luau
local engine = MobEngine.createEngine(
	Blackboard,
	Methods,
	DefaultConfig
)
```

#### `engine.createMethod(MethodName)`

Methodを作成します。

#### `engine.createProvider(ProviderName, ProviderMethods)`

Providerを作成します。

#### `engine.createAdapter(AdapterName, Methods)`

Adapterを作成します。

#### `engine.createBehavior(Behavior)`

Behaviorを作成します。

#### `engine:registerProvider(Provider)`

ProviderをEngineへ登録します。

#### `engine:registerAdapter(Adapter)`

AdapterをEngineへ登録します。

#### `engine:loadBehavior(Behavior)`

BehaviorをEngineへロードします。

#### `engine:createMob(Model, Providers, Config, Plugin)`

設定したProvider、Config、Pluginなどを使用してMobを生成します。

---

## Behavior

BehaviorはMobEngineにおける**意思決定**を担当します。

Behavior自身が具体的な処理を実装するのではなく、`ctx.Methods`に用意されたMethodを使用してMobに必要な行動を要求します。

そのため、Behaviorは「**何をするか**」を決定し、「**どのように実行するか**」はMethod、Adapter、Providerへ委ねることができます。

Behaviorの実装方法は限定されていません。

Behavior Tree、Utility AI、State Machineなど、様々なAI方式をBehaviorとして実装できます。

### BehaviorInstance

Behaviorを作成すると`BehaviorInstance`が返されます。

### API

#### `engine.createBehavior(Behavior)`

Behaviorを作成します。

```luau
local behavior = engine.createBehavior(function(ctx)
	-- Behavior
end)
```

#### `engine:loadBehavior(Behavior)`

作成したBehaviorをEngineへロードします。

```luau
engine:loadBehavior(behavior)
```

---

## Method

MethodはBehaviorなどから使用される、**抽象的な行動**を定義します。

Methodは具体的な処理を直接持つのではなく、「Moveする」「Searchする」「Attackする」といった**行動そのもの**を表します。

BehaviorはMethodを通して行動を要求するため、具体的な実装を意識する必要がありません。

Methodが実際にどのような処理として実行されるかは、AdapterとProviderによって決定されます。

### MethodInstance

Methodを作成すると`MethodInstance`が返されます。

### API

#### `MobEngine.createMethod(MethodName)`

Methodを作成します。

```luau
local Move = MobEngine.createMethod("Move")
```

---

## Adapter

Adapterは、Methodで指定された**抽象的な行動を具体的な処理へ変換する役割**を持ちます。

BehaviorがMethodを実行すると、AdapterはそのMethodに対応するProviderの処理を決定します。

AdapterにはProviderのMethodを直接指定することも、**関数を使用して状況に応じた処理を動的に決定することもできます。**

そのため、同じMethodでもMobの状態や環境などに応じて異なる処理を実行できます。

例えば`Move()`という同じMethodでも、

```text
地上     → Walk
敵を発見 → Run
水中     → Swim
空中     → Fly
```

のようにAdapter側で実行する処理を変更できます。

Adapterは、**BehaviorとProviderを直接結び付けず、その間を抽象化する重要な層**として機能します。

### AdapterInstance

Adapterを作成すると`AdapterInstance`が返されます。

### API

#### `engine.createAdapter(AdapterName, Methods)`

Adapterを作成します。

```luau
local adapter = engine.createAdapter("Move", {
	-- Methods
})
```

#### `engine:registerAdapter(Adapter)`

AdapterをEngineへ登録します。

```luau
engine:registerAdapter(adapter)
```

---

## Provider

Providerは、Adapterによって選択された**具体的な処理を実際に実行する役割**を持ちます。

Providerはゲーム側の具体的なシステムとの接続点になります。

例えば移動を担当するProviderであれば、Humanoidを動かしたり、飛行処理を行ったりする実際の処理を実装します。

Providerの各処理には`ctx`が渡されるため、Blackboard、Config、Mobなど、そのMobに必要な情報へアクセスできます。

Providerは特定のBehaviorに依存する必要がありません。

そのため、一つのProviderを複数のBehaviorから利用したり、Adapterによって異なるMethodから同じProviderの処理を利用したりできます。

### ProviderInstance

Providerを作成すると`ProviderInstance`が返されます。

### API

#### `engine.createProvider(ProviderName, ProviderMethods)`

Providerを作成します。

```luau
local provider = engine.createProvider("Move", {
	Move = function(ctx)
		-- Move
	end,
})
```

#### `engine:registerProvider(Provider)`

ProviderをEngineへ登録します。

```luau
engine:registerProvider(provider)
```

---

## Plugin

Pluginは、イベント駆動によってMobに**独自の機能や振る舞いを追加する拡張要素**です。

PluginはMethodやProviderとは異なり、MobEngineの基本的な行動処理から独立して、イベントを通じて外部システムと連携できます。

Pluginではイベント名と`ctx`を受け取る関数を定義し、`ctx.Plugin`からそのイベントを実行できます。

### PluginInstance

Pluginを作成すると`PluginInstance`が返されます。

### Events

#### `SendEventAsync(EventName, ...)`

イベントを**非同期**で実行します。

イベントの処理を待機せず、そのまま次の処理へ進みます。

#### `InvokeEvent(EventName, ...)`

イベントを**同期的**に実行します。

イベントの処理が完了するまで待機し、イベントから返された値を受け取ることができます。

---

## Component Flow

MobEngineの各Componentは、それぞれ独立して動作するのではなく、Engineによって管理されながら連携してMobの行動を構成します。

基本的な流れは以下のようになります。

![architecture](images/architecture.png)

より具体的には、BehaviorがMethodを実行し、AdapterがそのMethodをどのProviderの処理として実行するかを決定します。

Providerは選択された具体的な処理を`ctx`を利用して実行します。

`ctx`にはMobごとのBlackboard、Methods、Config、Mob、Pluginが含まれているため、それぞれの処理は現在操作しているMobに必要な情報へアクセスできます。

Pluginはこの基本的な処理とは独立してイベントを提供し、MobEngineの外部システムや独自機能との連携に利用できます。

この構造によって、**意思決定・抽象的な行動・具体的な処理・イベントによる拡張を分離しながら、それぞれをEngineによって一つのMobシステムとして管理できます。**

# Quick Start

ここでは、MobEngineを使用して簡単なMob AIを作成します。

今回は、以下のような単純なAIを作成します。

```text
Mob
 └─ Behavior
     ├─ Move()
     └─ Search()
```

Behaviorから抽象的なMethodを実行し、Adapterによって具体的なProviderの処理へ接続します。

## 1. Create Methods

まず、Behaviorから使用するMethodを作成します。

```luau
local Methods = {
	Move = MobEngine.createMethod("Move"),
	Search = MobEngine.createMethod("Search"),
}
```

ここで作成したMethodは、まだ具体的な処理を持っていません。

「Moveする」「Searchする」という**行動の意味だけ**を定義しています。

## 2. Create the Engine

BlackboardとMethodsを使用してEngineを作成します。

```luau
local Blackboard = {
	Target = nil,
}

local engine = MobEngine.createEngine(
	Blackboard,
	Methods
)
```

Engineは、作成した各Componentを管理します。

## 3. Create a Provider

次に、Methodの具体的な処理を実装するProviderを作成します。

```luau
local provider = engine.createProvider("Ground", {
	Move = function(ctx)
		print("Moving")
	end,

	Search = function(ctx)
		print("Searching")
	end,
})
```

Providerでは、実際にゲーム内で何をするのかを実装します。

## 4. Create an Adapter

次に、MethodとProviderの処理を接続するAdapterを作成します。

```luau
local adapter = engine.createAdapter("Ground", {
	[Methods.Move] = "Move",
	[Methods.Search] = "Search",
})
```

これにより、

```text
Methods.Move()
      ↓
Adapter
      ↓
Provider.Move()
```

という関係が作られます。

## 5. Register the Components

作成したProviderとAdapterをEngineへ登録します。

```luau
engine:registerProvider(provider)
engine:registerAdapter(adapter)
```

これでEngineがProviderとAdapterを利用できるようになります。

## 6. Create a Behavior

次に、Mobの意思決定を担当するBehaviorを作成します。

```luau
local behavior = engine.createBehavior(function(ctx)
	ctx.Methods.Search()
	ctx.Methods.Move()
end)
```

Behaviorでは具体的な処理を直接実装せず、Methodを使用してMobの行動を決定します。

## 7. Load the Behavior

作成したBehaviorをEngineへロードします。

```luau
engine:loadBehavior(behavior)
```

## 8. Create a Mob

最後にMobを作成します。

```luau
local mob = engine:createMob({
	Ground = nil,
})
```

これで、MobEngineによる基本的なMob AIが完成します。

## How It Works

このQuick Startで作成した処理は、以下のように繋がっています。

```text
Behavior
    │
    │ Search()
    │ Move()
    ▼
 Method
    │
    ▼
 Adapter
    │
    ▼
 Provider
    │
    ▼
具体的な処理
```

Behaviorは「何をするか」だけを決定し、Adapterがその要求をProviderの具体的な処理へ接続します。

この仕組みによって、Behaviorを変更せずにAdapterやProviderを変更したり、同じBehaviorを異なる環境のMobへ利用したりできます。


# Installation

1. GitHubから[`MobEngine.rbxm`](MobEngine.rbxm)をダウンロードし
2. ライブラリを入れたいRoblox Studioを開く
3. **「Robloxモデルをインポート」**から`MobEngine.rbxm`をインポートすれば完了

![Installation gif](images/howToDownload.gif)
