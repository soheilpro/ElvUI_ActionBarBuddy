local E = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local AB = E.ActionBars
local AddOnName, Engine = ...

local IsPossessBarVisible, HasOverrideActionBar = IsPossessBarVisible, HasOverrideActionBar
local GetOverrideBarIndex, GetVehicleBarIndex, GetTempShapeshiftBarIndex = GetOverrideBarIndex, GetVehicleBarIndex, GetTempShapeshiftBarIndex
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local UnitExists, UnitAffectingCombat = UnitExists, UnitAffectingCombat
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local C_PlayerInfo_GetGlidingInfo = C_PlayerInfo and C_PlayerInfo.GetGlidingInfo

local ABB = E:NewModule(AddOnName, 'AceHook-3.0')
_G[AddOnName] = Engine

ABB.Title = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Title')
ABB.Version = GetAddOnMetadata('ElvUI_ActionBarBuddy', 'Version')
ABB.Configs = {}

function ABB:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', E.media.hexvaluecolor or '|cff00b3ff', 'ActionBar Masks:|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

local function GetOptions()
	for _, func in pairs(ABB.Configs) do
		func()
	end
end

function ABB:UpdateDragonRiding()
	local fullConditions = format('[overridebar] %d; [vehicleui][possessbar] %d;', GetOverrideBarIndex(), GetVehicleBarIndex()) or ''
	if E.db.actionbar.abb.removeDragonOverride then
		AB.barDefaults.bar1.conditions = fullConditions..format('[shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetTempShapeshiftBarIndex())
	else
		AB.barDefaults.bar1.conditions = fullConditions..format('[bonusbar:5] 11; [shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetTempShapeshiftBarIndex())
	end
	AB:PositionAndSizeBar('bar1')
end

function ABB:UpdateOptions()
	local db = E.db.actionbar.abb

	-- AB.fadeParent:RegisterEvent('PLAYER_REGEN_DISABLED')
	-- AB.fadeParent:RegisterEvent('PLAYER_REGEN_ENABLED')
	-- AB.fadeParent:RegisterEvent('PLAYER_TARGET_CHANGED')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
	-- AB.fadeParent:RegisterUnitEvent('UNIT_HEALTH', 'player')

	-- if not E.Classic then
	-- 	AB.fadeParent:RegisterEvent('PLAYER_FOCUS_CHANGED')
	-- end

	-- if E.Retail or E.Wrath then
	-- 	AB.fadeParent:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
	-- 	AB.fadeParent:RegisterEvent('UPDATE_POSSESS_BAR')
	-- 	AB.fadeParent:RegisterEvent('VEHICLE_UPDATE')
	-- 	AB.fadeParent:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
	-- 	AB.fadeParent:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
	-- end

	-- ABB.fadeParent:SetScript('OnEvent', ABB.FadeParent_OnEvent)
	if db.enhancedGlobalFade.enable then
		AB.fadeParent:SetScript('OnEvent', ABB.FadeParent_OnEvent)

		for i = 1, 10 do
			AB:Unhook(AB.handledBars['bar'..i], 'OnEnter')
			AB:Unhook(AB.handledBars['bar'..i], 'OnLeave')
			if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnEnter') then
				ABB:HookScript(AB.handledBars['bar'..i], 'OnEnter', 'Bar_OnEnter')
			end
			if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnLeave') then
				ABB:HookScript(AB.handledBars['bar'..i], 'OnLeave', 'Bar_OnLeave')
			end

			for x = 1, 12 do
				AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnEnter')
				AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnLeave')
				if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnEnter') then
					ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnEnter', 'Button_OnEnter')
				end
				if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnLeave') then
					ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnLeave', 'Button_OnLeave')
				end
			end
		end
		if E.Retail then
			for i = 13, 15 do
				AB:Unhook(AB.handledBars['bar'..i], 'OnEnter')
				AB:Unhook(AB.handledBars['bar'..i], 'OnLeave')
				if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnEnter') then
					ABB:HookScript(AB.handledBars['bar'..i], 'OnEnter', 'Bar_OnEnter')
				end
				if not ABB:IsHooked(AB.handledBars['bar'..i], 'OnLeave') then
					ABB:HookScript(AB.handledBars['bar'..i], 'OnLeave', 'Bar_OnLeave')
				end

				for x = 1, 12 do
					AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnEnter')
					AB:Unhook(AB.handledBars['bar'..i].buttons[x], 'OnLeave')
					if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnEnter') then
						ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnEnter', 'Button_OnEnter')
					end
					if not ABB:IsHooked(AB.handledBars['bar'..i].buttons[x], 'OnLeave') then
						ABB:HookScript(AB.handledBars['bar'..i].buttons[x], 'OnLeave', 'Button_OnLeave')
					end
				end
			end
		end

		-- if E.Retail then
		-- 	local ZoneAbilityFrame = _G.ZoneAbilityFrame
		-- 	ZoneAbilityFrame.SpellButtonContainer:UnhookScript('OnEnter', AB.ExtraButtons_OnEnter)
		-- 	ZoneAbilityFrame.SpellButtonContainer:HookScript('OnLeave', AB.ExtraButtons_OnLeave)
		-- end
	else
		AB.fadeParent:SetScript('OnEvent', AB.FadeParent_OnEvent)
	end

	if E.Retail then
		ABB:UpdateDragonRiding()
	end
end

function ABB:Bar_OnEnter(bar)
	local db = AB.db.abb.enhancedGlobalFade
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function ABB:Bar_OnLeave(bar)
	local db = AB.db.abb.enhancedGlobalFade
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

function ABB:Button_OnEnter(button)
	local db = AB.db.abb.enhancedGlobalFade
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function ABB:Button_OnLeave(button)
	local db = AB.db.abb.enhancedGlobalFade
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and db.displayTriggers.mouseover and not AB.fadeParent.mouseLock then
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

do
	local DragonChecks = {
		PLAYER_MOUNT_DISPLAY_CHANGED = function() return AB.WasDragonflying end,
		PLAYER_TARGET_CHANGED = function() return AB.WasDragonflying end,
		FAKE_EVENT = function() return AB.WasDragonflying == 0 and E:IsDragonRiding() end --* Added to check dragonriding when option is altered in the config
	}

	local DragonIgnore = {
		UNIT_HEALTH = true,
		PLAYER_TARGET_CHANGED = true,
		UPDATE_OVERRIDE_ACTIONBAR = true,
		PLAYER_MOUNT_DISPLAY_CHANGED = true
	}

	DragonChecks.UPDATE_OVERRIDE_ACTIONBAR = function()
		DragonChecks.UPDATE_OVERRIDE_ACTIONBAR = nil -- only need to check this once, its for the login check

		return AB.WasDragonflying == 0 and E:IsDragonRiding()
	end

	local function CanGlide()
		if not C_PlayerInfo_GetGlidingInfo then return end

		local _, canGlide = C_PlayerInfo_GetGlidingInfo()
		return canGlide
	end

	function ABB:FadeParent_OnEvent(event, _, _, arg3)
		local db = AB.db.abb.enhancedGlobalFade

		if event == 'UNIT_SPELLCAST_SUCCEEDED' then
			if not AB.WasDragonflying then -- this gets spammed on init login
				AB.WasDragonflying = E.MountDragons[arg3] and arg3
			end
		else
			local dragonCheck = E.Retail and DragonChecks[event]
			local dragonMount = dragonCheck and IsMounted() and dragonCheck()
			local dragonCast = E.Retail and not db.displayTriggers.isDragonRiding and E.MountDragons[arg3]
			local possessbar = SecureCmdOptionParse('[possessbar] 1; 0')

			if (db.displayTriggers.playerCasting and (UnitCastingInfo('player') or UnitChannelInfo('player')) and not dragonCast)
			or (db.displayTriggers.hasTarget and UnitExists('target'))
			or (db.displayTriggers.hasFocus and UnitExists('focus'))
			or (db.displayTriggers.inVehicle and UnitExists('vehicle'))
			or (db.displayTriggers.isPossessed and possessbar == '1')
			or (db.displayTriggers.inCombat and UnitAffectingCombat('player'))
			or (db.displayTriggers.notMaxHealth and (UnitHealth('player') ~= UnitHealthMax('player')))
			or (E.Retail and ((db.displayTriggers.isDragonRiding and CanGlide()) or (db.displayTriggers.inVehicle and (IsPossessBarVisible() or HasOverrideActionBar())))) then
				AB.fadeParent.mouseLock = true
				E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
				AB:FadeBlings(1)
			else
				AB.fadeParent.mouseLock = false
				local a = 1 - AB.db.globalFadeAlpha
				E:UIFrameFadeOut(AB.fadeParent, db.smooth, AB.fadeParent:GetAlpha(), a)
				AB:FadeBlings(a)
			end

			if (AB.WasDragonflying ~= 0) and (not DragonIgnore[event] or not dragonMount) and (event ~= 'UNIT_SPELLCAST_STOP' or arg3 ~= AB.WasDragonflying) then
				AB.WasDragonflying = nil
			end
		end
	end
end

function ABB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	if not AB.Initialized then return end

	AB.fadeParent:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR')
	hooksecurefunc(E, 'UpdateDB', ABB.UpdateOptions)
	ABB:UpdateOptions()

	if not ABBDB then
		_G.ABBDB = {}
	end
end

E.Libs.EP:HookInitialize(ABB, ABB.Initialize)
