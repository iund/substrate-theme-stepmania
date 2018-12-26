local songboxspacingy=64
local songboxspacingx=120

local timetext
local updatetime=function(s)
	timetext:settext(
		string.format("%04d/%02d/%02d %02d:%02d:%02d",
			Year(),MonthOfYear(),DayOfMonth(),
			Hour(),Minute(),Second()))
end

local out=Def.ActorFrame {
	OnCommand=cmd(SetUpdateFunction,updatetime),
	LoadActor(THEME:GetPathB(THEME:GetMetric("Evaluation","Fallback"),"overlay"))..{
		InitCommand=cmd(aux,-1),
		OnCommand=function(s) Sweep.InCenter(s,-1) end,
		OffCommand=function(s) Sweep.OutCenter(s,-1) end,
	},

--Top info
	Def.BitmapText {
		Font="_common white",
		OnCommand=cmd(shadowlength,0;x,SCREEN_WIDTH*.25;y,SCREEN_TOP+12;zoom,.75),
		Text=GetPref("MachineName"),
	},

	Def.BitmapText { --TODO working clock?
		Font="_common white",
		InitCommand=function(s) timetext=s end,
		OnCommand=cmd(shadowlength,0;x,SCREEN_WIDTH*.75;y,SCREEN_TOP+12;zoom,.75),
	},

--Song box
	Def.ActorFrame {
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-136),

		OnCommand=function(s) Sweep.InCenter(s,-1) end,
		OffCommand=function(s) Sweep.OutCenter(s,-1) end,

		Def.Sprite {
			Texture=THEME:GetPathG("Evaluation","banner frame"),
			InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha)
		},
		Def.Sprite {
			Texture=IsCourseMode() and GetCurCourse():GetBannerPath() or GetCurSong():GetBannerPath(),
			InitCommand=cmd(scaletoclipped,256,100)
		},
	--Upper text
		Def.BitmapText {
			Font="_common white",
			Text=IsCourseMode() and GetCurCourse():GetDisplayFullTitle() or GetCurSong():GetDisplayFullTitle(),
		--LoadActor("../../Graphics/_song name")..{
			InitCommand=cmd(y,-songboxspacingy;zoom,.75),
		},
	--Lower text
		Def.BitmapText {
			OnCommand=cmd(x,-songboxspacingx;y,songboxspacingy;horizalign,"left";zoom,.75),
			Text=GetTempoString(GetCurSong()),
			Font="_common white",
		},
		--Ratemod text only ("1.1x rate"). TODO 
		Def.BitmapText {
			OnCommand=cmd(x,songboxspacingx;y,songboxspacingy;horizalign,"center";zoom,.75),
			Text=GAMESTATE:GetSongOptionsString(),
			--(tonumber(Env().SongMods.Rate) or 1)~=1 and sprintf("%1.1fx Rate", tonumber(Env().SongMods.Rate) or 1) or "",
			Font="_common white",
		},

		Def.BitmapText {
			OnCommand=cmd(x,songboxspacingx;y,songboxspacingy;horizalign,"right";zoom,.75),
			Text=SecondsToMMSS(GetCurSong():MusicLengthSeconds() or 0),
			Font="_common white",
		},
	}
}	
local panexoffset=208
local paney=SCREEN_CENTER_Y+88

ForeachEnabledPlayer(function(pn)
	local l=#out+1
	local pi=PlayerIndex[pn]
	local side=pi*2-3 --NOTE: Idiom to get -1 if P1, +1 if P2. 

	local pss=STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)	

--Score box
	out[l]=Def.ActorFrame {
		InitCommand=cmd(x,SCREEN_CENTER_X+side*276;y,SCREEN_CENTER_Y-136),
		OnCommand=function(s) Sweep.In(s,pi) end,
		OffCommand=function(s) Sweep.Out(s,pi) end,

		Def.Sprite {
			Texture="scorebox",
			InitCommand=function(s) ApplyUIColor(s,pn) end,
			OnCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha)
		},

		--Don't specify X offsets since these must all align vertically:
		
		Def.BitmapText {
			OnCommand=cmd(y,-64),
			Text=GetPlayerName(pn),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(y,-16;zoom,2.25),
			Text=FormatPercentScore(pss:GetPercentDancePoints()),
			Font="_common white",
		},

		HighScoreListObject(pn,3,-112,-64,16,92)..{
			InitCommand=cmd(y,48)
		}
	}

--Player pane.
	local statslabelalign=pi==1 and "right" or "left"
	local judgelabelalign=pi==1 and "left" or "right"

	local judgelabelx=-40*side
	local judgevaluex=-168*side
	local judgey=-84
	local judgeyspacing=24

	local statslabelx=80*side
	local statsvaluex=24*side
	local statsy=-84
	local statsyspacing=24

	local function judge(tns) return pss:GetTapNoteScores(tns) end

	local function stats(rv)
		local hitted=pss:GetRadarActual():GetValue(rv)
		local total=pss:GetRadarPossible():GetValue(rv)
		return string.format("%d/%d",hitted,total)
	end

	out[l+1]=Def.ActorFrame{
		InitCommand=cmd(x,SCREEN_CENTER_X+side*panexoffset;y,paney),
		OnCommand=function(s) Sweep.In(s,pi) end,
		OffCommand=function(s) Sweep.Out(s,pi) end,

		Def.Sprite {
			Texture="../Evaluation underlay/pane p"..pi,
			InitCommand=function(s) ApplyUIColor(s,pn) end,
			OnCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha)
		},
				
	--Judge Labels
		Def.BitmapText {
			OnCommand=cmd(horizalign,judgelabelalign;zoom,.75;x,judgelabelx;y,judgey),
			Text="Fantastic",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,judgelabelalign;zoom,.75;x,judgelabelx;y,judgey+judgeyspacing),
			Text="Excellent",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,judgelabelalign;zoom,.75;x,judgelabelx;y,judgey+judgeyspacing*2),
			Text="Great",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,judgelabelalign;zoom,.75;x,judgelabelx;y,judgey+judgeyspacing*3),
			Text="Decent",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,judgelabelalign;zoom,.75;x,judgelabelx;y,judgey+judgeyspacing*4),
			Text="Miss",
			Font="_common white",
		},

	--Judge Values
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,judgevaluex;y,judgey),
			Text=judge("TapNoteScore_W1"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,judgevaluex;y,judgey+judgeyspacing),
			Text=judge("TapNoteScore_W2"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,judgevaluex;y,judgey+judgeyspacing*2),
			Text=judge("TapNoteScore_W3"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,judgevaluex;y,judgey+judgeyspacing*3),
			Text=judge("TapNoteScore_W4"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,judgevaluex;y,judgey+judgeyspacing*4),
			Text=judge("TapNoteScore_Miss"),
			Font="_common white",
		},

	--Stats Labels
		Def.BitmapText {
			OnCommand=cmd(horizalign,statslabelalign;zoom,.75;x,statslabelx;y,statsy),
			Text="Jumps",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,statslabelalign;zoom,.75;x,statslabelx;y,statsy+statsyspacing),
			Text="Holds",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,statslabelalign;zoom,.75;x,statslabelx;y,statsy+statsyspacing*2),
			Text="Mines",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,statslabelalign;zoom,.75;x,statslabelx;y,statsy+statsyspacing*3),
			Text="Hands",
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(horizalign,statslabelalign;zoom,.75;x,statslabelx;y,statsy+statsyspacing*4),
			Text="Rolls",
			Font="_common white",
		},

	--Stats Values
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,statsvaluex;y,statsy),
			Text=stats("RadarCategory_Jumps"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,statsvaluex;y,statsy+statsyspacing),
			Text=stats("RadarCategory_Holds"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,statsvaluex;y,statsy+statsyspacing*2),
			Text=stats("RadarCategory_Mines"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,statsvaluex;y,statsy+statsyspacing*3),
			Text=stats("RadarCategory_Hands"),
			Font="_common white",
		},
		Def.BitmapText {
			OnCommand=cmd(zoom,.75;x,statsvaluex;y,statsy+statsyspacing*4),
			Text=stats("RadarCategory_Rolls"),
			Font="_common white",
		},

		--meter
		Def.BitmapText {
			OnCommand=cmd(x,168*side;y,-96;zoom,2;diffusecolor,DifficultyColors[GetCurSteps(pn):GetDifficulty()]),
			Text=GetCurSteps(pn):GetMeter(),
			Font="_common white",
		},

		--chart tag
		Def.BitmapText {
			OnCommand=cmd(x,-16*side;y,-116;zoom,.75),
			Text=GetCurSteps(pn):GetChartName(),
			Font="_common semibold black",
		},

		--mods list
		Def.BitmapText {
			OnCommand=cmd(y,44;zoom,.75),
			Text=GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred"),
			Font="_common white",
		},

		--combined life/combo graph. works the same as in 3.95
		Def.ActorFrame {
			InitCommand=cmd(y,92),
			Def.GraphDisplay {
				OnCommand=cmd(Load,"LifeGraph";Set,STATSMAN:GetCurStageStats(),pss;RunCommandsOnChildren,function(c) c:zbias(1) c:zbuffer(true) end),
			},
			Def.ComboGraph {
				OnCommand=cmd(Load,"ComboGraph";Set,STATSMAN:GetCurStageStats(),pss;ztestmode,"writeonfail")
			},
		}

		--TODO- Life plot line?
		--TODO- Chart density plot (filled graph? brightness?)
		--TODO- Scatter graph? using ActorMultiVertex?
	}

	--Camera flash.
	out[l+2]=Def.Quad {
		["P"..PlayerIndex[pn].."SelectPressInputMessageCommand"]=cmd(finishtweening;diffusealpha,self:getaux();decelerate,0.5;diffusealpha,0;aux,0),
		Command=cmd(stretchtoscreen;diffuse,.8,.8,.8,0;aux,PROFILEMAN:IsPersistentProfile(pn) and 1 or 0),
	}
	
end)

return out


