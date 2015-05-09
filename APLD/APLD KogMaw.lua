if not VIP_USER or myHero.charName ~= "KogMaw" then return end

function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>APLD KogMaw:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end


local Author = "Your"
local Version = "0.1"

local SCRIPT_INFO = {
	["Name"] = "APLD KogMaw",
	["Version"] = 1.0,
	["Author"] = {
		["Your"] = "http://forum.botoflegends.com/user/145247-"
	},
}
local SCRIPT_UPDATER = {
	["Activate"] = true,
	["Script"] = SCRIPT_PATH..GetCurrentEnv().FILE_NAME,
	["URL_HOST"] = "raw.github.com",
	["URL_PATH"] = "/jineyne/",
	["URL_VERSION"] = "/jineyne/"
}
local SCRIPT_LIBS = {
	["SourceLib"] = "https://raw.github.com/LegendBot/Scripts/master/Common/SourceLib.lua",
	["HPrediction"] = "https://raw.githubusercontent.com/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua"
}

--{ Initiate Script (Checks for updates)
function Initiate()
	for LIBRARY, LIBRARY_URL in pairs(SCRIPT_LIBS) do
		if FileExist(LIB_PATH..LIBRARY..".lua") then
			require(LIBRARY)
		else
			DOWNLOADING_LIBS = true
			ScriptMsg("Missing Library! Downloading "..LIBRARY..". If the library doesn't download, please download it manually.")
			DownloadFile(LIBRARY_URL,LIB_PATH..LIBRARY..".lua",function() ScriptMsg("Successfully downloaded ("..LIBRARY") Thanks Use TEAM Y Teemo") end)
		end
	end
	if DOWNLOADING_LIBS then return true end
	if SCRIPT_UPDATER["Activate"] then
		SourceUpdater("<font color=\"#00A300\">"..SCRIPT_INFO["Name"].."</font>", SCRIPT_INFO["Version"], SCRIPT_UPDATER["URL_HOST"], SCRIPT_UPDATER["URL_PATH"], SCRIPT_UPDATER["Script"], SCRIPT_UPDATER["URL_VERSION"]):CheckUpdate()
	end
end
if Initiate() then return end
	
if VIP_USER then
 	AdvancedCallback:bind('OnApplyBuff', function(source, unit, buff) OnApplyBuff(source, unit, buff) end)
	AdvancedCallback:bind('OnUpdateBuff', function(unit, buff, stack) OnUpdateBuff(unit, buff, stack) end)
	AdvancedCallback:bind('OnRemoveBuff', function(unit, buff) OnRemoveBuff(unit, buff) end)
end

local player = myHero;

local DefultRRange = 0;

local MyminBBox = GetDistance(myHero.minBBox)/2;
local DefultAARange = myHero.range+MyminBBox;

local Q = {Range = 975, Width = 70, Delay = 0.5, Speed = 1200, IsReady = function() return player:CanUseSpell(_Q) == READY end,};
local W = {Range = DefultAARange+(110+20*player:GetSpellData(_E).level), IsReady = function() return player:CanUseSpell(_W) == READY end,};
local E = {Range = 1200, Width = 120, Delay = 0.5, Speed = 1200, IsReady = function() return player:CanUseSpell(_E) == READY end,};
local R = {Range = 900+(300*player:GetSpellData(_R).level), Delay = 1.1, Width = 225, Speed = math.huge, IsReady = function() return player:CanUseSpell(_R) == READY end, };

local KogMawRStack = {Stack = 1, LastCastTime = 0};

local VPload , DPLoad, HPLoad = false, false, false;
local Next_Cast_time = 0;

local RMana = 0;
local _RMana = {"40", "80", "120", "160", "200", "240", "280", "320", "360", "400"}
local DPStat = {"SUCCESS_HIT", "MINION_HIT"}
local Prediction = {"HPrediction"}

local STS;

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
	_JungleMobs = minionManager(MINION_JUNGLE, R.Range, myHero, MINION_SORT_MAXHEALTH_DEC)
end

local function OrbLoad()
	if _G.MMA_Loaded then
		MMALoaded = true
		ScriptMsg("Found MMA")
	elseif _G.AutoCarry then
		if _G.AutoCarry.Helper then
			RebornLoaded = true
			ScriptMsg("Found SAC: Reborn")
		else
			RevampedLoaded = true
			ScriptMsg("Found SAC: Revamped")
		end
	elseif _G.Reborn_Loaded then
		SACLoaded = true
		DelayAction(OrbLoad, 1)
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require 'SxOrbWalk'
		SxO = SxOrbWalk()
		SxOLoaded = true
		ScriptMsg("Loaded SxO")
	elseif FileExist(LIB_PATH .. "SOW.lua") then
		require 'SOW'
		SOW = SOW(VP)
		SOWLoaded = true
		ScriptMsg("Loaded SOW")
	else
		ScriptMsg("Cant Fine OrbWalker")
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

local function OrbTarget(range)
	local T
	if MMALoad then T = _G.MMA_Target end
	if RebornLoad then T = _G.AutoCarry.Crosshair.Attack_Crosshair.target end
	if RevampedLoaded then T = _G.AutoCarry.Orbwalker.target end
	if SxOLoad then T = SxO:GetTarget() end
	if SOWLoaded then T = SOW:GetTarget() end
	if T == nil then 
		T = STS:GetTarget(range)
	end
	if T and T.type == player.type and ValidTarget(T, range) then
		return T
	end
end


function OnLoad()
	HPred = HPrediction()
	STS = SimpleTS();
	OrbLoad();
	
	OnMenuLoad();
	
		-- Q
	Spell_Q.delay['KogMaw'] = Q.Delay;
	Spell_Q.width['KogMaw'] = Q.Width*2;
	Spell_Q.range['KogMaw'] = Q.Range;
	Spell_Q.speed['KogMaw'] = Q.Speed;
	Spell_Q.type['KogMaw'] = "DelayLine"
	
		-- E
	Spell_E.delay['KogMaw'] = E.Delay;
	Spell_E.width['KogMaw'] = E.Width*2;
	Spell_E.range['KogMaw'] = E.Range;
	Spell_E.speed['KogMaw'] = E.Speed;
	Spell_E.type['KogMaw'] = "DelayLine"
		
		-- R
	Spell_R.delay['KogMaw'] = R.Delay;
	Spell_R.radius['KogMaw'] = R.Width;
	Spell_R.range['KogMaw'] = R.Range;
	Spell_R.type['KogMaw'] = "PromptCircle"
	
	if GetGame().map.shortName == "twistedTreeline" then
		TwistedTreeline = true
	else
		TwistedTreeline = false
	end
	Setting()
	
	enemyMinions = minionManager(MINION_ENEMY, R.Range+R.Width, player, MINION_SORT_MAXHEALTH_DEC)

end

function OnMenuLoad()
	Config = scriptConfig("APLD KogMaw", "APLD KogMaw");
	
	Config:addSubMenu("TargetSelector", "TargetSelector")
	STS:AddToMenu(Config.TargetSelector)
	
	Config:addSubMenu("HotKey", "HotKey");
		Config.HotKey:addParam("Combo","Combo",SCRIPT_PARAM_ONKEYDOWN, false, 32);
		Config.HotKey:addParam("Harass","Harass",SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"));
		Config.HotKey:addParam("LineClear","LineClear",SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"));
		
	Config:addSubMenu("Combo", "Combo");
		Config.Combo:addParam("UseQ","Use Q",SCRIPT_PARAM_ONOFF, true);
		Config.Combo:addParam("UseW","Use W",SCRIPT_PARAM_ONOFF, true);
		Config.Combo:addParam("UseE","Use E",SCRIPT_PARAM_ONOFF, true);
		Config.Combo:addParam("UseR","Use R",SCRIPT_PARAM_ONOFF, true);
	
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true);
		Config.Harass:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true);
		Config.Harass:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true);
		Config.Harass:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true);
		
	Config:addSubMenu("Clear", "Clear")
		Config.Clear:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true);
		Config.Clear:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true);
		Config.Clear:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true);
		Config.Clear:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true);
		
	Config:addSubMenu("KillSteal", "KillSteal")
		Config.KillSteal:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true);
		Config.KillSteal:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true);
		
	Config:addSubMenu("Prediction", "pred")
		Config.pred:addSubMenu("HPSetting", "HPSetting")
			Config.pred.HPSetting:addParam("QHitChance", "QHitChance", SCRIPT_PARAM_SLICE, 2, 0, 3, 0);
			Config.pred.HPSetting:addParam("EHitChance", "EHitChance", SCRIPT_PARAM_SLICE, 2, 0, 3, 0);
			Config.pred.HPSetting:addParam("RHitChance", "RHitChance", SCRIPT_PARAM_SLICE, 1, 0, 3, 0);

	Config:addSubMenu("ETC", "ETC")
		--Config.ETC:addParam("DamageManager", "DamageManager", SCRIPT_PARAM_ONOFF, true);
		Config.ETC:addParam("TargetMark", "TargetMark", SCRIPT_PARAM_ONOFF, true);
		Config.ETC:addParam("TMColor", "TargetMark Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		
	Config:addSubMenu("Draw", "Draw")
		Config.Draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		Config.Draw:addParam("DrawQColor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.Draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		Config.Draw:addParam("DrawWColor", "Draw W Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.Draw:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		Config.Draw:addParam("DrawEColor", "Draw E Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.Draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
		Config.Draw:addParam("DrawRColor", "Draw R Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		
			
	Config:addSubMenu("WSetting", "WSetting")
		Config.WSetting:addParam("WAdvance","Use W in advance",SCRIPT_PARAM_ONOFF, false);
		
	
	Config:addSubMenu("RSetting", "RSetting")
		Config.RSetting:addParam("PriorityW", "Priority W target", SCRIPT_PARAM_ONOFF, true);
		Config.RSetting:addParam("UseRLimit","Use R Limit",SCRIPT_PARAM_ONOFF, true);
		Config.RSetting:addParam("LimitRStack","LimitRStack", SCRIPT_PARAM_LIST, 5, {"40", "80", "120", "160", "200", "240", "280", "320", "360", "400"});
		Config.RSetting:addParam("UseRDelay", "Use R Delay", SCRIPT_PARAM_ONOFF, true);
		Config.RSetting:addParam("DelayRChoice", "Delay R Choice", SCRIPT_PARAM_LIST, 1, { "Random", "Slice",});
		Config.RSetting:addParam("DelayRSlice", "Delay R Slice", SCRIPT_PARAM_SLICE, 0, 0, 50, 0);
		Config.RSetting:addParam("RKSDelay", "Use RKS Delay", SCRIPT_PARAM_ONOFF, true)
		
	Config:addSubMenu("Developer", "Developer")
		Config.Developer:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, true)
		
	Config:addParam("INFO", "", SCRIPT_PARAM_INFO, "")
	Config:addParam("Version", "Version", SCRIPT_PARAM_INFO, Version)
	Config:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
end

function OnTick()
	if player.dead then	return end

	if Config.HotKey.Combo then OnCombo() end
	if Config.HotKey.Harass then OnHarass() end
	if Config.HotKey.LineClear then OnClear() end
	
	OnKillSteal()
	if Next_Cast_time < os.clock() then
		if Next_Cast_time > 0 then
			local target = OrbTarget(R.Range)
			if target ~= nil then
				CastRTwo(target)
			end	
		end
	end
	if tostring(KogMawRStack.LastCastTime+6.5) < tostring(os.clock()) then
		KogMawRStack.Stack = 1;
		KogMawRStack.LastCastTime = 0;
	end
end

function OnDraw()
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
	
	if Config.ETC.TargetMark then
		local t = OrbTarget(R.Range)
		if t~= nil then
			DrawCircle(t.x, t.y, t.z, t.minBBox, TARGB(Config.ETC.TMColor))
		end
	end
	
	if Config.Debug then
		DrawText(_RMana[KogMawRStack.Stack], 18, 100, 100, 0xffff0000)
		DrawText(tostring(KogMawRStack.LastCastTime), 18, 100, 125, 0xffff0000)
		DrawText(tostring(os.clock()), 18, 100, 150, 0xffff0000)
		DrawText(tostring(Next_Cast_time), 18, 100, 175, 0xffff0000)
	end
end

function OnCombo()
	if player.dead then return end
	local t = OrbTarget(R.Range)
	if t ~= nil then
		if Config.Combo.UseQ then CastQ(t) end
		if Config.Combo.UseW then CastW() end
		if Config.Combo.UseE then CastE(t) end
		if Config.Combo.UseR then CastR(t) end
	end
end

function OnHarass()
	if player.dead then return end
	local t = OrbTarget(R.Range)
	if t ~= nil then
		if Config.Harass.UseQ then CastQ(t) end
		if Config.Harass.UseW then CastW() end
		if Config.Harass.UseE then CastE(t) end
		if Config.Harass.UseR then CastR(t) end
	end
end

function OnClear()
	enemyMinions:update();
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and not minion.dead then
			if Config.Clear.UseE and GetDistance(minion, player) < E.Range and E.IsReady() then
				local bestpos, besthit = GetBestLineFarmPosition(E.Range, E.Width, enemyMinions.objects)
				if bestpos ~= nil then
					CastSpell(_E, bestpos.x, bestpos.z)
				end
			end
			if Config.Clear.UseR and GetDistance(minion, player) < R.Range and R.IsReady() and RLimit() then
				local bestpos, besthit = GetBestCircularFarmPosition(R.Range, R.Width, enemyMinions.objects)
				if bestpos ~= nil then
					CastSpell(_R, bestpos.x, bestpos.z)
				end
			end
		end
	end
	_JungleMobs:update();
	for i, minion in pairs(_JungleMobs.objects) do
		if minion ~= nil and not minion.dead then
			if Config.Clear.UseE and GetDistance(minion, player) < E.Range and E.IsReady() then
				local bestpos, besthit = GetBestLineFarmPosition(E.Range, E.Width, _JungleMobs.objects)
				if bestpos ~= nil then
					CastSpell(_E, bestpos.x, bestpos.z)
				end
			end
			if Config.Clear.UseR and GetDistance(minion, player) < R.Range and R.IsReady() and RLimit() then
				local bestpos, besthit = GetBestCircularFarmPosition(R.Range, R.Width, _JungleMobs.objects)
				if bestpos ~= nil then
					CastSpell(_R, bestpos.x, bestpos.z)
				end
			end
		end
	end
end

function OnKillSteal()
	if player.dead then return end
	local Kt = OrbTarget(R.Range)
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if Config.KillSteal.CastE and getDmg("E", enemy, player) and E.IsReady() and GetDistance(enemy, player) <= E.Range then CastE(Kt) end
		if Config.KillSteal.CastR and getDmg("R", enemy, player) and R.IsReady() and GetDistance(enemy, player) <= R.Range then CastR(Kt) end
	end
end


function CastQ( target )
	if Q.IsReady() then
		if GetDistance(player, target) <= Q.Range then
			local Pos, HitChance = HPred:GetPredict("Q", target, player)
			if HitChance >= Config.pred.HPSetting.QHitChance  then
				CastSpell(_Q, Pos.x, Pos.z)
			end
		end
	end
end

function CastW( target )
	if W.IsReady() then
		if Config.WSetting.WAdvance then
			if GetDistance(player, target) <= W.Range+100 then
				CastSpell(_W)
			end
		else
			if GetDistance(player, target) <= W.Range then
				CastSpell(_W)
			end
		end
	end
end

function CastE( target )
	if E.IsReady() then
		if GetDistance(player, target) <= E.Range then
			local Pos, HitChance = HPred:GetPredict("E", target, player)
			if HitChance >= Config.pred.HPSetting.EHitChance  then
				CastSpell(_E, Pos.x, Pos.z)
			end
		end
	end
end

function CastR( target )
	if R.IsReady() then
		if RSKDelay() then
			if RLimit() then
				CastRDelay()
			end
		end
	end
end

function CastRDelay()
	local delay = RDelay()
	if Next_Cast_time == 0 and R.IsReady() then
		Next_Cast_time = os.clock() + (delay*0.01)
		print(Next_Cast_time)
	end
end

function CastRTwo( target )
	if not R.IsReady() then return end
	if GetDistance(target, player) < R.Range then
		local Pos, HitChance = HPred:GetPredict("R", target, player)
		if HitChance >= Config.pred.HPSetting.RHitChance  then
			CastSpell(_R, Pos.x, Pos.z)
		end
	end
end

---------------------------------
---------R Logic ----------------
---------------------------------

function RSKDelay()
	if not Config.RSetting.RKSDelay then return true end
	for i, champ in ipairs(GetEnemyHeroes()) do
		if champ.health < getDmg("R", champ, player)+100 then
			for j, ally in ipairs(GetAllyHeroes()) do
				if GetDistance(champ, ally) < 600 then
					return true;
				end
			end
		end
	end
	return true;
end

function RDelay()
	if not Config.RSetting.UseRDelay then return 0 end
	if Config.RSetting.DelayRChoice == 1 then
		return math.random(0, 50);
	elseif Config.RSetting.DelayRChoice == 2 then
		return Config.RSetting.DelayRSlice;
	end
	return 0;
end

function RLimit()
	if not Config.RSetting.UseRLimit then return true end
	if _RMana[KogMawRStack.Stack] < _RMana[Config.RSetting.LimitRStack] then
		return false;
	end
	return true;
end

function PriorityW()
	if not Config.RSetting.PriorityW then return true end;
	for i , champ in ipairs(GetEnemyHeroes()) do
		if TargetHaveBuff("Slow", champ) and GetDistance(player, champ) then
			return champ
		end
	end
	return nil;
end

---------------------------------
------End R Logic ---------------
---------------------------------

---------------------------------
------Fucking Farming -----------
---------------------------------

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.pos or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function GetBestLineFarmPosition(range, width, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local EndPos = Vector(myHero.pos) + range * (Vector(object) - Vector(myHero.pos)):normalized()
        local hit = CountObjectsOnLineSegment(myHero.pos, EndPos, width, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
    local n = 0
    for i, object in ipairs(objects) do
        local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
        if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
            n = n + 1
        end
    end
    return n
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "KogMawLivingArtillery" then
		KogMawRStack.Stack = KogMawRStack.Stack+1;
		KogMawRStack.LastCastTime = os.clock();
		Next_Cast_time = 0;
	end
end