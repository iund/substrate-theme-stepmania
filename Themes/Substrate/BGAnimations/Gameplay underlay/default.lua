local timecounter
return Def.ActorFrame{
	OnCommand=function(s)
		--tween on
		--check playerX
		--check features
		if IsPlayerCentered(GAMESTATE:GetMasterPlayerNumber()) then s:visible(false) end

		local time=IsCourseMode() and GetCurCourse():GetTotalSeconds(GAMESTATE:GetCurrentStyle():GetStepsType()) or
			not IsCourseMode() and GetCurSong():MusicLengthSeconds() or 0
		
		local rate=GAMESTATE:GetSongOptionsObject("ModsLevel_Stage"):MusicRate()

		s:SetUpdateFunction(function(s)
			timecounter:settext(SecondsToMSS(time-timecounter:GetSecsIntoEffect()/rate))
		end)
	end,
	LoadActor("bglayer"),

	LoadActor("traffic light")..{
		Condition=not IsCourseMode() and GAMESTATE:GetEasiestStepsDifficulty()=="Difficulty_Beginner"
			and not IsPlayerCentered(GAMESTATE:GetMasterPlayerNumber()),

		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-48)
	},

	LoadActor("luaplatform")..{
		Condition=GAMESTATE:IsPlayerEnabled(PLAYER_1) and IsNovice(PLAYER_1) and GAMESTATE:GetCurrentStyle():GetStyleType()~="StyleType_OnePlayerTwoSides",
		InitCommand=cmd(aux,1),
	},
	LoadActor("luaplatform")..{
		Condition=GAMESTATE:IsPlayerEnabled(PLAYER_2) and IsNovice(PLAYER_2) and GAMESTATE:GetCurrentStyle():GetStyleType()~="StyleType_OnePlayerTwoSides",
		InitCommand=cmd(aux,2),
	},
	Def.BitmapText{
		Font="_common semibold white",
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+50;shadowlength,0;diffusecolor,.36,.785,.785,1;effectclock,"music");
		OnCommand=function(s) timecounter=s Sweep.InCenter(s,-1) end,
		OffCommand=function(s) Sweep.OutCenter(s,-1) end,
	},

	Def.BitmapText{
		Font="SongCreditDisplay text",
		Condition=not IsCourseMode() and GetCurSong():GetSongDir()~="/Songs/In The Groove/Training1/" and not IsDemonstration(),
		InitCommand=cmd(playcommand,"SetText"),
		OnCommand=cmd(shadowlength,0;horizalign,"left";x,SCREEN_LEFT+96;y,SCREEN_BOTTOM-110;diffusealpha,0;linear,0.3;diffusealpha,1;sleep,3.5;linear,0.3;diffusealpha,0),
		CurrentSongChangedMessageCommand=cmd(playcommand,"SetText"),
		SetTextCommand=function(s)
			local si={}
			ForeachPlayer(function(pn)
				if not si[1] or si[1]~=GetCurSteps(pn) then table.insert(si,GetCurSteps(pn)) end
			end)
			table.sort(si,function(a,b) return DifficultyIndex[a:GetDifficulty()]<DifficultyIndex[b:GetDifficulty()] end)
			
			local stepinfo={}
			for i,s in next,si,nil do
				stepinfo[i]=string.format(
					"%s steps: %s",
					CustomDifficultyToLocalizedString(StepsToCustomDifficulty(s)),
					s:GetDescription()
				)
			end
			s:settext(
				string.format(
					"%s\n%s\n%s",
					GetCurSong():GetDisplayFullTitle(),
					GetCurSong():GetDisplayArtist(),
					join("\n",stepinfo)
				)
			)
		end
	},

	LoadActor("progress")..{
		OnCommand=function(s) Sweep.InCenter(s,-1) end,
		OffCommand=function(s) Sweep.OutCenter(s,-1) end,
	},

	Def.SongBPMDisplay{
		Condition=GAMESTATE:GetCurrentStyle():GetStyleType()~="StyleType_OnePlayerTwoSides" and not GetPref("Center1Player"),
		Name="BPMDisplay", --needed to fetch metrics
		Font="BPMDisplay bpm",
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+20;zoom,1.5),
		OnCommand=function(s) Sweep.InCenter(s,-1) end,
		OffCommand=function(s) Sweep.OutCenter(s,-1) end,
	},

	--stage:
        Def.BitmapText {
                Font="_common semibold white",
                InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-32;zoom,0.75),
		OnCommand=function(s) s:settext(GetStageText()) Sweep.InCenter(s,1) end,
		OffCommand=function(s) Sweep.OutCenter(s,1) end,
		CurrentSongChangedMessageCommand=cmd(settext,GetStageText())
        }
}
