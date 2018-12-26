return Def.ActorFrame {
	InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y),
--[[
		LoadActor("center frame")..{
		OnCommand=function(s)
			Actor[GAMESTATE:GetMasterPlayerNumber()==PLAYER_1 and "cropleft" or "cropright"](s,0.5)
			s:visible(GAMESTATE:GetNumPlayersEnabled()==1)
			s:ztestmode("writeonpass")
			s:diffusealpha(CommonPaneDiffuseAlpha)
			ApplyUIColor(s,GAMESTATE:GetMasterPlayerNumber())
		end,
		PlayerJoinedMessageCommand=function(s)	
			if GAMESTATE:GetNumPlayersEnabled()==2 then
				s:visible(false)
			end
		end
	},
--]]
--[[
	Def.Sprite{
		Texture="ssm sidecap",
		InitCommand=cmd(
			visible,GAMESTATE:GetNumPlayersEnabled()==1;
			x,-192*(PlayerIndex[GAMESTATE:GetMasterPlayerNumber()]*2-3);
			zoomx,-(PlayerIndex[GAMESTATE:GetMasterPlayerNumber()]*2-3);
			diffuse,0,0,0,CommonPaneDiffuseAlpha)
	}
--]]
}