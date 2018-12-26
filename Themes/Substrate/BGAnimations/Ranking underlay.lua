--TODO: Deduplicate stuff from here and G/Ranking ScrollerItem
local screenname="Ranking" --NOTE: GetScreen():GetName() doesn't work

local numcols=THEME:GetMetric(screenname,"NumColumns")

local leftcol,rightcol=8,308
local spacingx=(rightcol-leftcol)/(numcols-1)

local headingy=-184

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
	InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y),
	Def.Sprite{
		Texture=THEME:GetPathG("Ranking","frame"),
		InitCommand=cmd(y,-8;diffusecolor,unpack(UIColors.RankingPane);diffusealpha,CommonPaneDiffuseAlpha)
	},

	--heading:
	Def.BitmapText{
		Font=THEME:GetPathF(screenname,"steps type"),
		InitCommand=cmd(x,-204;y,headingy),
		OnCommand=cmd(settext,string.format("%s %s %s",
			--TODO: (L10n) Localize it and get rid of these awful hacks.
			split("_",GAMEMAN:GetFirstStepsTypeForGame(GAMESTATE:GetCurrentGame()))[3],
			({
				HighScoresType_AllSteps="Song",
				HighScoresType_NonstopCourses="Marathon",
				HighScoresType_OniCourses="Oni",
				HighScoresType_SurvivalCourses="Survival"
			})[THEME:GetMetric(GetScreen():GetName(),"HighScoresType")],
			THEME:GetString("ScreenHighScores","HeaderText")
		))
	},
	headings,
	Def.Quad{ --Scroller mask
		InitCommand=cmd(clearzbuffer,true;blend,"noeffect";zwrite,1;zoomto,720,320)
	}
}
