local screenname=lua.GetThreadVariable("LoadingScreen")

--TODO pull metrics form metrics.ini

local metrics={
	rowheight=112,
	numfeatsshown=3,
	autonudgeinterval=THEME:GetMetric(screenname,"AutoNudgeIntervalSeconds"),
	topy=16
}

local scrollery=metrics.topy+(metrics.rowheight*metrics.numfeatsshown)/2

local mask=Def.Quad{
	InitCommand=cmd(zoomto,SCREEN_WIDTH,metrics.rowheight*metrics.numfeatsshown;
	blend,"noeffect";zwrite,1)
}

local didnudge=false --when the user manually scrolls, disable autonudge.

--setup : pull everything from statsman

local numentries=STATSMAN:GetStagesPlayed()

local allsongs={}
local allstats={}

for i=1,numentries do
	local ago=numentries+1-i
	local pss=STATSMAN:GetPlayedStageStats(ago)
	allsongs[i]=pss:GetPlayedSongs()

	allstats[i]={}
	ForeachEnabledPlayer(function(pn)
		allstats[i][pn]=pss:GetPlayerStageStats(pn)
	end)
end

local rows={}

local currow=1
local dist=math.ceil(metrics.numfeatsshown/2) --distance from middle of feat window
local moveup=math.ceil(metrics.numfeatsshown/2) --distance to move row 1 from (1 row below middle) to top row

local nudge=function(dir)
	if numentries<=metrics.numfeatsshown then return end --don't scroll if we don't need to.

	currow=clamp(currow+dir,1,numentries-moveup)

	for i=1,numentries do
		local row=rows[i]

		local oldpos=wrap(i-currow-1+dir,-dist,dist)
		local newpos=wrap(i-currow-1,-dist,dist)

		row:visible(within(newpos,-dist,dist))

		--dir: +1 means the rows are going up, -1 means the rows are going down.

		if dir>0 and newpos>oldpos or dir<0 and newpos<oldpos then
			--don't tween the row that wraps
			row:finishtweening()
		else
			row:stoptweening()
			row:decelerate(.25)
		end
		row:y(metrics.rowheight*newpos)
	end
end

scroller=Def.ActorFrame{
	InitCommand=cmd(ztestmode,"writeonfail";FitToAspect),
	OnCommand=cmd(sleep,metrics.autonudgeinterval;queuecommand,"AutoNudgeDown"),
	NudgeScrollerUpMessageCommand=function(s) didnudge=true nudge(-1) end,
	NudgeScrollerDownMessageCommand=function(s) didnudge=true nudge(1) end,
	AutoNudgeDownCommand=function(s)
		if not didnudge then 
			--wrap this one
			currow=wrap(currow+1,1,numentries)
			nudge(0)
			s:sleep(metrics.autonudgeinterval) s:queuecommand("AutoNudgeDown")
		end
	end,
}

local tnsindex={
	"TapNoteScore_W1",
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	--"TapNoteScore_W5", --NOTE: No Wayoff. TODO put it back with fa+ timing
	"TapNoteScore_Miss"
}

local function judgetext(score)
	if score then
		local judges={}
		for i,tns in next,tnsindex,nil do
			judges[i]=tostring(score:GetTapNoteScores(tns))
		end
		return join("\n",judges)
	else return "" end
end

for i=1,numentries do
	local rowy=metrics.rowheight*wrap(i-moveup,-dist,dist)

	scroller[i]=Def.ActorFrame{
		InitCommand=cmd(y,rowy),
		OnCommand=function(s) rows[i]=s end,
	}
	local row=scroller[i]
	local song=allsongs[i][1]

	ForeachEnabledPlayer(function(pn)
		local p=PlayerIndex[pn]
		local side=p*2-3
		local stats=allstats[i][pn]
		local steps=stats:GetPlayedSteps()[1]

		row[#row+1]=
			Def.Sprite{
				Texture="score scroller/scroller/score row/p"..p.." frame",
				InitCommand=function(s) s:horizalign(p==1 and "right" or "left") s:diffusealpha(CommonPaneDiffuseAlpha) ApplyUIColor(s,pn) end --TODO offset
			}
		row[#row+1]=
			Def.BitmapText{
				Font="_common white",
				Text=steps:GetMeter(),
				InitCommand=cmd(x,side*384;zoom,2;diffusecolor,DifficultyColors[steps:GetDifficulty()])
			}
		row[#row+1]=
			Def.BitmapText{
				Font="_common white",
				Text=FormatPercentScore(stats:GetPercentDancePoints()),
				InitCommand=function(s)
					s:x(side*248) s:y(-36) s:zoom(1.5)
					if stats:GetFailed() then s:diffusecolor(1,0,0,1) end --red
				end
			}
		row[#row+1]=
			Def.BitmapText{
				Font="_common semibold black",
				Text=judgetext(stats),
				InitCommand=cmd(x,side*100;zoom,.75;horizalign,p==1 and "right" or "left")
			}
		row[#row+1]=
			HighScoreListObject(pn,3,-86,-54,4,68,song,steps)..{
				InitCommand=cmd(x,side*248;y,16),
			}
		
	end)
	row[#row+1]=
		Def.Sprite{
			Texture="score scroller/scroller/score row/banner frame"
		}
	row[#row+1]=
		Def.Sprite{
			Texture=song:GetBannerPath(),
			InitCommand=cmd(scaletoclipped,192,75)
		}
	row[#row+1]=
		Def.BitmapText{
			Font="_common white",
			Text=song:GetDisplayFullTitle(),
			InitCommand=cmd(y,-46;zoom,.75;maxwidth,224)
		}
	row[#row+1]=
		Def.BitmapText{
			Font="_common white",
			Text=GetTempoString(song),
			InitCommand=cmd(y,46;zoom,.75)
		}
end

return Def.ActorFrame{
	InitCommand=cmd(x,SCREEN_CENTER_X;y,scrollery),
	mask,
	scroller
}
