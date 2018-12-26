return Def.ActorFrame {
	LoadActor("score row")..{
		Cond="Scores[1] and Scores[1].Song",
		OnCommand=function(s) s:y(Metrics.Summary.ScoreHeight*Screen():getaux()) end,
	},
	LoadActor("score row")..{
		Cond="Scores[2] and Scores[2].Song",
		OnCommand=function(s) s:y(Metrics.Summary.ScoreHeight*Screen():getaux()) end,
	},
	LoadActor("score row")..{
		Cond="Scores[3] and Scores[3].Song",
		OnCommand=function(s) s:y(Metrics.Summary.ScoreHeight*Screen():getaux()) end,
	},
	LoadActor("score row")..{
		Cond="Scores[4] and Scores[4].Song",
		OnCommand=function(s) s:y(Metrics.Summary.ScoreHeight*Screen():getaux()) end,
	},
}