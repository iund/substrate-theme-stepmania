-----------------------
-- Theme metrics
-----------------------

-----TODO: Move these out of here and into system profile config

-- Select music

	DifficultyCursorTween=function(c) c:stoptweening() c:decelerate(0.2) end

-- ScreenStage

	stageSeconds=2.5

-- Judge and combo tween zoom values (corresponds to the JudgeAnimation mod options - eg Small, Medium, Big, Static)

	judgeTweenSizes = { { x=1.1, y=1.1 }, { x=1.3, y=1.3 }, { x=1.3, y=1.7 }, { x=1, y=1 } }
	judgeTweenBaseSize = 1
	judgeZoom = 0.75
	--judgeZoom = 1

	comboTweenSizes = { {x=1, y=1}, {x=1.1, y=1.1}, {x=1.2, y=1.2}, {x=1, y=1} }
	holdTweenSizes = { 1.05, 1.1, 1.2, 1 }

-- Playfield (Y coords are relative to screen centre)

	--BUG: In portrait aspect, ReceptorArrowsY positions correctly in Overhead,
	--     but the receptor row is positioned wrong in Hallway/Distant.
	--     Maybe force overhead in portrait aspect?
	--     or use sin/cos to move them correctly

	receptorArrowsY={ Normal=96-SCREEN_CENTER_Y, Reverse=SCREEN_CENTER_Y-48 }

	-- Notefield's Y is middle of normal/reverse receptors. The targets in "dance" are 64px square.
	local receptorHeight=64
	local receptorArrowsMiddle=(receptorArrowsY.Normal+receptorArrowsY.Reverse)/2
	
	notefieldDrawY = {
		Top    = SCREEN_TOP-receptorHeight*2-receptorArrowsMiddle,
		Bottom = SCREEN_BOTTOM+receptorHeight-receptorArrowsMiddle
	} -- relative to targets


	--comboY={ Normal=240-SCREEN_CENTER_Y, Reverse=240-SCREEN_CENTER_Y }
	comboY={ Normal=255-SCREEN_CENTER_Y, Reverse=220-SCREEN_CENTER_Y,
	         NormalCenteredOffset=0, ReverseCenteredOffset=0 } -- TODO
	
	comboLabelOffsetY=28


	--JudgeY = { Normal=receptorArrowsY.Normal+84, Reverse=receptorArrowsY.Reverse-84 } -- centerY-60
	--JudgeY = { Normal=receptorArrowsY.Normal+114, Reverse=receptorArrowsY.Reverse-114 }
	JudgeY = { Normal=receptorArrowsY.Normal+100, Reverse=receptorArrowsY.Reverse-114,
	           NormalCenteredOffset=0, ReverseCenteredOffset=0 } -- TODO
	holdJudgeY = { Normal=receptorArrowsY.Normal+48, Reverse=receptorArrowsY.Reverse-48 }

	comboZoom = { Min = 1/2, Max = 1/2, MaxZoomCombo = 500 }

	forcedNoviceMods = { OPENITG and '1x' or 'C120', 'Overhead', 'Cel' }

-- Lifebar
	
	lifebarHeight = SCREEN_HEIGHT-160 --not including end caps
	lifebarWidth = 32
	lifebarDangerThreshold = 0.25
	function lifebarInitialFill() return 0.5 end --todo, in-game option to customise the initial lifebar fill

	assistTickOffset = 0

-- Screens

	EvaluationJudgeYPos=function(pos) local top=Metrics.Evaluation.JudgeTopY local bot=Metrics.Evaluation.JudgeBottomY return top-((top-bot)/(Metrics.Evaluation.NumJudgeRows-1))*(pos-1) end
	EvaluationStatsYPos=function(pos) local top=Metrics.Evaluation.StatsTopY local bot=Metrics.Evaluation.StatsBottomY return top-((top-bot)/(Metrics.Evaluation.NumStatsRows-1))*(pos-1) end
