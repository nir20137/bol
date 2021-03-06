--[[
        Your Master Yi

	v 1.0		Release
	V 1.01		Fix Q Rogic, W Cansle,
	v 1.02		Fix Bug
	v 1.03		Fix Updater
	v 1.04		Optimization, Add CastItem (Youmu, Blade of the Ruined King)

]]

if myHero.charName ~= "MasterYi" then return end

local Author = "Your"
local version = "1.04"

local SCRIPT_INFO = {
	["Name"] = "Your Master Yi",
	["Version"] = 1.04,
	["Author"] = {
		["Your"] = "http://forum.botoflegends.com/user/145247-"
	},
}
local SCRIPT_UPDATER = {
	["Activate"] = true,
	["Script"] = SCRIPT_PATH..GetCurrentEnv().FILE_NAME,
	["URL_HOST"] = "raw.github.com",
	["URL_PATH"] = "/jineyne/bol/master/Your Master Yi.lua",
	["URL_VERSION"] = "/jineyne/bol/master/version/Your Master Yi.version"
}
local SCRIPT_LIBS = {
	["SourceLib"] = "https://raw.github.com/LegendBot/Scripts/master/Common/SourceLib.lua",
}

function PrintMessage(message) 
	print("<font color=\"#00A300\"><b>"..SCRIPT_INFO["Name"]..":</b></font> <font color=\"#FFFFFF\">"..message.."</font>")
end
--{ Initiate Script (Checks for updates)
	function Initiate()
		for LIBRARY, LIBRARY_URL in pairs(SCRIPT_LIBS) do
			if FileExist(LIB_PATH..LIBRARY..".lua") then
				require(LIBRARY)
			else
				DOWNLOADING_LIBS = true
				PrintMessage("Missing Library! Downloading "..LIBRARY..". If the library doesn't download, please download it manually.")
				DownloadFile(LIBRARY_URL,LIB_PATH..LIBRARY..".lua",function() PrintMessage("Successfully downloaded "..LIBRARY) end)
			end
		end
		if DOWNLOADING_LIBS then return true end
		if SCRIPT_UPDATER["Activate"] then
			SourceUpdater("<font color=\"#00A300\">"..SCRIPT_INFO["Name"].."</font>", SCRIPT_INFO["Version"], SCRIPT_UPDATER["URL_HOST"], SCRIPT_UPDATER["URL_PATH"], SCRIPT_UPDATER["Script"], SCRIPT_UPDATER["URL_VERSION"]):CheckUpdate()
		end
	end
	if Initiate() then return end

local Ignite = nil
local Smite = nil

local defaultRange = myHero.range + GetDistance(myHero.minBBox)
local enemyHeroes = GetEnemyHeroes()


local enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_MAXHEALTH_DEC)

local Q = {Name = "Alpha Strike", Range = 600, IsReady = function() return myHero:CanUseSpell(_Q) == READY end,}
local W = {Name = "Meditate", Range = defaultRange, IsReady = function() return myHero:CanUseSpell(_W) == READY end,}
local E = {Name = "Wuju Style", Range = defaultRange, IsReady = function() return myHero:CanUseSpell(_E) == READY end,}
local R = {Name = "Highlander", Range = 125, IsReady = function() return myHero:CanUseSpell(_R) == READY end,}

local qDmg = 0
local wDmg = 0
local eDmg = 0



local JungleMobs = {}
local JungleFocusMobs = {}
	
	
local EvadingSpell =
{
	--["Jax"]			= {"CounterStrike"},
	["Teemo"]		= {"BlindingDart"},
	["Jad"] = {""},
}

local KillText = {}
local KillTextColor = ARGB(250, 255, 38, 1)
local KillTextList =
 {		
	"Harass your enemy!", 					-- 01
	"Wait for your CD's!",					-- 02
	"Kill! - Ignite",						-- 03
	"Kill! - (Q)",							-- 04 
	"Kill! - (W)",							-- 05
	"Kill! - (E)",							-- 06
	"Kill! - (Q)+(W)",						-- 07
	"Kill! - (Q)+(E)",						-- 08
	"Kill! - (W)+(E)",						-- 09
	"Kill! - (Q)+(W)+(E)"					-- 10
}

local MMALoaded, RebornLoaded, RevampedLoaded, SxOLoaded, SACLoaded = nil, nil, nil, nil, nil

local function OrbLoad()
	if _G.MMA_Loaded then
		MMALoaded = true
		PrintMessage("Found MMA")
	elseif _G.AutoCarry then
		if _G.AutoCarry.Helper then
			RebornLoaded = true
			PrintMessage("Found SAC: Reborn")
		else
			RevampedLoaded = true
			PrintMessage("Found SAC: Revamped")
		end
	elseif _G.Reborn_Loaded then
		SACLoaded = true
		DelayAction(OrbLoad, 1)
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require 'SxOrbWalk'
		SxO = SxOrbWalk()
		SxOLoaded = true
		PrintMessage("Loaded SxO")
	elseif FileExist(LIB_PATH .. "SOW.lua") then
		require 'SOW'
		SOW = SOW(VP)
		SOWLoaded = true
		ScriptMsg("Loaded SOW")
	else
		PrintMessage("Cant Fine OrbWalker")
	end
end

local function OrbReset()
	if MMALoaded then
		--print("ReSet")
		_G.MMA_ResetAutoAttack()
	elseif RebornLoaded then
		--print("ReSet")
		_G.AutoCarry.MyHero:AttacksEnabled(true)
	elseif SxOLoaded then
		--print("ReSet")
		SxO:ResetAA()
	elseif SOWLoaded then
		--print("ReSet")
		SOW:resetAA()
	end
end

function OrbwalkCanMove()
 	if RebornLoaded then
    	return _G.AutoCarry.Orbwalker:CanMove()
 	elseif MMALoaded then
	    return _G.MMA_AbleToMove
	 elseif SxOLoaded then
 	   return SxO:CanMove()
	elseif SOWLoaded then
	   return SOW:CanMove()
	 end
end

local function OrbTarget(rance)
	local T
	if MMALoad then T = _G.MMA_Target end
	if RebornLoad then T = _G.AutoCarry.Crosshair.Attack_Crosshair.target end
	if RevampedLoaded then T = _G.AutoCarry.Orbwalker.target end
	if SxOLoad then T = SxO:GetTarget() end
	if SOWLoaded then T = SOW:GetTarget() end
	if T == nil then 
		T = STS:GetTarget(rance)
	end
	if T and T.type == player.type and ValidTarget(T, rance) then
		return T
	end
end

function Setting()
	if not TwistedTreeline then
		JungleMobNames = {
			["SRU_MurkwolfMini2.1.3"]	= true,
			["SRU_MurkwolfMini2.1.2"]	= true,
			["SRU_MurkwolfMini8.1.3"]	= true,
			["SRU_MurkwolfMini8.1.2"]	= true,
			["SRU_BlueMini1.1.2"]		= true,
			["SRU_BlueMini7.1.2"]		= true,
			["SRU_BlueMini21.1.3"]		= true,
			["SRU_BlueMini27.1.3"]		= true,
			["SRU_RedMini10.1.2"]		= true,
			["SRU_RedMini10.1.3"]		= true,
			["SRU_RedMini4.1.2"]		= true,
			["SRU_RedMini4.1.3"]		= true,
			["SRU_KrugMini11.1.1"]		= true,
			["SRU_KrugMini5.1.1"]		= true,
			["SRU_RazorbeakMini9.1.2"]	= true,
			["SRU_RazorbeakMini9.1.3"]	= true,
			["SRU_RazorbeakMini9.1.4"]	= true,
			["SRU_RazorbeakMini3.1.2"]	= true,
			["SRU_RazorbeakMini3.1.3"]	= true,
			["SRU_RazorbeakMini3.1.4"]	= true
		}

		FocusJungleNames = {
			["SRU_Blue1.1.1"]			= true,
			["SRU_Blue7.1.1"]			= true,
			["SRU_Murkwolf2.1.1"]		= true,
			["SRU_Murkwolf8.1.1"]		= true,
			["SRU_Gromp13.1.1"]			= true,
			["SRU_Gromp14.1.1"]			= true,
			["Sru_Crab16.1.1"]			= true,
			["Sru_Crab15.1.1"]			= true,
			["SRU_Red10.1.1"]			= true,
			["SRU_Red4.1.1"]			= true,
			["SRU_Krug11.1.2"]			= true,
			["SRU_Krug5.1.2"]			= true,
			["SRU_Razorbeak9.1.1"]		= true,
			["SRU_Razorbeak3.1.1"]		= true,
			["SRU_Dragon6.1.1"]			= true,
			["SRU_Baron12.1.1"]			= true
		}
	else
		FocusJungleNames = {
			["TT_NWraith1.1.1"]			= true,
			["TT_NGolem2.1.1"]			= true,
			["TT_NWolf3.1.1"]			= true,
			["TT_NWraith4.1.1"]			= true,
			["TT_NGolem5.1.1"]			= true,
			["TT_NWolf6.1.1"]			= true,
			["TT_Spiderboss8.1.1"]		= true
		}
		JungleMobNames = {
			["TT_NWraith21.1.2"]		= true,
			["TT_NWraith21.1.3"]		= true,
			["TT_NGolem22.1.2"]			= true,
			["TT_NWolf23.1.2"]			= true,
			["TT_NWolf23.1.3"]			= true,
			["TT_NWraith24.1.2"]		= true,
			["TT_NWraith24.1.3"]		= true,
			["TT_NGolem25.1.1"]			= true,
			["TT_NWolf26.1.2"]			= true,
			["TT_NWolf26.1.3"]			= true
		}
	end
	_JungleMobs = minionManager(MINION_JUNGLE, Q.Range, myHero, MINION_SORT_MAXHEALTH_DEC)
end

function GetJungleMob(rance)
	for _, Mob in pairs(JungleFocusMobs) do
		if ValidTarget(Mob, rance) then
			return Mob
		end
	end
	for _, Mob in pairs(JungleMobs) do
		if ValidTarget(Mob, rance) then
			return Mob
		end
	end
end

function OnLoad()
	STS = SimpleTS()
	OrbLoad()
	LoadMenu()
	Setting()
	
 	if GetGame().map.shortName == "twistedTreeline" then
		TwistedTreeline = true
	else
		TwistedTreeline = false
	end
	
	Items =
	{
		["Hydra"] = {Id = 3074,Range = defaultRange,Slot = nil, IsReady = function() if Items["Hydra"].Slot ~= nil then return myHero:CanUseSpell(Items["Hydra"].Slot) else return false end end,},
		["Tiamat"] = {Id = 3077,Range = defaultRange,Slot = nil, IsReady = function() if Items["Tiamat"].Slot ~= nil then return myHero:CanUseSpell(Items["Tiamat"].Slot) else return false end end,},
		["Youmu"] = {Id = 3142,Range = defaultRange,Slot = nil, IsReady = function() if Items["Youmu"].Slot ~= nil then return myHero:CanUseSpell(Items["Youmu"].Slot) else return false end end,},
		["BRK"]   = {Id = 3153,Range = 450,Slot = nil, IsReady = function() if Items["BRK"].Slot ~= nil then return myHero:CanUseSpell(Items["BRK"].Slot) else return false end end,},
	}
	
end

function _GetSummonerSlot(spellName, unit)
    unit = unit or player
    if unit:GetSpellData(SUMMONER_1).name:lower():find(spellName) then return SUMMONER_1 end
    if unit:GetSpellData(SUMMONER_2).name:lower():find(spellName) then return SUMMONER_2 end
	return nil
end



function LoadMenu()
	Config = scriptConfig("[Your] Master Yi", "[Your] Master Yi")
		Config:addSubMenu("Hotkey", "Hotkey")
			Config.Hotkey:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			Config.Hotkey:addParam("Clear", "Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
			Config.Hotkey:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

		Config:addSubMenu("Combo", "Combo")
			Config.Combo:addParam("UseQ", "UseQ", SCRIPT_PARAM_ONOFF, true)
			Config.Combo:addParam("UseW", "UseW", SCRIPT_PARAM_ONOFF, true)
			Config.Combo:addParam("UseE", "UseE", SCRIPT_PARAM_ONOFF, true)
			Config.Combo:addParam("UseR", "UseR", SCRIPT_PARAM_ONOFF, true)
			--Config.Combo:addParam("UseItem", "UseItem", SCRIPT_PARAM_ONOFF, true)

		Config:addSubMenu("Harass", "Harass")
			Config.Harass:addParam("UseQ", "UseQ", SCRIPT_PARAM_ONOFF, true)
			Config.Harass:addParam("UseW", "UseW", SCRIPT_PARAM_ONOFF, false)
			Config.Harass:addParam("UseE", "UseE", SCRIPT_PARAM_ONOFF, false)

		Config:addSubMenu("Clear", "Clear")
			Config.Clear:addParam("UseQ", "UseQ", SCRIPT_PARAM_ONOFF, true)
			--Config.Clear:addParam("UseW", "UseW", SCRIPT_PARAM_ONOFF, false)
			Config.Clear:addParam("UseE", "UseE", SCRIPT_PARAM_ONOFF, true)

		Config:addSubMenu("KillSteal", "KillSteal")
			Config.KillSteal:addParam("Enable", "Enable", SCRIPT_PARAM_ONOFF, true)
			Config.KillSteal:addParam("UseQ", "UseQ", SCRIPT_PARAM_ONOFF, true)
	
		
		Config:addSubMenu("Evade", "Evade")
			Config.Evade:addParam("Evade", "Evade With Evadeee", SCRIPT_PARAM_ONOFF, true)
			
		Config:addSubMenu("Summoner", "Summoner")
			

		Config:addSubMenu("QSetting", "QSetting")
			Config.QSetting:addParam("Packet", "Packet Cast Only VIP", SCRIPT_PARAM_ONOFF, true)
			--Config.QSetting:addParam("Magnet", "Magnet", SCRIPT_PARAM_ONOFF, true)

		Config:addSubMenu("WSetting", "WSetting")
			Config.WSetting:addParam("Cansle", "Attack Cansle", SCRIPT_PARAM_ONOFF, true)
			Config.WSetting:addParam("Packet", "Packet Cast Only VIP", SCRIPT_PARAM_ONOFF, true)

		Config:addSubMenu("ESetting", "ESetting")
			Config.ESetting:addParam("Packet", "Packet Cast Only VIP", SCRIPT_PARAM_ONOFF, true)

		Config:addSubMenu("RSetting", "RSetting")
			Config.RSetting:addParam("Packet", "Packet Cast Only VIP", SCRIPT_PARAM_ONOFF, true)


		Config:addSubMenu("Draw", "Draw")
			Config.Draw:addParam("DrawQ", "Draw Q Rance", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("DrawQColor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
			Config.Draw:addParam("DrawW", "Draw W Rance", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("DrawWColor", "Draw W Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
			Config.Draw:addParam("DrawE", "Draw E Rance", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("DrawEColor", "Draw E Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
			Config.Draw:addParam("DrawR", "Draw R Rance", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("DrawRColor", "Draw R Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
			Config.Draw:addParam("INFO1", "", SCRIPT_PARAM_INFO, "")
			Config.Draw:addParam("KillMark", "KillMark", SCRIPT_PARAM_ONOFF, true)
			Config.Draw:addParam("TargetMark", "TargetMark", SCRIPT_PARAM_ONOFF, true)

		Config:addSubMenu("OrbWalker", "Orbwalker")
			if MMALoaded then
				Config.Orbwalker:addParam("INFO", "MMA Load", SCRIPT_PARAM_INFO, "")
			elseif SACLoaded then
				Config.Orbwalker:addParam("INFO", "Reborn Load", SCRIPT_PARAM_INFO, "")
			elseif SxOLoaded then
				SxO:LoadToMenu(Config.Orbwalker)
				Config.Orbwalker:addParam("INFO", "", SCRIPT_PARAM_INFO, "")
				Config.Orbwalker:addParam("INFO2", "SxOrbWalk Setting", SCRIPT_PARAM_INFO, "")
			elseif SOWLoaded then
				SOW:LoadToMenu(Config.Orbwalker)
				Config.Orbwalker:addParam("INFO", "", SCRIPT_PARAM_INFO, "")
				Config.Orbwalker:addParam("INFO2", "SOW Setting", SCRIPT_PARAM_INFO, "")
			end

		Config:addParam("INFO", "", SCRIPT_PARAM_INFO, "")
		Config:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
		Config:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
end

function OnTick(  )
	if player.dead then return end
	
	
	DamageCalculation()
	if Config.Hotkey.Combo then OnCombo() end
	if Config.Hotkey.Harass then OnHarass() end
	if Config.Hotkey.Clear then OnClear() end
	if Config.KillSteal.Enable then KillSteal() end
	if Config.Evade.Evade then Evade() end
	
	for _, item in pairs(Items) do
		item.Slot = GetInventorySlotItem(item.Id)
	end
end

function OnDraw(  )
	if player.dead then return end
	if Q.IsReady() and Config.Draw.DrawQ then
		DrawCircle(player.x, player.y, player.z, Q.Range, TARGB(Config.Draw.DrawQColor))
	end

	if W.IsReady() and Config.Draw.DrawW then
		DrawCircle(player.x, player.y, player.z, W.Range, TARGB(Config.Draw.DrawWColor))
	end

	if E.IsReady() and Config.Draw.DrawE then
		DrawCircle(player.x, player.y, player.z, E.Range, TARGB(Config.Draw.DrawEColor))
	end

	if R.IsReady() and Config.Draw.DrawR then
		DrawCircle(player.x, player.y, player.z, R.Range, TARGB(Config.Draw.DrawRColor))
	end

	if Config.Draw.KillMark then
		for i, enemy in pairs(enemyHeroes) do
			if ValidTarget(enemy) and enemy ~= nil then
				local barPos = GetHPBarPos(enemy)
				DrawText(KillTextList[KillText[i]], 18, barPos.x, barPos.y-60, KillTextColor)
			end
		end
	end

	if Config.Draw.TargetMark then
		if OrbTarget(Q.Range) then
			local Target = OrbTarget(Q.Range)
			DrawCircle(Target.x, Target.y, Target.z, (GetDistance(Target.minBBox, Target.maxBBox)/2), ARGB(100,76,255,76))
		end
	end
end

function OnCombo()
	local target = OrbTarget(Q.Range)
	if ValidTarget(target) then
		if Items["Youmu"].IsReady() then CastItem(target, "Youmu", 1000) end
		if Items["BRK"].IsReady() then CastBRK(target) end
		if Config.Combo.UseQ and Q.IsReady() and GetDistance(target, player) >= W.Range  then CastQ(target) end
		if Config.Combo.UseE and E.IsReady() then CastE(target) end
		if Config.Combo.UseR and R.IsReady() then CastR(target) end
	end
end


function OnHarass()
	local target = OrbTarget(Q.Range)
	if ValidTarget(target) then
		if Config.Harass.UseQ and Q.IsReady() then CastQ(target) end
		if Config.Harass.UseE and E.IsReady() then CastE(target) end
	end
end

function OnClear(  )
	_JungleMobs:update()
	for i, minion in pairs(_JungleMobs.objects) do
		if minion ~= nil then
			if ValidTarget(minion) and not minion.dead then
				if Config.Clear.UseQ and Q.IsReady() then CastQ(minion) end
				if Config.Clear.UseE and E.IsReady() then CastE(minion) end
			end
		end
	end
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			if ValidTarget(minion) and not minion.dead then
				if Config.Clear.UseQ and Q.IsReady() then CastQ(minion) end
				if Config.Clear.UseE and E.IsReady() then CastE(minion) end
			end
		end
	end
end

function KillSteal(  )
	for _, enemy in pairs(enemyHeroes) do
		if enemy ~= nil and ValidTarget(enemy) then
		local distance = GetDistance(enemy, player)
		local hp = enemy.health
			if hp <= qDmg and Q.IsReady() and (distance <= Q.Range)
				then CastQ(enemy)
			elseif hp <= wDmg and W.IsReady() and (distance <= W.Range) 
				then CastW(enemy)
			elseif hp <= eDmg and E.IsReady() and (distance <= E.Range) 
				then CastE(enemy)
			elseif hp <= (qDmg + wDmg) and Q.IsReady() and W.IsReady() and (distance <= Q.Range)
				then CastW(enemy)
			elseif hp <= (qDmg + eDmg) and Q.IsReady() and E.IsReady() and (distance <= Q.Range)
				then CastE(enemy)
			elseif hp <= (wDmg + eDmg) and W.IsReady() and E.IsReady() and (distance <= W.Range)
				then CastE(enemy)
			elseif hp <= (qDmg + wDmg + eDmg) and Q.IsReady() and W.IsReady() and E.IsReady() and (distance <= Q.Range)
				then CastE(enemy)
			end
		end
	end
end

function Evade()
	if _G.Evadeee_impossibleToEvade then
		local T = OrbTarget(Q.Range)
		if T ~= nil then
			EvadeQ(T)
		end
	end
end

---------------------------------------------------------------------
--- Cast Functions for Spells ---------------------------------------
---------------------------------------------------------------------

function CastQ( target )
	if target.dead then return end
	if not OrbwalkCanMove() then return end
	if GetDistance(target, player) <= Q.Range and target ~= nil then
		if VIP_USER then
			if Config.QSetting.Packet then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = target.networkID}):send()
			else
				CastSpell(_Q, target)
			end
		else
			CastSpell(_Q, target)
		end
	end
end

function EvadeQ()
	local c = nil
	if Config.Hotkey.Combo or Config.Hotkey.Harass then
		c = OrbTarget(Q.Range)
	end
	if c == nil then
		enemyMinions:update()
		for i, minion in pairs(enemyMinions.objects) do
			if c == nil then
				c = minion
			else
				if GetDistance(c, player) > GetDistance(minion, player) then
					c = minion
				end
			end
		end
	end
	if c == nil then
		local c = GetJungleMob(Q.Range)
	end
	if c == nil then
		c = OrbTarget(Q.Range)
	end
	if c ~= nil and Q.IsReady() then
		CastQ(c)
	end
end

function CastW( target )
	if target.dead then return end
	if not OrbwalkCanMove() then return end
	if GetDistance(target, player) <= W.Range and target ~= nil then
		if VIP_USER then
			if Config.QSetting.Packet then
				Packet("S_CAST", {spellId = _W}):send()
				if Config.WSetting.Cansle then 
					OrbReset() 
				end
			else
				CastSpell(_W, target)
				if Config.WSetting.Cansle then 
					OrbReset() 
				end
			end
		else
			CastSpell(_W, target)
			if Config.WSetting.Cansle then 
				OrbReset() 
			end
		end
	end
end

function CastE( target )
	if target.dead then return end
	if not OrbwalkCanMove() then return end
	if GetDistance(target, player) <= E.Range and target ~= nil then
		if VIP_USER then
			if Config.QSetting.Packet then
				Packet("S_CAST", {spellId = _E}):send()
			else
				CastSpell(_E, target)
			end
		else
			CastSpell(_E, target)
		end
	end
end

function CastR( target )
	if target.dead then return end
	if not OrbwalkCanMove() then return end
	if GetDistance(target, player) <= R.Range and target ~= nil then
		if VIP_USER then
			if Config.QSetting.Packet then
				Packet("S_CAST", {spellId = _R}):send()
			else
				CastSpell(_R, target)
			end
		else
			CastSpell(_R, target)
		end
	end
end

function CastBRK( target )
	if target.dead then return end
	if not OrbwalkCanMove() then return end
	if GetDistance(target, player) <= Items["BRK"].Range and target ~= nil then
		if VIP_USER then
			Packet("S_CAST", {spellId = Items["BRK"].Slot, targetNetworkId = target.networkID}):send()
		else
			CastSpell(Items["BRK"].Slot, target)
		end
	end
end

function CastItem( target , item , range)
	if not OrbwalkCanMove() then return end
	if GetDistance(target, player) <= range then return end
	if target ~= nil then
		if VIP_USER then
			Packet("S_CAST", {spellId = Items[item].Slot}):send()
		else
			CastSpell(Items[item].Slot, target)
		end
	end
end


---------------------------------------------------------------------
--- Athor Functions -------------------------------------------------
---------------------------------------------------------------------


---------------------------------------------------------------------
--- Function Damage Calculations for Skills/Items/Enemys --- 
---------------------------------------------------------------------

function DamageCalculation()
	for i, enemy in pairs(enemyHeroes) do
		if ValidTarget(enemy) and enemy ~= nil then
			aaDmg 		= getDmg("AD", enemy, myHero)
			qDmg 		= ((getDmg("Q", enemy, myHero)) or 0)	
			wDmg		= ((getDmg("W", enemy, myHero)) or 0)	
			eDmg		= ((getDmg("E", enemy, myHero)) or 0)
			--iDmg 		= ((Ignite and getDmg("IGNITE", enemy, myHero)) or 0)	-- Ignite
			local abilityDmg = qDmg + wDmg + eDmg
			-- Set Kill Text --	
			-- "Kill! - Ignite" --
			--[[if enemy.health <= iDmgthen
					 if IREADY then KillText[i] = 3
					 else KillText[i] = 2
				 end]]
			-- "Kill! - (Q)" --
			elseif enemy.health <= qDmg then
				if Q.IsReady() then
					KillText[i] = 4
				else
					KillText[i] = 2
				end
			--	"Kill! - (W)" --
			elseif enemy.health <= wDmg then
				if W.IsReady() then KillText[i] = 5
					else KillText[i] = 2
				end
			-- "Kill! - (E)" --
			elseif enemy.health <= eDmg then
				if E.IsReady() then KillText[i] = 6
					else KillText[i] = 2
				end
			-- "Kill! - (Q)+(W)" --
			elseif enemy.health <= qDmg+wDmg then
				if Q.IsReady() and W.IsReady() then KillText[i] = 7
					else KillText[i] = 2
				end
			-- "Kill! - (Q)+(E)" --
			elseif enemy.health <= qDmg+eDmg then
				if Q.IsReady() and E.IsReady() then KillText[i] = 8
					else KillText[i] = 2
				end
			-- "Kill! - (W)+(E)" --
			elseif enemy.health <= wDmg+eDmg then
				if W.IsReady() and E.IsReady() then KillText[i] = 9
					else KillText[i] = 2
				end
			-- "Kill! - (Q)+(W)+(E)" --
			elseif enemy.health <= qDmg+wDmg+eDmg then
				if Q.IsReady() and W.IsReady() and E.IsReady() then KillText[i] = 10
					else KillText[i] = 2
				end
			-- "Harass your enemy!" -- 
			else KillText[i] = 1				
			end
		end
end

function GetHPBarPos(enemy)
	enemy.barData = {PercentageOffset = {x = -0.05, y = 0}}--GetEnemyBarData()
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = 171
	local BarPosOffsetY = 46
	local CorrectionY = 39
	local StartHpPos = 31

	barPos.x = math.floor(barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos)
	barPos.y = math.floor(barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY)

	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos =  Vector(barPos.x + 108 , barPos.y , 0)
	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

--[[
function OnCreateObj(obj)
	if GetDistance(obj, player) < 300 then
		if obj.name == "Counterstrike_cas.troy" then
			local target = OrbTarget(Q.Range)
			if target ~= nil then
				EvadeQ(target)
			end
		end
	end
end
]]
function OnProcessSpell(unit, spell)
	--[[if GetDistance(unit, player) < Q.Range then
		if spell.name == "BlindingDart" and spell.target.isMe then
			local target = OrbTarget(Q.Range)
			if target ~= nil then
				EvadeQ(target)
			end
		end
	end]]
	if unit.isMe then
		if spell.name:lower():find("attack") then
			local target = OrbTarget(Q.Range)
			if not W.IsReady then
				if Config.Hotkey.Combo and Config.Combo.UseW then
					DelayAction( function() CastW(target) end,0.3)
				end
				if Config.Hotkey.Harass and Config.Harass.UseW then
					DelayAction( function() CastW(target) end,0.3)
				end
			--[[else
				if Config.Hotkey.Combo or Config.Hotkey.Harass or Config.Hotkey.Clear then
					if Items["BRK"].IsReady() then
						DelayAction(function() CastBRK(target) end,0.3)
					elseif Items["Hydra"].IsReady() then
						DelayAction( function() CastItem( target , "Hydra" , 1000 ) end,0.3)
						OrbReset()
					elseif Items["Tiamat"].IsReady() then
						DelayAction(function() CastItem( target , "Tiamat" , 1000 )end,0.3)
						OrbReset()
					end
				end]]
			end
		end
	end
end
