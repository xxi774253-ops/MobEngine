MobEngine

Roblox向けのモジュール式・拡張可能なAIフレームワークです。

Contents

Features

Core Concepts

Components

Component Flow

Quick Start

Best Practices

API Reference

Examples

Installation

Features

このライブラリでは、主に以下の5つの機能を提供しています

柔軟な行動システムBehavior TreeやUtility AI、State Machineなど、自分の好きなAI方式をBehaviorとして実装可

抽象化された行動用関数Move()やSearch()などのMethodによって、AIの意思決定と実際の処理を分離

強力な挙動管理システム同じMethodでも、状況や環境に応じて実行する処理を柔軟に変更可

Luauの型サポートライブラリ内部で厳密な型定義を行っているため、Roblox Studio上で型推論や自動補完を活用可

高い拡張性モブAIだけでなく、NPC、武器、スキルなど、様々なゲームシステムへ応用が可能

Core Concepts

MobEngineでは、以下の要素を中心にAIを構成します。

EngineMobEngineの各コンポーネントを管理し、Mobの生成やBehavior、Provider、Adapterなどを統括する中核となる要素

Behaviorこのライブラリにおける意思決定を行う要素

MethodBehaviorから使用される抽象的な行動を定義する要素

AdapterMethodで指定された抽象的な行動を具体的な処理へ翻訳する、いわば「翻訳機」のような要素

ProviderAdapterによって選択された具体的な処理を実際に実行する要素

Pluginイベント駆動によってモブに独自の機能や振る舞いを追加する拡張要素

基本的な処理の流れは以下のようになります。

Behavior
   ↓
Method
   ↓
Adapter
   ↓
Provider
   ↓
Mob

Pluginはこの基本的な流れとは独立して、イベントを通じてMobへ機能を追加します。

Components

Core Conceptsで紹介した各コンポーネントについて、ここから詳しく解説します。

まず、これ以降の説明で多用するctxについて説明します。

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

ctxは、BehaviorやProviderなどが、そのMobに関連する情報へアクセスするためのContextです。

Engine

EngineはMobEngine全体を管理する中核となる要素です。

Blackboard、Methods、DefaultConfigをもとにEngineを作成し、ProviderやAdapterの登録、Behaviorのロード、Mobの生成など、MobEngineの主要な機能を管理します。

EngineInstance

Engineを作成するとEngineInstanceが返されます。

API

MobEngine.createEngine(Blackboard, Methods, DefaultConfig)

MobEngineのEngineを作成します。

local engine = MobEngine.createEngine(
	Blackboard,
	Methods,
	DefaultConfig
)

engine.createMethod(MethodName)

Methodを作成します。Engineから作成する場合、createEngine()に渡した型情報を利用できるため、Roblox Studio上で型推論や自動補完を活用できます。

MobEngine.createMethod()から作成することもできます。詳細はAPI Referenceを参照してください。

engine.createProvider(ProviderName, ProviderMethods)

Providerを作成します。

engine.createAdapter(AdapterName, Methods)

Adapterを作成します。

engine.createBehavior(Behavior)

Behaviorを作成します。

engine.createPlugin(Events)

PluginInstanceを作成します。

local plugin = engine.createPlugin({
	OnAttacked = function(ctx)
		-- イベント処理
	end,
})

engine:registerProvider(Provider)

ProviderをEngineへ登録します。

engine:registerAdapter(Adapter)

AdapterをEngineへ登録します。

engine:loadBehavior(Behavior)

BehaviorをEngineへロードします。

engine:createMob(Model, Providers, Config, Plugin)

設定したProvider、Config、Pluginなどを使用してMobを生成します。

Behavior

BehaviorはMobEngineにおける意思決定を担当します。

Behavior自身が具体的な処理を実装するのではなく、ctx.Methodsに用意されたMethodを使用してMobに必要な行動を要求します。

そのため、Behaviorは「何をするか」を決定し、「どのように実行するか」はMethod、Adapter、Providerへ委ねることができます。

Behaviorの実装方法は限定されていません。

Behavior Tree、Utility AI、State Machineなど、様々なAI方式をBehaviorとして実装できます。

BehaviorInstance

Behaviorを作成するとBehaviorInstanceが返されます。

API

engine.createBehavior(Behavior)

Behaviorを作成します。

local behavior = engine.createBehavior(function(ctx)
	-- Behavior
end)

engine:loadBehavior(Behavior)

作成したBehaviorをEngineへロードします。

engine:loadBehavior(behavior)

Method

MethodはBehaviorなどから使用される、抽象的な行動を定義します。

Methodは具体的な処理を直接持つのではなく、「Moveする」「Searchする」「Attackする」といった行動そのものを表します。

BehaviorはMethodを通して行動を要求するため、具体的な実装を意識する必要がありません。

Methodが実際にどのような処理として実行されるかは、AdapterとProviderによって決定されます。

MethodInstance

Methodを作成するとMethodInstanceが返されます。

API

MobEngine.createMethod(MethodName)

Methodを作成します。

local Move = MobEngine.createMethod("Move")

MethodはMobEngine.createMethod()とengine.createMethod()のどちらからでも作成できます。Engineから作成した場合は、Engineに渡した型情報を利用できるため、Roblox Studio上で型補完を活用できます。

Adapter

Adapterは、Methodで指定された抽象的な行動を具体的な処理へ変換する役割を持ちます。

BehaviorがMethodを実行すると、AdapterはそのMethodに対応するProviderの処理を決定します。

AdapterにはProviderのMethodを直接指定することも、関数を使用して状況に応じた処理を動的に決定することもできます。

そのため、同じMethodでもMobの状態や環境などに応じて異なる処理を実行できます。

例えばMove()という同じMethodでも、

地上     → Walk
敵を発見 → Run
水中     → Swim
空中     → Fly

のようにAdapter側で実行する処理を変更できます。

Adapterは、BehaviorとProviderを直接結び付けず、その間を抽象化する重要な層として機能します。

AdapterInstance

Adapterを作成するとAdapterInstanceが返されます。

API

engine.createAdapter(AdapterName, Methods)

Adapterを作成します。

local adapter = engine.createAdapter("Move", {
	-- Methods
})

engine:registerAdapter(Adapter)

AdapterをEngineへ登録します。

engine:registerAdapter(adapter)

Provider

Providerは、Adapterによって選択された具体的な処理を実際に実行する役割を持ちます。

Providerはゲーム側の具体的なシステムとの接続点になります。

例えば移動を担当するProviderであれば、Humanoidを動かしたり、飛行処理を行ったりする実際の処理を実装します。

Providerの各処理にはctxが渡されるため、Blackboard、Config、Mobなど、そのMobに必要な情報へアクセスできます。

Providerは特定のBehaviorに依存する必要がありません。

そのため、一つのProviderを複数のBehaviorから利用したり、Adapterによって異なるMethodから同じProviderの処理を利用したりできます。

ProviderInstance

Providerを作成するとProviderInstanceが返されます。

API

engine.createProvider(ProviderName, ProviderMethods)

Providerを作成します。

local provider = engine.createProvider("Move", {
	Move = function(ctx)
		-- Move
	end,
})

engine:registerProvider(Provider)

ProviderをEngineへ登録します。

engine:registerProvider(provider)

Plugin

Pluginは、イベント駆動によってMobに独自の機能や振る舞いを追加する拡張要素です。

PluginはMethodやProviderとは異なり、MobEngineの基本的な行動処理から独立して、イベントを通じて外部システムと連携できます。

Pluginではイベント名とctxを受け取る関数を定義し、ctx.Pluginからそのイベントを実行できます。

PluginInstance

Pluginを作成するとPluginInstanceが返されます。

API

engine.createPlugin(Events)

Pluginを作成します。

local plugin = engine.createPlugin({
	OnAttacked = function(ctx)
		-- イベント処理
	end,
})

PluginはMobEngine.createPlugin()から作成することもできます。Engineから作成する場合は、Engineの型情報を利用できます。

Events

SendEventAsync(EventName, ...)

イベントを非同期で実行します。

イベントの処理を待機せず、そのまま次の処理へ進みます。

InvokeEvent(EventName, ...)

イベントを同期的に実行します。

イベントの処理が完了するまで待機し、イベントから返された値を受け取ることができます。

Component Flow

MobEngineの各Componentは、それぞれ独立して動作するのではなく、Engineによって管理されながら連携してMobの行動を構成します。

基本的な流れは以下のようになります。



より具体的には、BehaviorがMethodを実行し、AdapterがそのMethodをどのProviderの処理として実行するかを決定します。

Providerは選択された具体的な処理をctxを利用して実行します。

ctxにはMobごとのBlackboard、Methods、Config、Mob、Pluginが含まれているため、それぞれの処理は現在操作しているMobに必要な情報へアクセスできます。

Pluginはこの基本的な処理とは独立してイベントを提供し、MobEngineの外部システムや独自機能との連携に利用できます。

この構造によって、意思決定・抽象的な行動・具体的な処理・イベントによる拡張を分離しながら、それぞれをEngineによって一つのMobシステムとして管理できます。

Quick Start

ここでは、MobEngineを使用して簡単なMob AIを作成します。

今回作成するMobは、Search()を実行してターゲットを探し、その後Move()を実行します。

また、Mobごとに異なるConfigを設定し、Providerからその値を利用します。

1. Create the Blackboard

まず、Mobごとに保持するデータであるBlackboardを定義します。

local Blackboard = {
	Target = nil :: Model?,
}

Blackboardは、Mobの行動中に変化するランタイムデータなどを保持するために使用します。

2. Create Methods

次に、Behaviorから使用する抽象的な行動を作成します。

local Methods = {
	Move = MobEngine.createMethod("Move"),
	Search = MobEngine.createMethod("Search"),
}

この時点では、Move()やSearch()が具体的に何をするのかは決まっていません。

Methodはあくまで「何をするか」を表します。

3. Create the Engine

Blackboard、Methods、DefaultConfigを使用してEngineを作成します。

local DefaultConfig = {
	MoveSpeed = 10,
}

local engine = MobEngine.createEngine(
	Blackboard,
	Methods,
	DefaultConfig
)

DefaultConfigには、すべてのMobに適用するデフォルトの設定を定義できます。

4. Create a Provider

次に、Methodの具体的な処理を実装するProviderを作成します。

local provider = engine.createProvider("Ground", {
	Move = function(ctx)
		print("MoveSpeed:", ctx.Config.MoveSpeed)
	end,

	Search = function(ctx)
		print("Searching...")
	end,
})

Providerでは、実際にゲーム内で何をするのかを実装します。

ここではctx.Config.MoveSpeedを使用して、Mobの設定値を取得しています。

5. Create an Adapter

次に、MethodとProviderの処理を接続するAdapterを作成します。

local adapter = engine.createAdapter("Ground", {
	[Methods.Move] = "Move",
	[Methods.Search] = "Search",
})

これにより、Behaviorから実行されたMethodがProviderの対応する処理へ接続されます。

Methods.Move()
      ↓
   Adapter
      ↓
Provider.Move(ctx)

6. Register the Provider and Adapter

作成したProviderとAdapterをEngineへ登録します。

engine:registerProvider(provider)
engine:registerAdapter(adapter)

これでEngineがProviderとAdapterを利用できるようになります。

7. Create a Behavior

次に、Mobの意思決定を担当するBehaviorを作成します。

local behavior = engine.createBehavior(function(ctx)
	ctx.Methods.Search()
	ctx.Methods.Move()
end)

Behaviorでは具体的な処理を直接実装せず、Methodを使用してMobの行動を決定します。

8. Load the Behavior

作成したBehaviorをEngineへロードします。

engine:loadBehavior(behavior)

9. Create a Mob

最後にMobを作成します。

local mob = engine:createMob(
	mobModel,
	{"Ground"},
	{
		MoveSpeed = 20,
	},
	{}
)

ここではMoveSpeedを20に設定しています。

そのため、このMobのProviderからctx.Config.MoveSpeedを取得すると20になります。

このように、DefaultConfigを設定しつつ、Mobごとに異なるConfigを持たせることができます。

How It Works

今回作成したMobの処理は、以下のように繋がっています。

                    Engine
                      │
              ┌───────┴───────┐
              │               │
          Behavior          Config
              │               │
              ▼               │
           Method             │
              │               │
              ▼               │
           Adapter             │
              │               │
              ▼               │
           Provider ◄──────────┘
              │
              ▼
             Mob

BehaviorはMove()やSearch()という抽象的なMethodを実行します。

Adapterは、そのMethodをProviderの具体的な処理へ接続します。

Providerはctxを通して、そのMob固有のConfigやBlackboard、Mobなどへアクセスしながら実際の処理を実行します。

このようにMobEngineでは、

「何をするか」

をBehaviorとMethodで決定し、

「どう実行するか」

をAdapterとProviderで決定します。

さらにConfigによって、同じBehavior・Method・Providerを使用しながら、Mobごとに異なる設定を与えることができます。

Best Practices

MobEngineでは、Behavior・Method・Adapter・Providerを適切に分離することで、柔軟で再利用性の高いシステムを構築できます。

ここでは、MobEngineを使用する上で推奨される設計方法を紹介します。

Keep Methods Abstract

Methodは、できるだけ抽象的な行動として定義することを推奨します。

例えば、

ctx.Methods.Move()
ctx.Methods.Search()
ctx.Methods.Do()

のように、「何をするか」を表現します。

一方で、

ctx.Methods.Walk()
ctx.Methods.Run()
ctx.Methods.Swim()

のように具体的な処理までMethodとして分けてしまうと、Behaviorが特定の実装に依存しやすくなります。

Methodを抽象化することで、同じBehaviorを異なる環境やMobへ再利用できます。

Let Adapters Handle Context

Methodの具体的な処理を決定する必要がある場合は、Adapterを活用します。

例えば、Behaviorが

ctx.Methods.Move()

を実行するとします。

Adapter側で状況を判断することで、

Move()
   │
   ▼
Adapter
   ├── 水中       → Swim
   ├── ターゲットあり → Run
   └── 通常       → Walk

のように、同じMethodでも状況に応じて実行する処理を変更できます。

この方法では、Behavior側が「水中か」「ターゲットがいるか」といった具体的な環境判断をする必要がありません。

そのため、意思決定と環境依存の処理を分離できます。

Keep Providers Focused

Providerでは、実際にゲーム内で行う具体的な処理に集中させることを推奨します。

例えばMoveProviderであれば、実際の移動処理を担当します。

Behavior
    ↓
Method
    ↓
Adapter
    ↓
Provider
    ↓
Roblox / Game System

Behaviorに直接Roblox APIを記述するのではなく、Providerへ具体的な処理を集約することで、コードの責任範囲を明確にできます。

また、Providerを分離することで、同じMethodを異なる実装へ接続できます。

Reuse Behaviors

Behaviorは、可能な限り特定のProviderや環境に依存しないように設計することを推奨します。

例えば、以下のようなBehaviorを考えます。

local behavior = engine.createBehavior(function(ctx)
	ctx.Methods.Search()
	ctx.Methods.Move()
end)

このBehaviorは「SearchしてMoveする」という意思決定だけを行っています。

どのような対象をSearchするのか、どのようにMoveするのかはAdapterやProviderに任せることができます。

そのため、同じBehaviorを異なるMobや異なる環境で再利用できます。

Use Adapters to Change Behavior Without Changing Behaviors

MobEngineでは、Adapterを変更することでBehaviorそのものを変更せずにMobの性質を変えることができます。

例えば、同じSearch()を使用していても、

Search()
   │
   ▼
Adapter
   ├── 敵対Provider → 敵を検索
   └── 友好Provider → 味方を検索

のように、Providerを切り替えることで異なる対象を検索できます。

同様に、

Do()
   │
   ▼
Adapter
   ├── 敵 → Attack
   └── 味方 → Heal

とすることもできます。

このように、Behaviorを変更せずにAdapterやProviderを変更することで、同じBehaviorから異なる性質のMobを構築できます。

Use Plugins for Independent Features

Mobの基本的な行動処理とは独立した機能には、Pluginの利用を推奨します。

Pluginではイベントを通して独自の機能を追加できます。

ctx.Plugin.SendEventAsync("OnInWater")

のようにイベントを発生させることで、BehaviorやProviderとは独立した処理を実行できます。

例えば、環境に入ったときのエフェクト、サウンド、ゲーム固有のイベントなど、MobEngineの基本的な行動システムに直接含める必要のない処理に適しています。

Separate Decision From Execution

MobEngineでは、

「何をするか」と「どうやってするか」を分離する

ことが重要です。

┌──────────────┐
│   Behavior   │
│  意思決定    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Method    │
│ 抽象的な行動 │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Adapter    │
│   処理を選択 │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Provider   │
│ 具体的な処理 │
└──────────────┘

この分離を意識することで、Behaviorの再利用性を高めながら、AdapterやProviderによってゲーム固有の処理を柔軟に組み合わせることができます。

MobEngineの柔軟性を活かすためにも、それぞれのComponentに明確な責任を持たせることを推奨します。

API Reference

MobEngineが提供する主要なAPIについて説明します。

MobEngine

MobEngineからは、Engineの型情報を必要としないコンポーネントを作成できます。

createMethod()、createProvider()、createAdapter()、createBehavior()、createPlugin()は、MobEngineとEngineのどちらからでも作成できます。

Engineから作成した場合は、createEngine()に渡したBlackboard、Methods、DefaultConfigなどの型情報を利用できるため、Roblox Studio上でより正確な型推論や自動補完を活用できます。

MobEngine.createMethod(MethodName)

抽象的な行動を定義し、MethodInstanceを作成します。

local Move = MobEngine.createMethod("Move")

MobEngine.createProvider(ProviderName, ProviderMethods)

ProviderInstanceを作成します。

local provider = MobEngine.createProvider("Ground", {
	Move = function(ctx, pos)
		-- 実際の処理
	end,
})

MobEngine.createAdapter(AdapterName, Methods)

AdapterInstanceを作成します。

local adapter = MobEngine.createAdapter("Ground", {
	[Methods.Move] = "Move",
})

MobEngine.createBehavior(Behavior)

BehaviorInstanceを作成します。

local behavior = MobEngine.createBehavior(function(ctx)
	-- 意思決定
end)

MobEngine.createPlugin(Events)

PluginInstanceを作成します。

local plugin = MobEngine.createPlugin({
	OnAttacked = function(ctx)
		-- イベント処理
	end,
})

MobEngine.createEngine(Blackboard, Methods, DefaultConfig)

MobEngineのEngineInstanceを作成します。

local engine = MobEngine.createEngine(
	Blackboard,
	Methods,
	DefaultConfig
)

Engine

Engineは、Provider・Adapter・Behavior・Pluginを管理し、Mobを生成します。

engine.createMethod(MethodName)

MethodInstanceを作成します。Engineから作成することで、Engineに紐づいた型情報を利用できます。

local Move = engine.createMethod("Move")

engine.createProvider(ProviderName, Methods)

ProviderInstanceを作成します。

local provider = engine.createProvider(
	"Ground",
	{
		Move = function(ctx, pos)
			-- 実際の処理
		end,
	}
)

engine.createAdapter(AdapterName, Methods)

AdapterInstanceを作成します。

local adapter = engine.createAdapter(
	"Ground",
	{
		[Methods.Move] = "Move",
	}
)

engine.createBehavior(Behavior)

BehaviorInstanceを作成します。

local behavior = engine.createBehavior(function(ctx)
	-- 意思決定
end)

engine.createPlugin(Events)

PluginInstanceを作成します。

local plugin = engine.createPlugin({
	OnAttacked = function(ctx)
		-- イベント処理
	end,
})

engine:registerProvider(Provider)

ProviderをEngineに登録します。

engine:registerProvider(provider)

engine:registerAdapter(Adapter)

AdapterをEngineに登録します。

engine:registerAdapter(adapter)

engine:loadBehavior(Behavior)

BehaviorをEngineに読み込みます。

engine:loadBehavior(behavior)

engine:createMob(Model, Providers, Config, Plugin)

指定したModelからMobInstanceを作成します。

local mob = engine:createMob(
	Model,
	{ "Ground", "Search", "Melee" },
	{
		Damage = 20,
	},
	plugin
)

Parameters

引数

説明

Model

Mobとして使用するModel

Providers

使用するProvider名の配列

Config

個体ごとのConfig

Plugin

個体に追加するPlugin

ConfigとPluginは必要に応じて指定できます。

MobInstance

mob:Run()

Mobに読み込まれたBehaviorを実行します。

mob:Run()

Context

Behavior・Provider・Pluginなどから使用できるctxには、Mobの実行に必要な情報が格納されています。

ctx = {
	Blackboard = {},
	Methods = {},
	Config = {},
	Mob = {},
	Plugin = {},
}

ctx.Blackboard

Mobごとに保持されるランタイムデータです。

ctx.Blackboard.Target

ctx.Methods

Behaviorなどから使用するMethodInstanceの集合です。

ctx.Methods.Move(position)
ctx.Methods.Attack()

ctx.Config

MobごとのConfigです。

ctx.Config.Damage
ctx.Config.AttackRange

ctx.Mob

現在のMobに関する情報です。

ctx.Mob.Model
ctx.Mob.Humanoid
ctx.Mob.RootPart

ctx.Plugin

Pluginのイベントを実行するためのAPIです。

ctx.Plugin.SendEventAsync(EventName, ...)

イベントを非同期で実行します。

ctx.Plugin.SendEventAsync("OnSomething")

ctx.Plugin.InvokeEvent(EventName, ...)

イベントを同期的に実行し、結果を受け取ります。

local result = ctx.Plugin.InvokeEvent("OnSomething")

Examples

ここでは、MobEngineを使用して実現できる代表的な構成を紹介します。

これらはあくまで一例であり、MobEngineではAdapterやProviderなどを組み合わせることで、様々なシステムを構築できます。

Context-dependent Actions

同じMethodでも、状況に応じて異なる処理を実行できます。

例えば、BehaviorからMove()を実行した場合でも、Adapterによって現在の状況を判断し、実際の処理を変更できます。

Move()
   │
   ▼
Adapter
   ├── 通常時       → Walk
   ├── 敵を発見     → Run
   ├── 水中         → Swim
   └── 空中         → Fly

Behaviorは「移動する」という意思決定だけを行い、移動方法そのものには依存しません。

Different Behaviors With the Same Methods

同じMethodを使用しながら、ProviderやAdapterを変更することで、異なる性質のMobを構築できます。

例えばSearch()というMethodを使用する場合でも、

Search()
   │
   ▼
Adapter
   ├── Enemy Provider → 敵を検索
   └── Ally Provider  → 味方を検索

のように、対象に応じて検索処理を変更できます。

そのため、同じBehaviorを使用していても、敵対するMobと友好的なMobで異なる行動を実現できます。

Abstract Actions

より抽象的なMethodを定義することで、同じ行動要求から異なる処理を実行できます。

例えばDo()というMethodを定義した場合、

Do()
   │
   ▼
Adapter
   ├── 敵に対して → Attack
   └── 味方に対して → Heal

のように、対象や状況に応じて実行する処理を変更できます。

このようにMethodを具体的な処理から切り離すことで、Behaviorを変更せずにMobの役割や性質を変更できます。

Event-driven Extensions

Pluginを使用することで、MobEngineの基本的な行動システムとは独立した機能を追加できます。

例えば、水中に入ったことをイベントとして扱う場合、

OnInWater
   │
   ▼
Plugin
   ├── VFX
   ├── SFX
   └── Game-specific Logic

のように、イベントを起点として様々な処理を実行できます。

SendEventAsync()とInvokeEvent()を使い分けることで、非同期・同期のどちらにも対応できます。

Multiple Provider Implementations

同じMethodでも、Providerを変更することで異なるシステムへ接続できます。

例えばProjectileProviderを用意した場合、

Method
   │
   ▼
Adapter
   │
   ▼
ProjectileProvider
   ├── Projectile A
   ├── Projectile B
   └── Projectile C

のように、ゲーム側の具体的なシステムに合わせてProviderを構成できます。

Providerを分離することで、Behaviorを変更することなく、実際の処理だけを差し替えることができます。

Combining Components

MobEngineの各Componentは単独で使用するものではなく、組み合わせることでより複雑なシステムを構築できます。

例えば、

                  Behavior
                     │
                     ▼
                   Method
                     │
                     ▼
                  Adapter
                ┌────┴────┐
                ▼         ▼
             Provider   Provider
                │         │
                └────┬────┘
                     ▼
                    Mob
                     ▲
                     │
                  Plugin

のように、複数のProviderやAdapterを組み合わせることができます。

MobEngineでは、Behaviorの意思決定、Methodによる抽象化、Adapterによる処理の選択、Providerによる具体的な実装、Pluginによる拡張を組み合わせることで、ゲームに合わせた柔軟なシステムを構築できます。

ここからは、MobEngineを使って構築した具体的な例を紹介します。

Example: Basic Zombie AI

この例では、MobEngineを使用してシンプルなゾンビAIを構築します。

このゾンビは、一定間隔でプレイヤーを検索し、ターゲットが存在する場合は走って追跡し、存在しない場合は歩いて移動します。

この例では、以下の仕組みを組み合わせています。

Behavior — AIのループと意思決定

Method — Search()とMove()による抽象化

SearchProvider — プレイヤーの検索処理

SearchAdapter — Search()と検索処理の接続

GroundProvider — Walk / Runの具体的な移動処理

GroundAdapter — ターゲットの有無によるWalk / Runの切り替え

Blackboard — ターゲットの保持

Config — 検索範囲や移動速度などの設定

ZombieBehavior

How It Works

この例で重要なのは、BehaviorがWalkやRunを直接判断していないことです。

Behaviorは、

Search()
Move()

という抽象的な行動だけを要求しています。

Search()ではSearchAdapter / SearchProviderによってプレイヤーを検索し、その結果をBlackboardへ保存します。

その後Move()が実行されると、GroundAdapterがBlackboardを確認し、

Targetあり  → Run
Targetなし  → Walk

と実行するProviderの処理を決定します。

そのため、Behaviorを変更することなく、Adapter側の実装を変更するだけで、

Targetあり  → Run
Targetなし  → Walk

から、

Targetあり  → Attack
Targetなし  → Patrol

のように、Mobの具体的な挙動を変更することもできます。

このようにMobEngineでは、Behaviorによる意思決定と、Adapter / Providerによる具体的な処理を分離できます。

Example 2: Combat Wolf

Example 1のZombie AIを発展させ、攻撃行動を追加したWolfを構築します。

この例では、基本的なSearch()とMove()に加えて、Attack()というMethodとMeleeProviderを追加しています。

What This Example Demonstrates

複数のMethodを組み合わせたAI

攻撃処理をProviderとして分離

AttackRangeによる攻撃可能範囲の設定

AttackCooldownによる攻撃間隔の設定

Damageによる攻撃力の設定

ConfigによるMobごとの設定

WolfBehavior

Behaviorでは、まずSearch()によってターゲットを探します。

ターゲットが存在する場合、その位置へMove()し、その後Attack()を実行します。

Search()
   │
   ▼
Blackboard.Target
   │
   ├── Targetなし
   │      ↓
   │   Move()
   │
   └── Targetあり
          │
          ├── Move(TargetPosition)
          │
          └── Attack()
                 │
                 ▼
            MeleeProvider
                 │
          ┌──────┴──────┐
          ▼             ▼
     AttackRange   AttackCooldown
          │             │
          └──────┬──────┘
                 ▼
              Damage

Example 1では移動だけだったBehaviorに、攻撃という新しい行動を追加しています。

それでもBehaviorは具体的な攻撃処理を直接実装せず、Attack()というMethodを呼び出すだけです。

これにより、攻撃方法を変更する場合でもBehaviorを変更する必要がありません。

Example 3: Plugin Werewolf

Example 2のCombat Wolfをさらに発展させ、Pluginによる独自処理を追加したWerewolfを構築します。

基本的なAI構造はWolfと同じですが、攻撃成功時にOnAttackedイベントを発生させ、Plugin側で追加の処理を実行します。

What This Example Demonstrates

PluginによるMob固有の機能追加

ProviderからPluginへのイベント通知

InvokeEvent()による同期イベント

個体ごとのConfig変更

共通のAI構造から異なるMobを作成

WerewolfBehavior

攻撃処理が成功すると、MeleeProviderからOnAttackedイベントを発生させます。

MeleeProvider
      │
      │ InvokeEvent("OnAttacked")
      ▼
    Plugin
      │
      ▼
 OnAttacked
      │
      └── Werewolf-specific behavior

さらにWerewolfでは、Wolfと同じProviderやBehaviorを使用しながら、Configを変更しています。

Wolf
├── Speed = 20
└── Default Attack Config

Werewolf
├── Damage = 60
├── AttackRange = 10
├── AttackCooldown = 5
└── Plugin
     └── OnAttacked

このように、MobEngineでは共通のAIシステムを再利用しながら、ConfigやPluginを組み合わせることで個体ごとの特徴を追加できます。

BehaviorやProviderを作り直すことなく、同じシステムから異なる性質を持つMobを構築できます。

Installation

GitHubからMobEngine.rbxmをダウンロードします。

ライブラリを導入したいRoblox Studioを開きます。

**「Robloxモデルをインポート」**からMobEngine.rbxmをインポートします
