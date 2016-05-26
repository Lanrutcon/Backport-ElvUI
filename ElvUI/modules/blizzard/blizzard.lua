local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule('Blizzard', 'AceEvent-3.0', 'AceHook-3.0');

E.Blizzard = B;

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:AlertMovers()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:PositionVehicleFrame()
	self:PositionAltPowerBar()
	self:MoveWatchFrame()
end

E:RegisterModule(B:GetName())