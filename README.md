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

MobEngineでは、以下の要素を中心にAIを構成します

* **Behavior**
  このライブラリにおける**意思決定**を行う要素

* **Method**
  Behaviorから使用される**抽象的な行動**を定義する要素

* **Adapter**
  Methodで指定された**抽象的な行動**を**具体的な処理**へ翻訳する、いわば「翻訳機」のような要素

* **Provider**
  Adapterによって選択された**具体的な処理**を実際に実行する要素

* **Plugin**
  イベント駆動によってモブに**独自の機能や振る舞い**を追加する拡張要素


![MobEngine Architecture](images/architecture.png)

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

`ctx`は、BehaviorやProviderなどがMobごとの情報へアクセスするためのContextです。

---

## Behavior

BehaviorはMobEngineにおける**意思決定**を担当します。

Behavior自身が具体的な処理を実装するのではなく、`ctx.Methods`に用意されたMethodを使用してMobに必要な行動を要求します。

そのため、Behaviorは「どのような行動をするか」を決定し、実際に「どのように実行するか」はMethod、Adapter、Providerへ委ねることができます。

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

Methodは具体的な処理を持つのではなく、「Moveする」「Searchする」「Attackする」といった**行動の意味そのもの**を表します。

例えば`Move`というMethodをBehaviorから実行した場合、Behaviorは「移動する」という要求だけを出します。

その要求を実際にどのような処理へ変換するかはAdapterが担当します。

この分離によって、Behavior側は移動方法や環境などの具体的な実装を意識する必要がありません。

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

Adapterでは、単純にMethodとProviderの処理を対応付けるだけでなく、関数を使用して状況に応じた処理を動的に決定することもできます。

そのため、同じMethodであっても、Mobの状態、環境、ターゲットなどに応じて異なるProviderの処理を実行できます。

例えば、同じ`Move()`というMethodでも、

* 地上なら`Walk`
* ターゲットを発見したら`Run`
* 水中なら`Swim`
* 空中なら`Fly`

のように、Adapter側で実行する処理を変更できます。

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

AdapterをEngineに登録します。

```luau
engine:registerAdapter(adapter)
```

---

## Provider

Providerは、Adapterによって選択された**具体的な処理を実際に実行する役割**を持ちます。

Providerはゲーム側の具体的なシステムとの接続点になります。

例えば移動を担当するProviderであれば、実際にHumanoidを動かしたり、飛行処理を行ったりする処理を実装します。

Providerの処理には`ctx`が渡されるため、Blackboard、Config、Mobなど、そのMobに必要な情報へアクセスできます。

Providerは特定のBehaviorに依存する必要がありません。

そのため、一つのProviderを複数のBehaviorから利用したり、Adapterによって異なるMethodから同じProviderの処理を利用したりできます。

### ProviderInstance

Providerを作成すると`ProviderInstance`が返されます。

### API

#### `engine.createProvider(ProviderName, ProviderMethods)`

Providerを作成します。

```luau
local provider = engine.createProvider("Move", {
	-- ProviderMethods
})
```

#### `engine:registerProvider(Provider)`

ProviderをEngineに登録します。

```luau
engine:registerProvider(provider)
```

---

## Plugin

Pluginは、イベント駆動によってMobに**独自の機能や振る舞いを追加する拡張要素**です。

PluginはMethodやProviderとは異なり、MobEngineの基本的な行動処理から独立して、イベントを通じて外部システムと連携できます。

`ctx.Plugin`からイベントを実行でき、イベントごとに任意の処理を登録できます。

### PluginInstance

Pluginを作成すると`PluginInstance`が返されます。

### Events

#### `SendEventAsync(EventName, ...)`

イベントを非同期で実行します。

呼び出した側はイベントの処理が完了するまで待機する必要がありません。

#### `InvokeEvent(EventName, ...)`

イベントを同期的に実行します。

イベントの処理が完了するまで待機し、イベント側から返された値を受け取ることができます。

---

# Component Flow

MobEngineの各Componentは、それぞれ独立して動作するのではなく、互いに連携してMobの行動を構成します。

基本的な処理の流れは以下のようになります。

```text
Behavior
   │
   │ Methodを実行
   ▼
Method
   │
   │ Adapterによって処理を決定
   ▼
Adapter
   │
   │ Providerの具体的な処理を選択
   ▼
Provider
   │
   │ ctxを使用して処理を実行
   ▼
Mob
```

各Componentは`ctx`を通して、そのMobに対応する情報へアクセスできます。

```text
                 ┌──────────────┐
                 │   Behavior   │
                 └──────┬───────┘
                        │
                   Methodを実行
                        │
                        ▼
                 ┌──────────────┐
                 │    Method   │
                 └──────┬───────┘
                        │
                   Adapterが変換
                        │
                        ▼
                 ┌──────────────┐
                 │   Adapter    │
                 └──────┬───────┘
                        │
                  処理を選択
                        │
                        ▼
                 ┌──────────────┐
                 │   Provider   │
                 └──────┬───────┘
                        │
                     ctxを使用
                        │
                        ▼
                 ┌──────────────┐
                 │     Mob      │
                 └──────────────┘

                        ▲
                        │
                 ┌──────┴───────┐
                 │    Plugin    │
                 │   Events     │
                 └──────────────┘
```

この構造によって、**意思決定・抽象的な行動・具体的な処理・拡張機能をそれぞれ分離したまま連携させることができます。**


# Installation

1. GitHubから[`MobEngine.rbxm`](MobEngine.rbxm)をダウンロードし
2. ライブラリを入れたいRoblox Studioを開く
3. **「Robloxモデルをインポート」**から`MobEngine.rbxm`をインポートすれば完了

![Installation gif](images/howToDownload.gif)
