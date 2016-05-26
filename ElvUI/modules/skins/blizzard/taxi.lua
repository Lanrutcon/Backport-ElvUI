local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

S:RegisterSkin("ElvUI", function()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true) then return; end

	TaxiFrame:StripTextures();
	TaxiFrame:CreateBackdrop("Transparent");
	TaxiFrame:SetScale(0.8)

	S:HandleCloseButton(TaxiFrameCloseButton);

	TaxiRouteMap:CreateBackdrop("Default");
end);