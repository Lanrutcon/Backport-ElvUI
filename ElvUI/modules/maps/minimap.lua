local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('Minimap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.Minimap = M

local Astrolabe, AstrolabeMapMonitor
if IsAddOnLoaded("Gatherer") then
	Astrolabe = DongleStub("Astrolabe-1.0")
	AstrolabeMapMonitor = DongleStub("AstrolabeMapMonitor")
end

local gsub = string.gsub
local upper = string.upper
local tinsert = table.insert

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent)

local menuList = {
	{text = CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = SPELLBOOK_ABILITIES_BUTTON,
	func = function() if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end end},
	{text = TALENTS_BUTTON,
	func = function()
		if not PlayerTalentFrame then
			TalentFrame_LoadUI()
		end

		if not GlyphFrame then
			GlyphFrame_LoadUI()
		end

		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end},
	{text = L["Farm Mode"],
	func = FarmMode},
	{text = TIMEMANAGER_TITLE,
	func = function() ToggleFrame(TimeManagerFrame) end},
	{text = ACHIEVEMENT_BUTTON,
	func = function() ToggleAchievementFrame() end},
	{text = SOCIAL_BUTTON,
	func = function() ToggleFriendsFrame() end},
	{text = L["Calendar"],
	func = function() GameTimeFrame:Click() end},
	{text = ACHIEVEMENTS_GUILD_TAB,
	func = function()
		if IsInGuild() then
			if not GuildFrame then GuildFrame_LoadUI() end
			GuildFrame_Toggle()
		else
			if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end
			if not LookingForGuildFrame then return end
			LookingForGuildFrame_Toggle()
		end
	end},
	{text = LFG_TITLE,
	func = function() ToggleLFDParentFrame(); end},
	{text = ENCOUNTER_JOURNAL,
	func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then EncounterJournal_LoadUI(); end ToggleFrame(EncounterJournal) end},
	{text = MAINMENU_BUTTON,
	func = function() 
		if ( not GameMenuFrame:IsShown() ) then
			if ( VideoOptionsFrame:IsShown() ) then
				VideoOptionsFrameCancel:Click();
			elseif ( AudioOptionsFrame:IsShown() ) then
				AudioOptionsFrameCancel:Click();
			elseif ( InterfaceOptionsFrame:IsShown() ) then
				InterfaceOptionsFrameCancel:Click();
			end		
			CloseMenus();
			CloseAllWindows()
			PlaySound("igMainMenuOpen");
			ShowUIPanel(GameMenuFrame);
		else
			PlaySound("igMainMenuQuit");
			HideUIPanel(GameMenuFrame);
			MainMenuMicroButton_SetNormal();
		end
	end}
}

tinsert(menuList, 	{text = HELP_BUTTON, func = function() ToggleHelpFrame() end})

function GetMinimapShape()
	return 'SQUARE'
end

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.84, 0.03, 0.03
	end
end

function M:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function M:Minimap_OnMouseUp(btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if position:match("LEFT") then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == "RightButton" then
		local xoff = -1

		if position:match("RIGHT") then xoff = E:Scale(-16) end

		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, xoff, E:Scale(-3))
	else
		Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' or not E.private.general.minimap.enable then return; end
	Minimap.location:SetText(strsub(GetMinimapZoneText(),1,46))
	Minimap.location:SetTextColor(M:GetLocTextColor())
end

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or Minimap:GetWidth() + 10

	if E.db.auras.consolidatedBuffs.enable and E.private.auras.disableBlizzard then
		E.ConsolidatedBuffsWidth = ((E.MinimapSize - (E.db.auras.consolidatedBuffs.filter and 8 or 9)) / (E.db.auras.consolidatedBuffs.filter and 8 or 9)) + (E.PixelMode and 3 or 4)-- 4 needs to be 3
	else
		E.ConsolidatedBuffsWidth = 0;
	end

	E.MinimapWidth = E.MinimapSize
	E.MinimapHeight = E.MinimapSize + 5

	if E.private.general.minimap.enable then
		Minimap:Size(E.MinimapSize, E.MinimapSize)
	end

	if LeftMiniPanel and RightMiniPanel then
		if E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			LeftMiniPanel:Show()
			RightMiniPanel:Show()
		else
			LeftMiniPanel:Hide()
			RightMiniPanel:Hide()
		end
	end
	
	if(LeftMiniPanel and RightMiniPanel) then
		if(E.db.datatexts.minimapPanels and E.private.general.minimap.enable) then
			LeftMiniPanel:Show();
			RightMiniPanel:Show();
		else
			LeftMiniPanel:Hide();
			RightMiniPanel:Hide();
		end
	end
	
	if(BottomMiniPanel) then
		if(E.db.datatexts.minimapBottom and E.private.general.minimap.enable) then
			BottomMiniPanel:Show();
		else
			BottomMiniPanel:Hide();
		end
	end
	
	if(BottomLeftMiniPanel) then
		if(E.db.datatexts.minimapBottomLeft and E.private.general.minimap.enable) then
			BottomLeftMiniPanel:Show();
		else
			BottomLeftMiniPanel:Hide();
		end
	end
	
	if(BottomRightMiniPanel) then
		if(E.db.datatexts.minimapBottomRight and E.private.general.minimap.enable) then
			BottomRightMiniPanel:Show();
		else
			BottomRightMiniPanel:Hide();
		end
	end
	
	if(TopMiniPanel) then
		if(E.db.datatexts.minimapTop and E.private.general.minimap.enable) then
			TopMiniPanel:Show();
		else
			TopMiniPanel:Hide();
		end
	end
	
	if(TopLeftMiniPanel) then
		if(E.db.datatexts.minimapTopLeft and E.private.general.minimap.enable) then
			TopLeftMiniPanel:Show();
		else
			TopLeftMiniPanel:Hide();
		end
	end
	
	if(TopRightMiniPanel) then
		if(E.db.datatexts.minimapTopRight and E.private.general.minimap.enable) then
			TopRightMiniPanel:Show();
		else
			TopRightMiniPanel:Hide();
		end
	end

	if MMHolder then
		MMHolder:Width((Minimap:GetWidth() + (E.PixelMode and 2 or 4)) + E.ConsolidatedBuffsWidth)

		if E.db.datatexts.minimapPanels then
			MMHolder:Height(Minimap:GetHeight() + (E.PixelMode and 24 or 27))
		else
			MMHolder:Height(Minimap:GetHeight() + (E.PixelMode and 2 or 5))
		end
	end

	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)

		if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
			Minimap.location:Hide()
		else
			Minimap.location:Show()
		end
	end

	if MinimapMover then
		MinimapMover:Size(MMHolder:GetSize())
	end

	if AurasHolder then
		AurasHolder:Height(E.MinimapHeight)
		if AurasMover and not E:HasMoverBeenMoved('AurasMover') and not E:HasMoverBeenMoved('MinimapMover') then
			AurasMover:ClearAllPoints()
			AurasMover:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -((E.MinimapSize + 4) + E.ConsolidatedBuffsWidth + 7), -3)
			--E:SaveMoverDefaultPosition('AurasMover')
		end

		if AurasMover then
			AurasMover:Height(E.MinimapHeight)
		end
	end

	if ElvConfigToggle then
		if E.db.auras.consolidatedBuffs.enable and E.db.datatexts.minimapPanels and E.private.general.minimap.enable and E.private.auras.disableBlizzard then
			ElvConfigToggle:Show()
			ElvConfigToggle:Width(E.ConsolidatedBuffsWidth)
		else
			ElvConfigToggle:Hide()
		end
	end

	if ElvUI_ConsolidatedBuffs then
		E:GetModule('Auras'):Update_ConsolidatedBuffsSettings()
	end

	--Stop here if ElvUI Minimap is disabled.
	if not E.private.general.minimap.enable then
		return;
	end

	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end
end

function M:Initialize()
	menuFrame:SetTemplate("Transparent", true)

	self:UpdateSettings()

	if not E.private.general.minimap.enable then
		Minimap:SetMaskTexture('Textures\\MinimapMask')
		return;
	end

	local mmholder = CreateFrame('Frame', 'MMHolder', Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((Minimap:GetWidth() + 29) + E.ConsolidatedBuffsWidth)
	mmholder:Height(Minimap:GetHeight() + 53)

	Minimap:ClearAllPoints()
	if E.db.auras.consolidatedBuffs.position == "LEFT" then
		Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -2, -2)
	else
		Minimap:Point("TOPLEFT", mmholder, "TOPLEFT", 2, -2)
	end
	Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:CreateBackdrop('Default')
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript('OnEnter', function(self)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		self.location:Show()
	end)

	Minimap:HookScript('OnLeave', function(self)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		self.location:Hide()
	end)

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:FontTemplate(nil, nil, 'OUTLINE')
	Minimap.location:Point('TOP', Minimap, 'TOP', 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MinimapNorthTag:Kill()
	MinimapZoneTextButton:Hide()
	MiniMapTracking:Hide()
	MiniMapWorldMapButton:Kill()

	MiniMapMailFrame:ClearAllPoints();
	MiniMapMailFrame:Point('TOPRIGHT', Minimap, 3, 4);
	MiniMapMailBorder:Hide();
	MiniMapMailIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\mail');

	MiniMapBattlefieldFrame:ClearAllPoints();
	MiniMapBattlefieldFrame:Point('BOTTOMRIGHT', Minimap, 3, 0);
	MiniMapBattlefieldBorder:Hide();

	MiniMapInstanceDifficulty:ClearAllPoints();
	MiniMapInstanceDifficulty:SetParent(Minimap);
	MiniMapInstanceDifficulty:Point('TOPLEFT', Minimap, 'TOPLEFT', 0, 0);

	GuildInstanceDifficulty:SetParent(Minimap)

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	E:CreateMover(MMHolder, 'MinimapMover', L["Minimap"])

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	MiniMapLFGFrame:ClearAllPoints();
	MiniMapLFGFrame:Point('BOTTOMRIGHT', Minimap, 'BOTTOMRIGHT', 2, 1);
	MiniMapLFGFrameBorder:Hide();

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent('ADDON_LOADED')
	self:UpdateSettings()

	--Create Farmmode Minimap
	local fm = CreateFrame('Minimap', 'FarmModeMap', E.UIParent)
	fm:Size(E.db.farmSize)
	fm:Point('TOP', E.UIParent, 'TOP', 0, -120)
	fm:SetClampedToScreen(true)
	fm:CreateBackdrop('Default')
	fm:EnableMouseWheel(true)
	fm:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	fm:SetScript("OnMouseUp", M.Minimap_OnMouseUp)
	fm:RegisterForDrag("LeftButton", "RightButton")
	fm:SetMovable(true)
	fm:SetScript("OnDragStart", function(self) self:StartMoving() end)
	fm:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	if AstrolabeMapMonitor then AstrolabeMapMonitor:MonitorWorldMap(fm) end
	fm:Hide()
	E.FrameLocks['FarmModeMap'] = true;

	FarmModeMap:SetScript('OnShow', function()
		if BuffsMover and not E:HasMoverBeenMoved('BuffsMover') then
			BuffsMover:ClearAllPoints()
			BuffsMover:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
		end
		if DebuffsMover and not E:HasMoverBeenMoved('DebuffsMover') then
			DebuffsMover:ClearAllPoints()
			DebuffsMover:Point("TOPRIGHT", ElvUIPlayerBuffs, "BOTTOMRIGHT", 0, -3)
		end
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(FarmModeMap)
		if IsAddOnLoaded('Routes') then
			LibStub("AceAddon-3.0"):GetAddon('Routes'):ReparentMinimap(FarmModeMap)
		end

		if IsAddOnLoaded('GatherMate2') then
			LibStub('AceAddon-3.0'):GetAddon('GatherMate2'):GetModule('Display'):ReparentMinimapPins(FarmModeMap)
		end
		if Astrolabe then Astrolabe:SetTargetMinimap(FarmModeMap) end
	end)

	FarmModeMap:SetScript('OnHide', function()
		if BuffsMover and not E:HasMoverBeenMoved('BuffsMover') then
			E:ResetMovers(L["Player Buffs"])
		end
		if DebuffsMover and not E:HasMoverBeenMoved('DebuffsMover') then
			E:ResetMovers(L["Player Debuffs"])
		end
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(Minimap)
		if IsAddOnLoaded('Routes') then
			LibStub("AceAddon-3.0"):GetAddon('Routes'):ReparentMinimap(Minimap)
		end

		if IsAddOnLoaded('GatherMate2') then
			LibStub('AceAddon-3.0'):GetAddon('GatherMate2'):GetModule('Display'):ReparentMinimapPins(Minimap)
		end
		if Astrolabe then Astrolabe:SetTargetMinimap(Minimap) end
	end)


	UIParent:HookScript('OnShow', function()
		if not FarmModeMap.enabled then
			FarmModeMap:Hide()
		end
	end)
end

E:RegisterInitialModule(M:GetName())