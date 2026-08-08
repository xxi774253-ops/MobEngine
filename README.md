# MobEngine

A modular and extensible AI framework for Roblox.

# Features

このライブラリでは、主に5つのような機能を提供しています

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
