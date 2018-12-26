local barheight=40
local barwidth=720

return Def.ActorFrame{
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_TOP+20),
	
	SongProgressWidth=728*(SCREEN_WIDTH/853), --728,
	SongProgressHeight=40,
	SongProgressXY={0,SCREEN_TOP+20},

	Def.Quad{ --frame
		OnCommand=cmd(diffuse,unpack(UIColors["ProgressBackground"]);zoomto,barwidth,barheight)
	},

	Def.SongMeterDisplay{
		StreamWidth=barwidth,
		Stream=Def.Quad {
			InitCommand=cmd(zoomtoheight,40;diffusecolor,unpack(UIColors["ProgressFill"]))
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
		InitCommand=cmd(Load,"Gameplay StepsDisplay";x,-barwidth/2),
		OnCommand=cmd(SetFromGameState,PLAYER_1),
		CurrentStepsP1ChangedMessageCommand=cmd(SetFromGameState,PLAYER_1),
		CurrentTrailP1ChangedMessageCommand=cmd(SetFromGameState,PLAYER_1)
	},

	Def.StepsDisplay{
		Condition=GAMESTATE:IsPlayerEnabled(PLAYER_2),
		InitCommand=cmd(Load,"Gameplay StepsDisplay";x,barwidth/2),
		OnCommand=cmd(SetFromGameState,PLAYER_2),
		CurrentStepsP2ChangedMessageCommand=cmd(SetFromGameState,PLAYER_2),
		CurrentTrailP2ChangedMessageCommand=cmd(SetFromGameState,PLAYER_2)
	}
}
