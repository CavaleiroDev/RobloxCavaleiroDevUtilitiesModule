local module = {}

local BadgeService = game:GetService("BadgeService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService("RunService")

local ErrorsModule = require(script.ErrorsModule)

function module.GetIndexInTable(val, tab)
	if typeof(tab) ~= "table" then warn(string.format(ErrorsModule[404], "GetIndexInTable", 2, "Table", typeof(tab))) return end
	for i, v in pairs(tab) do
		if v == val then return i end
		if i == #tab then return nil end
	end
end

function module.AwardBadge(BadgeId, plr)
	if typeof(BadgeId) ~= "number" then warn(string.format(ErrorsModule[404], "AwardBadge", 1, "numero", typeof(BadgeId))) return end
	if typeof(plr) == "number" or typeof(plr) == "Instance" then else warn(string.format(ErrorsModule[404], "AwardBadge", 2, "numero ou Instancia", typeof(plr))) return end
	if typeof(plr) == "Instance" and not plr:IsA("Player") then warn(string.format(ErrorsModule[405], "AwardBadge", plr.Name.." Não é um jogador")) return end
	local success, badgeInfo = pcall(function()
		return BadgeService:GetBadgeInfoAsync(BadgeId)
	end)
	if success then
		if badgeInfo.IsEnabled then
			local awarded, errorMessage = pcall(function()
				if typeof(plr) == "Instance" and plr:IsA("Player") then
					BadgeService:AwardBadge(plr.UserId, BadgeId)
				end
				if typeof(plr) == "number" then
					BadgeService:AwardBadge(plr, BadgeId)
				end	
			end)
			if awarded then
			else
				warn(string.format(ErrorsModule[405], "AwardBadge", "Erro ao conceder a badge: "..errorMessage))
				--warn(string.format(ErrorsModule[406], "AwardBadge", errorMessage))
			end
		end
	else
		warn(string.format(ErrorsModule[405], "AwardBadge", "Erro ao obter as informações da badge!"))
	end
end

function module.GetAllPlayerTools(plr)
	if typeof(plr) ~= "Instance" then warn(string.format(ErrorsModule[404], "GetAllPlayerTools", 1, "Instancia", typeof(plr))) return {} end
	if plr:IsA("Player") or plr:IsA("Model") then else warn(string.format(ErrorsModule[404], "GetAllPlayerTools", "Player ou Model", typeof(plr))) return {} end
	local toolsTable = {}
	if plr:IsA("Player") then
		if plr.Character == nil then
			plr.CharacterAdded:Wait()
		end
	end
	if plr:IsA("Model") then
		if game.Players:GetPlayerFromCharacter(plr) == nil then warn(string.format(ErrorsModule[405], "GetAllPlayerTools", plr.Name.."Não é um jogador")) return {} end
		plr = game.Players:GetPlayerFromCharacter(plr)
	end
	for i, v in pairs(plr:WaitForChild("Backpack"):GetChildren()) do
		if v:IsA("Tool") then
			toolsTable[#toolsTable+1] = v
		end
	end
	for i, v in pairs(plr.Character:GetChildren()) do
		if v:IsA("Tool") then
			toolsTable[#toolsTable+1] = v
		end
	end
	return toolsTable
end

function module.UserOwnsGamePass(GamepassId, plr)
	if typeof(GamepassId) ~= "number" then warn(string.format(ErrorsModule[404], "UserOwnsGamePass", 1, "numero", typeof(GamepassId))) return end
	if typeof(plr) == "number" or typeof(plr) == "Instance" then else warn(string.format(ErrorsModule[404], "UserOwnsGamePass", 2, "numero ou Instancia", typeof(plr))) return end
	if typeof(plr) == "Instance" and not plr:IsA("Player") then warn(string.format(ErrorsModule[405], "UserOwnsGamePass", plr.Name.." Não é um jogador")) return end
	local hasPass = false
	local success, message = pcall(function()
		if typeof(plr) == "Instance" and plr:IsA("Player") then
			hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, GamepassId)
		end
		if typeof(plr) == "number" then
			hasPass = MarketplaceService:UserOwnsGamePassAsync(plr, GamepassId)
		end	
	end)
	if success then
		return hasPass
	else
		warn(string.format(ErrorsModule[405], "UserOwnsGamePass", "Erro enquanto checava se o jogador tem a gamepass: "..tostring(message) ))
		--warn("Error while checking if player has pass: " .. tostring(message))
		return
	end
end

function module.GetAccountAgeInYears(plr)
	if typeof(plr) ~= "Instance" then warn(string.format(ErrorsModule[404], "GetAccountAgeInYears", 1, "Instancia", typeof(plr))) return end
	if not plr:IsA("Player") then warn(string.format(ErrorsModule[405], "GetAccountAgeInYears", plr.Name.." Não é um jogador")) return end
	return math.floor(plr.AccountAge/365 * 1)/1
end

function module.PlayerIsOnTeam(plr, team)
	if typeof(plr) ~= "Instance" then warn(string.format(ErrorsModule[404], "PlayerIsOnTeam", 1, "Instancia", typeof(plr))) return end
	if typeof(plr) == "Instance" and not plr:IsA("Player") then warn(string.format(ErrorsModule[405], "PlayerIsOnTeam", plr.Name.." Não é um jogador")) return end
	if typeof(team) == "BrickColor" or typeof(team) == "Instance" then else warn(string.format(ErrorsModule[404], "PlayerIsOnTeam", 2, "BrickColor ou Instancia", typeof(team))) return end
	if typeof(team) == "Instance" and not team:IsA("Team") then warn(string.format(ErrorsModule[405], "PlayerIsOnTeam", team.Name.." Não é um time")) return end
	
	if typeof(team) == "Instance" then if plr.Team == team then return true end end
	if typeof(team) == "BrickColor" then if plr.TeamColor == team then return true end end
	return false
end

function module.SetPlayerTeam(plr, team)
	if typeof(plr) ~= "Instance" then warn(string.format(ErrorsModule[404], "SetPlayerTeam", 1, "Instancia", typeof(plr))) return end
	if typeof(plr) == "Instance" and not plr:IsA("Player") then warn(string.format(ErrorsModule[405], "SetPlayerTeam", plr.Name.." Não é um jogador")) return end
	if typeof(team) == "BrickColor" or typeof(team) == "Instance" then else warn(string.format(ErrorsModule[404], "SetPlayerTeam", 2, "BrickColor ou Instancia", typeof(team))) return end
	if typeof(team) == "Instance" and not team:IsA("Team") then warn(string.format(ErrorsModule[405], "SetPlayerTeam", team.Name.." Não é um time")) return end
	
	if typeof(team) == "Instance" then
		plr.Team = team
	end
	if typeof(team) == "BrickColor" then
		plr.TeamColor = team
	end
end

function module.GetPlayerPlatform()
	if UserInputService.VREnabled == true then
		return "Vr"
	end
	if UserInputService.KeyboardEnabled == true then
		return "Pc"
	end
	if UserInputService.GamepadEnabled == true then
		return "Console"
	end
	if UserInputService.TouchEnabled == true then
		return "Mobile"
	end
end

function module.IsPrivateServer()
	if game.PrivateServerId ~= "" then
		return true
	else
		return false
	end
end

function module.GetPlayerByPrivateServerOwner()
	if game.Players:GetPlayerByUserId(game.PrivateServerOwnerId) == nil then
		return nil
	else
		return game.Players:GetPlayerByUserId(game.PrivateServerOwnerId)
	end
end

function module.PlayerIsPrivateServerOwner(plr)
	if typeof(plr) ~= "Instance" then warn(string.format(ErrorsModule[404], "GetPlayerByPrivateServerOwner", 1, "Instancia", typeof(plr))) return end
	if typeof(plr) == "Instance" and plr:IsA("Player") then else warn(string.format(ErrorsModule[405], "GetPlayerByPrivateServerOwner", plr.Name.."Não é um jogador")) return end
	if plr.UserId == game.PrivateServerOwnerId then
		return true
	else
		return false
	end
end

return module
