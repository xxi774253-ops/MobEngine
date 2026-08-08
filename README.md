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

## Behavior

BehaviorはMobEngineにおける意思決定を担当します。

### BehaviorInstance

Behaviorを作成すると`BehaviorInstance`が返されます。

```luau
type BehaviorInstance = {
	-- ...
}
```

### API

#### `engine.createBehavior()`

Behaviorを作成します。

```luau
local behavior = engine.createBehavior(function(ctx)
	-- Behavior
end)
```

### Example

```luau
-- ...
```

---

## Method

MethodはBehaviorなどから使用される、抽象的な行動を定義します。

### MethodInstance

Methodを作成すると`MethodInstance`が返されます。

```luau
type MethodInstance = {
	-- ...
}
```

### API

#### `MobEngine.createMethod()`

Methodを作成します。

```luau
local Move = MobEngine.createMethod("Move")
```

### Example

```luau
-- ...
```

---

## Adapter

AdapterはMethodで指定された抽象的な行動を、具体的な処理へ変換します。

### AdapterInstance

Adapterを作成すると`AdapterInstance`が返されます。

```luau
type AdapterInstance = {
	-- ...
}
```

### API

#### `engine.createAdapter()`

Adapterを作成します。

```luau
local adapter = engine.createAdapter("Move", {
	-- ...
})
```

#### `engine:registerAdapter()`

AdapterをEngineに登録します。

```luau
engine:registerAdapter(adapter)
```

### Example

```luau
-- ...
```

---

## Provider

Providerは具体的な処理を実際に実行します。

### ProviderInstance

Providerを作成すると`ProviderInstance`が返されます。

```luau
type ProviderInstance = {
	-- ...
}
```

### API

#### `engine.createProvider()`

Providerを作成します。

```luau
local provider = engine.createProvider("Move", {
	-- ...
})
```

#### `engine:registerProvider()`

ProviderをEngineに登録します。

```luau
engine:registerProvider(provider)
```

### Example

```luau
-- ...
```

---

## Plugin

Pluginはイベント駆動によってMobに独自の機能や振る舞いを追加します。

### PluginInstance

Pluginを作成すると`PluginInstance`が返されます。

```luau
type PluginInstance = {
	-- ...
}
```

### API

#### `engine.createPlugin()`

Pluginを作成します。

```luau
local plugin = engine.createPlugin({
	-- ...
})
```

### Events

#### `SendEventAsync()`

イベントを非同期で実行します。

```luau
ctx.Plugin.SendEventAsync("OnSomething")
```

#### `InvokeEvent()`

イベントを同期的に実行し、結果を受け取ります。

```luau
local result = ctx.Plugin.InvokeEvent("OnSomething")
```

### Example

```luau
-- ...
```

# Installation

1. GitHubから[`MobEngine.rbxm`](MobEngine.rbxm)をダウンロードし
2. ライブラリを入れたいRoblox Studioを開く
3. **「Robloxモデルをインポート」**から`MobEngine.rbxm`をインポートすれば完了

![Installation gif](images/howToDownload.gif)
