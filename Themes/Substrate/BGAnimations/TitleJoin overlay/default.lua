
local text
local textblink=function() text:UpdateDiffuseCos(.5) end

local padspacing=80
local pady=SCREEN_CENTER_Y+140

return Def.ActorFrame {
	InitCommand=cmd(SetUpdateFunction,textblink),

	--Logo and very basic information
	LoadActor("../_logo")..{
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-64),
	},

	Def.BitmapText {
		Font="_common white",
		OnCommand=cmd(x,SCREEN_CENTER_X;vertalign,"top";y,SCREEN_TOP+8;zoom,.75),
		Text=string.format("%d songs in %d folders",
			SONGMAN:GetNumSelectableAndUnlockedSongs(),
			SONGMAN:GetNumSongGroups())
	},

	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+56;shadowlength,0),
		Text=GetPref("MachineName"),
	},
	Def.BitmapText {
		Font="_common semibold white",
		Text=GetTitleMenuStageText(),
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-64;shadowlength,0),
	},

	--Press start box
	Def.Sprite {
		Texture="box grey",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;diffuse,.2,.2,.2,CommonPaneDiffuseAlpha),
	},
	Def.BitmapText {
		InitCommand=function(s) text=s s:effectclock("beat") end,
		Font="_common white",
		Text="Press &START; to begin",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;shadowlength,0;zoom,3/2),
	},

	--Pads
	LoadActor("../../Graphics/_platform large")..{
		InitCommand=cmd(aux,1;x,SCREEN_CENTER_X-padspacing;y,pady),
	},
	LoadActor("../../Graphics/_platform large")..{
		InitCommand=cmd(aux,2;x,SCREEN_CENTER_X+padspacing;y,pady),
	},
        Def.BitmapText {
                Font="_common white",
                OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-6;zoom,0.75;vertalign,"bottom"),
		Text=ProductID()
	}
}
