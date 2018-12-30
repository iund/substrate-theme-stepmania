--TODO: Deduplicate stuff from here and G/Ranking ScrollerItem
local out=Def.ActorFrame{}
ForeachEnabledPlayer(function(p)
	local pn=PlayerIndex[p]

	out[#out+1]=Def.ActorFrame{
		InitCommand=cmd(x,SCREEN_CENTER_X+(SCREEN_WIDTH/4)*(pn*2-3);y,SCREEN_CENTER_Y+168),

		Def.Sprite{
			Texture="_global overlay/playerbox/box",
			InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha)
		},
		Def.BitmapText{
			Font="_common white",
			InitCommand=cmd(zoom,1.5;shadowlength,0;horizalign,"center";vertalign,"middle"),
			Text="Game over" --TODO L10n
		},
		Def.BitmapText{
			Font="_common semibold white",
			InitCommand=cmd(y,24;zoom,3/4;shadowlength,0;horizalign,"center";vertalign,"middle"),
			Text="Remove USB", --TODO l10n,
			Condition=not (MEMCARDMAN:GetCardState(p,"MemoryCardState_Removed")
					or MEMCARDMAN:GetCardState(p,"MemoryCardState_None")),
			["CardRemovedP"..pn.."MessageCommand"]=cmd(linear,0.3;diffusealpha,0)
		}
	}
end)
return out