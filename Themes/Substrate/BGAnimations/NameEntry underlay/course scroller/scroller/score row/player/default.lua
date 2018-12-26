return Def.ActorFrame {
	LoadActor("score list")..{
		OnCommand=function(s) Actor.xy(s,s:getaux()==1 and -248 or 248,-32) end,
	},
	Def.BitmapText {
		Font="_common black",
		TextCommand=function(s) s:horizalign(({"right","left"})[s:getaux()] or "center") s:settext(join("\n",Scores[Screen():getaux()][1].Judge)) end,
		OnCommand=function(s) s:x(self:getaux()==1 and -104 or 104) s:shadowlength(0) s:zoom(15/20) s:playcommand("Text") end,
	},
	Def.BitmapText {
		Font="_common white",
		TextCommand=function(s) s:settext(FormatPercentScore(Scores[Screen():getaux()][1].Percent/100)) if Scores[Screen():getaux()][1].Failed then s:diffusecolor(1,0,0,1) end end,
		OnCommand=function(s) s:y(-42) s:x(self:getaux()==1 and -248 or 248) s:shadowlength(0) s:playcommand("Text") end,
	},
	Def.BitmapText {
		Font="_common white",
		TextCommand=function(s) s:settext(Scores[Screen():getaux()][1].Meter) s:diffuse(unpack(difficultyColors[Scores[Screen():getaux()][1].Steps:GetDifficulty()])) end,
		OnCommand=function(s) s:x(self:getaux()==1 and -384 or 384) s:zoom(2) s:shadowlength(0) s:playcommand("Text") end,
	},
}