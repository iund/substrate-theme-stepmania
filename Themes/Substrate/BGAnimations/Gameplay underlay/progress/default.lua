local screenname=lua.GetThreadVariable("LoadingScreen")

local barheight=THEME:GetMetric(screenname,"ProgressBarHeight")
local barwidth=THEME:GetMetric(screenname,"ProgressBarWidth")

return Def.ActorFrame{
	InitCommand=cmd(
		x,THEME:GetMetric(screenname,"ProgressBarX");
		y,THEME:GetMetric(screenname,"ProgressBarY")),

	Def.Quad{ --frame
		OnCommand=cmd(diffuse,unpack(UIColors["ProgressBackground"]);zoomto,barwidth,barheight)
	},

	Def.SongMeterDisplay{
		StreamWidth=barwidth,
		Stream=Def.Quad {
			InitCommand=cmd(zoomtoheight,barheight;diffusecolor,unpack(UIColors["ProgressFill"]))
		},
		Tip=Def.Actor{},
	},

	Def.Sprite{
		Texture="meter icon",
		OnCommand=cmd(x,-barwidth/2)
	},

	Def.Sprite{
		Texture="meter icon",
		OnCommand=cmd(x,barwidth/2)
	},

	--NOTE: SM5 already has a StepsDisplayGameplay actor, but it's here instead to align it with the progress bar caps.
	Def.StepsDisplay{
		Condition=GAMESTATE:IsPlayerEnabled(PLAYER_1),
		InitCommand=cmd(Load,screenname.." StepsDisplay";x,-barwidth/2), --TODO unhardcode
		OnCommand=cmd(SetFromGameState,PLAYER_1),
		CurrentStepsP1ChangedMessageCommand=cmd(SetFromGameState,PLAYER_1),
		CurrentTrailP1ChangedMessageCommand=cmd(SetFromGameState,PLAYER_1)
	},

	Def.StepsDisplay{
		Condition=GAMESTATE:IsPlayerEnabled(PLAYER_2),
		InitCommand=cmd(Load,screenname.." StepsDisplay";x,barwidth/2), --TODO unhardcode
		OnCommand=cmd(SetFromGameState,PLAYER_2),
		CurrentStepsP2ChangedMessageCommand=cmd(SetFromGameState,PLAYER_2),
		CurrentTrailP2ChangedMessageCommand=cmd(SetFromGameState,PLAYER_2)
	}
}
