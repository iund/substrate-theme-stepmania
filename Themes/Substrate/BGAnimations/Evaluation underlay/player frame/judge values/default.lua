return Def.ActorFrame {
	Def.Actor {
		OnCommand=%function(s) Capture.ActorFrame.ApplyPNToChildren(s,s:getaux()) end,
		CaptureCommand=%Capture.ActorFrame.CaptureInternal,
	},
	Def.BitmapText {
		OffCommand=%function(s) Tweens.Evaluation.JudgeLabels.Off(s,s:getaux(),1) end,
		TweenCommand=%function(s) Tweens.Evaluation.JudgeLabels.On(s,s:getaux(),1) end,
		OnCommand=cmd(hidden,Bool[Metrics.Evaluation.NumJudgeRows<=1];x,Metrics.Evaluation.JudgeLabelsX[self:getaux()];y,EvaluationJudgeYPos(1);playcommand,Tween),
		Text=Languages[CurLanguage()].ScreenEvaluation.PlayerFrame.Fantastic,
		Font="_common white",
	},
	Def.BitmapText {
		OffCommand=%function(s) Tweens.Evaluation.JudgeLabels.Off(s,s:getaux(),2) end,
		TweenCommand=%function(s) Tweens.Evaluation.JudgeLabels.On(s,s:getaux(),2) end,
		OnCommand=cmd(hidden,Bool[Metrics.Evaluation.NumJudgeRows<=2];x,Metrics.Evaluation.JudgeLabelsX[self:getaux()];y,EvaluationJudgeYPos(2);playcommand,Tween),
		Text=Languages[CurLanguage()].ScreenEvaluation.PlayerFrame.Excellent,
		Font="_common white",
	},
	Def.BitmapText {
		OffCommand=%function(s) Tweens.Evaluation.JudgeLabels.Off(s,s:getaux(),3) end,
		TweenCommand=%function(s) Tweens.Evaluation.JudgeLabels.On(s,s:getaux(),3) end,
		OnCommand=cmd(hidden,Bool[Metrics.Evaluation.NumJudgeRows<=3];x,Metrics.Evaluation.JudgeLabelsX[self:getaux()];y,EvaluationJudgeYPos(3);playcommand,Tween),
		Text=Languages[CurLanguage()].ScreenEvaluation.PlayerFrame.Great,
		Font="_common white",
	},
	Def.BitmapText {
		OffCommand=%function(s) Tweens.Evaluation.JudgeLabels.Off(s,s:getaux(),4) end,
		TweenCommand=%function(s) Tweens.Evaluation.JudgeLabels.On(s,s:getaux(),4) end,
		OnCommand=cmd(hidden,Bool[Metrics.Evaluation.NumJudgeRows<=4];x,Metrics.Evaluation.JudgeLabelsX[self:getaux()];y,EvaluationJudgeYPos(4);playcommand,Tween),
		Text=Languages[CurLanguage()].ScreenEvaluation.PlayerFrame.Decent,
		Font="_common white",
	},
	Def.BitmapText {
		OffCommand=%function(s) Tweens.Evaluation.JudgeLabels.Off(s,s:getaux(),5) end,
		TweenCommand=%function(s) Tweens.Evaluation.JudgeLabels.On(s,s:getaux(),5) end,
		OnCommand=cmd(hidden,Bool[Metrics.Evaluation.NumJudgeRows<=5];x,Metrics.Evaluation.JudgeLabelsX[self:getaux()];y,EvaluationJudgeYPos(5);playcommand,Tween),
		Text=Languages[CurLanguage()].ScreenEvaluation.PlayerFrame.WayOff,
		Font="_common white",
	},
	Def.BitmapText {
		OffCommand=%function(s) Tweens.Evaluation.JudgeLabels.Off(s,s:getaux(),Metrics.Evaluation.NumJudgeRows) end,
		TweenCommand=%function(s) Tweens.Evaluation.JudgeLabels.On(s,s:getaux(),Metrics.Evaluation.NumJudgeRows) end,
		OnCommand=cmd(x,Metrics.Evaluation.JudgeLabelsX[self:getaux()];y,EvaluationJudgeYPos(Metrics.Evaluation.NumJudgeRows);playcommand,Tween),
		Text=Languages[CurLanguage()].ScreenEvaluation.PlayerFrame.Miss,
		Font="_common white",
	},
}