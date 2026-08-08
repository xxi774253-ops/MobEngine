local Players = game:GetService("Players")

local MobEngine = require(path.to.MobEngine)

local Blackboard = {
	Target = nil :: Player?,
	currentCooldown = 0,
}

local Methods = {
	Search = MobEngine.createMethod("Search"),
	Move = MobEngine.createMethod("Move"),
	Attack = MobEngine.createMethod("Attack"),
}

local DefaultConfig = {
	AttackRange = 8,
	AttackCooldown = 0.5,
	Damage = 10,
}

local engine = MobEngine.createEngine(
	Blackboard,
	Methods,
	DefaultConfig
)

local GroundProvider = engine.createProvider(
	"Ground",
	{
		Move = function(ctx, pos)
			ctx.Mob.Humanoid.WalkSpeed = ctx.Config.WalkSpeed or 12
			ctx.Mob.Humanoid:MoveTo(pos)
		end,
	}
)

local GroundAdapter = engine.createAdapter(
	"Ground",
	{
		[Methods.Move] = "Move",
	}
)

engine:registerProvider(GroundProvider)
engine:registerAdapter(GroundAdapter)

local SearchProvider = engine.createProvider(
	"Search",
	{
		Search = function(ctx)
			local min = math.huge
			local target = nil

			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character or player.CharacterAdded:Wait()

				if not char then
					continue
				end

				local rootPart = char.PrimaryPart

				if not rootPart then
					continue
				end

				local dist = (
					ctx.Mob.RootPart.Position - rootPart.Position
				).Magnitude

				if dist < min then
					min = dist
					target = player
				end
			end

			ctx.Blackboard.Target = target
		end,
	}
)

local SearchAdapter = engine.createAdapter(
	"Search",
	{
		[Methods.Search] = "Search",
	}
)

engine:registerProvider(SearchProvider)
engine:registerAdapter(SearchAdapter)

local MeleeProvider = engine.createProvider(
	"Melee",
	{
		Melee = function(ctx)
			if os.clock() - ctx.Blackboard.currentCooldown
				< ctx.Config.AttackCooldown then
				return
			end

			local target = ctx.Blackboard.Target

			if not target then
				return
			end

			local character = target.Character

			if not character then
				return
			end

			local rootPart = character.PrimaryPart

			if not rootPart then
				return
			end

			if (
				ctx.Mob.RootPart.Position - rootPart.Position
			).Magnitude > ctx.Config.AttackRange then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				return
			end

			humanoid:TakeDamage(ctx.Config.Damage)
      ctx.Plugin.InvokeEvent("OnAttacked")

			ctx.Blackboard.currentCooldown = os.clock()
		end,
	}
)

local MeleeAdapter = engine.createAdapter(
	"Melee",
	{
		[Methods.Attack] = "Melee",
	}
)

engine:registerProvider(MeleeProvider)
engine:registerAdapter(MeleeAdapter)

local behavior = engine.createBehavior(function(ctx)
	while task.wait(0.1) do
		ctx.Methods.Search()

		local target = ctx.Blackboard.Target

		if target then
			local character = target.Character
			local rootPart = character and character.PrimaryPart

			if rootPart then
				ctx.Methods.Move(rootPart.Position)
				ctx.Methods.Attack()
			end
		else
			ctx.Methods.Move(Vector3.zero)
		end
	end
end)

engine:loadBehavior(behavior)

local Model = path.to.model

local Plugin = engine.createPlugin({
  OnAttacked = function(ctx)
      task.wait(1.5)
  end
})

local werewolf = engine:createMob(
	Model,
	{ "Ground", "Search", "Melee" },
	{},
  Plugin
)

werewolf:Run()
