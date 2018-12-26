local text
local textblink=function() text:UpdateDiffuseCos(.5) end

return Def.ActorFrame {
	InitCommand=cmd(SetUpdateFunction,textblink),
	CoinModeChangedMessageCommand=function(s) SCREENMAN:SetNewScreen(Branch.Title()) end,

	Def.BitmapText {
		Font="_common semibold white",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+64;horizalign,"center";diffuse,1,1,1,1;shadowlength,0),
		Text=GetPref("MachineName"),
	},

	Def.BitmapText {
		Font="_common semibold white",
		Text=GetTitleMenuStageText(),
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+64;shadowlength,0),
	},

	--press start box
	Def.Sprite {
		Texture="box grey",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+144;diffusealpha,CommonPaneDiffuseAlpha;diffusecolor,0.2,0.2,0.2,1),
	},
	Def.BitmapText {
		InitCommand=function(s) text=s s:effectclock("beat") end,
		Font="_common white",
		Text="Press &START; to begin",
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+144;shadowlength,0;zoom,3/2),
	},

        Def.BitmapText {
                Font="_common white",
                OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-6;zoom,0.75;vertalign,"bottom"),
                Text=ProductID() 
        },

	SimpleMenu(TitleMenuEntries())
}
