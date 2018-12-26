return Def.ActorFrame {
	Def.BitmapText {
		Font="_common black",
		TextCommand=function(s) s:settext(GetSummaryScoreCol(s:getaux(),"rank",Metrics.Summary.NumScoresDisplayed,Screen():getaux())) end,
		OnCommand=function(s) s:x(Metrics.Summary.ScoreListX.rank) s:y(Metrics.Summary.ScoreListY) s:shadowlength(0) s:vertalign("top") s:playcommand("Text") s:playcommand("Tween") end,
		TweenCommand=function(s) Tweens.Summary.ScoreList.On(s,s:getaux()) end,
		OffCommand=function(s) Tweens.Summary.ScoreList.Off(s,s:getaux()) end,
	},
	Def.BitmapText {
		Font="_common black",
		TextCommand=function(s) s:settext(GetSummaryScoreCol(s:getaux(),"name",Metrics.Summary.NumScoresDisplayed,Screen():getaux())) end,
		OnCommand=function(s) s:x(Metrics.Summary.ScoreListX.name) s:y(Metrics.Summary.ScoreListY) s:shadowlength(0) s:vertalign("top") s:playcommand("Text") s:playcommand("Tween") end,
		TweenCommand=function(s) Tweens.Summary.ScoreList.On(s,s:getaux()) end,
		OffCommand=function(s) Tweens.Summary.ScoreList.Off(s,s:getaux()) end,
	},
	Def.BitmapText {
		Font="_common black",
		TextCommand=function(s) s:settext(GetSummaryScoreCol(s:getaux(),"score",Metrics.Summary.NumScoresDisplayed,Screen():getaux())) end,
		OnCommand=function(s) s:x(Metrics.Summary.ScoreListX.score) s:y(Metrics.Summary.ScoreListY) s:shadowlength(0) s:vertalign("top") s:playcommand("Text") s:playcommand("Tween") end,
		TweenCommand=function(s) Tweens.Summary.ScoreList.On(s,s:getaux()) end,
		OffCommand=function(s) Tweens.Summary.ScoreList.Off(s,s:getaux()) end,
	},
	Def.BitmapText {
		Font="_common black",
		TextCommand=function(s) s:settext(GetSummaryScoreCol(s:getaux(),"date",Metrics.Summary.NumScoresDisplayed,Screen():getaux())) end,
		OnCommand=function(s) s:x(Metrics.Summary.ScoreListX.date) s:y(Metrics.Summary.ScoreListY) s:shadowlength(0) s:vertalign("top") s:playcommand("Text") s:playcommand("Tween") end,
		TweenCommand=function(s) Tweens.Summary.ScoreList.On(s,s:getaux()) end,
		OffCommand=function(s) Tweens.Summary.ScoreList.Off(s,s:getaux()) end,
	},
}