local Players = game:GetService("Players")

local MobEngine = require(path.to.MobEngine)

local Blackboard = {
	Target = nil :: Player?,
}

local Methods = {
	Search = MobEngine.createMethod("Search"),
	Move = MobEngine.createMethod("Move"),
}

local DefaultConfig = {
	SearchRange = 60,
}

local engine = MobEngine.createEngine(
	Blackboard,
	Methods,
	DefaultConfig
)

local GroundProvider = engine.createProvider(
	"Ground",
	{
		Walk = function(ctx, pos)
			ctx.Mob.Humanoid.WalkSpeed = ctx.Config.WalkSpeed or 12
			ctx.Mob.Humanoid:MoveTo(pos)
			ctx.Mob.Humanoid.MoveFinished:Wait()
		end,

		Run = function(ctx, pos)
			ctx.Mob.Humanoid.WalkSpeed = ctx.Config.RunSpeed or 18
			ctx.Mob.Humanoid:MoveTo(pos)
		end,
	}
)

local GroundAdapter = engine.createAdapter(
	"Ground",
	{
		[Methods.Move] = function(ctx)
			if ctx.Blackboard.Target then
				return "Run"
			end

			return "Walk"
		end,
	}
)

engine:registerProvider(GroundProvider)
engine:registerAdapter(GroundAdapter)

local SearchProvider = engine.createProvider(
	"Search",
	{
		Search = function(ctx)
			local min = ctx.Config.SearchRange
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

local behavior = engine.createBehavior(function(ctx)
	while task.wait(0.1) do
		ctx.Methods.Search()

		local pos =
			ctx.Blackboard.Target
			and ctx.Blackboard.Target.Character.PrimaryPart.Position
			or Vector3.new(
				math.random(-5, 5),
				ctx.Mob.RootPart.Position.Y,
				math.random(-5, 5)
			)

		ctx.Methods.Move(pos)
	end
end)

engine:loadBehavior(behavior)

local Model = path.to.model

local zombie = engine:createMob(
	Model,
	{ "Ground", "Search" },
	{}
)

zombie:Run()
