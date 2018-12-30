local screenname=lua.GetThreadVariable("LoadingScreen")

local numcols=THEME:GetMetric(screenname,"NumColumns")
local leftcol=THEME:GetMetric(screenname,"ScoreLeftOffsetX")
local rightcol=THEME:GetMetric(screenname,"ScoreRightOffsetX")
local spacingx=(rightcol-leftcol)/(numcols-1)

local headingy=THEME:GetMetric(screenname,"HeadingOffsetY")

local maskheight=368 --TODO: put in metrics?

local headings=Def.ActorFrame{
	InitCommand=cmd(y,headingy)
}

for i=1,numcols do
	headings[i]=Def.BitmapText{
		InitCommand=function(s)
			s:x(leftcol+spacingx*(i-1))
			local st=THEME:GetMetric(screenname,"ColumnStepsType"..tostring(i))
			local diff=THEME:GetMetric(screenname,"ColumnDifficulty"..tostring(i))
			s:settext(CustomDifficultyToLocalizedString(GetCustomDifficulty(st,diff)))
			s:diffusecolor(DifficultyColors[diff])
		end,
		Font="_common semibold white",
	}
end

return Def.ActorFrame{
	InitCommand=THEME:GetMetric(screenname,"ScrollerOnCommand"),
	Def.Sprite{
		Texture=THEME:GetPathG(screenname,"frame"),
		InitCommand=cmd(y,-8;diffusecolor,unpack(UIColors.RankingPane);diffusealpha,CommonPaneDiffuseAlpha)
	},

	--heading:
	Def.BitmapText{
		Font=THEME:GetPathF(screenname,"steps type"),
		InitCommand=cmd(x,THEME:GetMetric(screenname,"ItemTitleOffsetX");y,headingy),
		OnCommand=cmd(settext,string.format("%s %s %s",
			--TODO: (L10n) Localize it and get rid of these awful hacks.
			split("_",GAMEMAN:GetFirstStepsTypeForGame(GAMESTATE:GetCurrentGame()))[3],
			({
				HighScoresType_AllSteps="Song",
				HighScoresType_NonstopCourses="Marathon",
				HighScoresType_OniCourses="Oni",
				HighScoresType_SurvivalCourses="Survival"
			})[THEME:GetMetric(screenname,"HighScoresType")],
			THEME:GetString("ScreenHighScores","HeaderText") --NOTE: Not ideal l10n but it'll do
		))
	},
	headings,
	Def.Quad{ --Scroller mask
		InitCommand=cmd(clearzbuffer,true;blend,"noeffect";zwrite,1;zoomto,SCREEN_WIDTH,maskheight)
	}
}
