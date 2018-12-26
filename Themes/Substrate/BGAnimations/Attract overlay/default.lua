local credittext

return Def.ActorFrame{
	OnCommand=cmd(SetUpdateFunction,function(s) credittext:UpdateDiffuseCos(.5) end),

	Def.BitmapText{
		Font="_common semibold white",
		InitCommand=cmd(shadowlength,0;x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-24),
			--;effectclock,"beat"), --since the itg theme doesn't do beat clock
		OnCommand=function(s) credittext=s end,
		RefreshCreditTextMessageCommand=cmd(settext,
			(function()
			local coinsneeded=GAMESTATE:GetCoinsNeededToJoin()
			return coinsneeded<1 and "Press &START;"
				or string.format("Insert %d coin%s",
				coinsneeded,
				coinsneeded~=1 and "s" or "")
			end)())
	}
}
