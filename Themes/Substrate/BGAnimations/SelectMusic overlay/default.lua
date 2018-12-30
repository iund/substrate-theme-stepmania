local screenname=lua.GetThreadVariable("LoadingScreen")

local pane=function(pn)
	local xoffset=288*(PlayerIndex[pn]*2-3)
	local yoffset=0
	local width=224
	
	local slidewidth=width*(PlayerIndex[pn]*2-3)

	local stepschangedcommand=
		IsCourseMode() and "CurrentTrailP"..PlayerIndex[pn].."ChangedMessageCommand"
		or "CurrentStepsP"..PlayerIndex[pn].."ChangedMessageCommand"

	return Def.ActorFrame {
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+xoffset-slidewidth)
			s:y(SCREEN_CENTER_Y+yoffset)
			if GAMESTATE:IsPlayerEnabled(pn) then InitPlayer(pn) end
			s:ztestmode("writeonpass")
		end,
		OnCommand=function(s) if GAMESTATE:IsPlayerEnabled(pn) then s:playcommand("SlideIn") end end,
		OffCommand=function(s) if GAMESTATE:IsPlayerEnabled(pn) then s:playcommand("SlideOut") end end,

		CurrentSongChangedMessageCommand=cmd(RunCommandsOnChildren,function(s) s:playcommand(stepschangedcommand) end),
		
		SlideInCommand=function(s) s:playcommand("SetPlayer") s:decelerate(0.5) s:addx(slidewidth) end,
		SlideOutCommand=function(s) s:stoptweening() s:accelerate(0.5) s:addx(-slidewidth) end,

		-- Handle late join
		PlayerJoinedMessageCommand=function(s,p)
			if p.Player==pn and GAMESTATE:IsPlayerEnabled(pn) then InitPlayer(pn) s:playcommand("SlideIn") end
		end,

		Def.Sprite {
			InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha),
			Texture=THEME:GetPathG("PaneDisplay","under p"..PlayerIndex[pn]),
			SetPlayerCommand=function(s) ApplyUIColor(s,pn) end,
		},

		--player name
		Def.BitmapText {
			Font="_common white",
			OnCommand=cmd(y,-188;zoom,3/2),
			SetPlayerCommand=cmd(settext,GetPlayerName(pn))
		},

		--player mods (y-144)
		Def.BitmapText {
			Font="_common white",
			OnCommand=cmd(y,-144;maxwidth,224/.75;zoom,.75),
			Text=GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred"),
		},

		--scores (x -56/+56, y-96)
		Def.BitmapText {
			Font="_common semibold black",
			OnCommand=cmd(x,-56;y,-100;playcommand,"Set"),
			[stepschangedcommand]=cmd(playcommand,"Set"),
			SetCommand=function(s)
				local name="USB" --TODO: L10n
				local scoretext="N/A"
				if PROFILEMAN:IsPersistentProfile(pn) then
					local songcourse=not IsCourseMode() and GetCurSong() or IsCourseMode() and GetCurCourse()
					local stepstrail=not IsCourseMode() and GetCurSteps(pn) or IsCourseMode() and GetCurTrail(pn)
					local scores=songcourse and stepstrail and GetSortedScoresList(pn,songcourse,stepstrail)
					local score=scores and scores[1] and scores[1]:GetPercentDP() or 0
					scoretext=FormatPercentScore(score)
				end
				s:settext(string.format("%s\n%s",name,scoretext))
			end,
		},
		Def.BitmapText {
			Font="_common semibold black",
			OnCommand=cmd(x,56;y,-100;playcommand,"Set"),
			[stepschangedcommand]=cmd(playcommand,"Set"),
			SetCommand=function(s)
				local songcourse=not IsCourseMode() and GetCurSong() or IsCourseMode() and GetCurCourse()
				local stepstrail=not IsCourseMode() and GetCurSteps(pn) or IsCourseMode() and GetCurTrail(pn)
				local scores=songcourse and stepstrail and GetSortedScoresList(nil,songcourse,stepstrail)
				if scores then
					local name=scores[1] and not scores[1]:IsFillInMarker() and scores[1]:GetName() or "Top"
					local score=scores[1] and scores[1]:GetPercentDP() or 0
					s:settext(string.format("%s\n%s",name,FormatPercentScore(score)))
				else
					s:settext("")
				end
			end,

		},

		LoadActor("../../Graphics/_CustomDifficultyList")..{
			InitCommand=cmd(aux,PlayerIndex[pn];y,-44;visible,not IsCourseMode()) --since this is a separate lua file, pass pn via aux.
		},

		LoadActor("../../Graphics/_CustomCourseContentsList")..{
			InitCommand=cmd(aux,PlayerIndex[pn];y,-56;visible,IsCourseMode()) --since this is a separate lua file, pass pn via aux.
		},

		--chart tag - y+120
		Def.BitmapText {
			Font="_common semibold black",
			OnCommand=cmd(y,120;zoom,.75),
			[stepschangedcommand]=cmd(settext,
				not IsCourseMode() and
					GetCurSteps(pn) and GetCurSteps(pn):GetChartName()
				or IsCourseMode() and
					GetCurTrail(pn) and
						string.format("%s (%d)",
							CustomDifficultyToLocalizedString(TrailToCustomDifficulty(GetCurTrail(pn))),
							GetCurTrail(pn):GetMeter())
				or "")
		},

		Def.ActorFrame { --chart stats (don't use PaneDisplay; do it ourself.)
			--Labels:
			Def.BitmapText {
				Font="PaneDisplay labels",
				Text="Steps",
				InitCommand=cmd(x,-72;y,152;zoom,.75),
			},
			Def.BitmapText {
				Font="PaneDisplay labels",
				Text="Jumps",
				InitCommand=cmd(x,-72;y,174;zoom,.75),
			},
			Def.BitmapText {
				Font="PaneDisplay labels",
				Text="Hands",
				InitCommand=cmd(x,-72;y,196;zoom,.75),
			},
			Def.BitmapText {
				Font="PaneDisplay labels",
				Text="Mines",
				InitCommand=cmd(x,36;y,152;zoom,.75),
			},
			Def.BitmapText {
				Font="PaneDisplay labels",
				Text="Holds",
				InitCommand=cmd(x,36;y,174;zoom,.75),
			},
			Def.BitmapText {
				Font="PaneDisplay labels",
				Text="Rolls",
				InitCommand=cmd(x,36;y,196;zoom,.75),
			},

			--Numbers:
			Def.BitmapText {
				Font="PaneDisplay text",
				InitCommand=cmd(x,-16;y,152;zoom,.75),
				[stepschangedcommand]=
				cmd(settext,
					IsCourseMode() and GetCurTrail(pn)
						and tostring(GetCurTrail(pn):GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds"))
					or not IsCourseMode() and GetCurSteps(pn)
						and tostring(GetCurSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_TapsAndHolds"))
					or ""),
			},
			Def.BitmapText {
				Font="PaneDisplay text",
				InitCommand=cmd(x,-16;y,174;zoom,.75),
				[stepschangedcommand]=
				cmd(settext,
					IsCourseMode() and GetCurTrail(pn)
						and tostring(GetCurTrail(pn):GetRadarValues(pn):GetValue("RadarCategory_Jumps"))
					or not IsCourseMode() and GetCurSteps(pn)
						and tostring(GetCurSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Jumps"))
					or ""),
			},
			Def.BitmapText {
				Font="PaneDisplay text",
				InitCommand=cmd(x,-16;y,196;zoom,.75),
				[stepschangedcommand]=
				cmd(settext,
					IsCourseMode() and GetCurTrail(pn)
						and tostring(GetCurTrail(pn):GetRadarValues(pn):GetValue("RadarCategory_Hands"))
					or not IsCourseMode() and GetCurSteps(pn)
						and tostring(GetCurSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Hands"))
					or ""),
			},
			Def.BitmapText {
				Font="PaneDisplay text",
				InitCommand=cmd(x,84;y,152;zoom,.75),
				[stepschangedcommand]=
				cmd(settext,
					IsCourseMode() and GetCurTrail(pn)
						and tostring(GetCurTrail(pn):GetRadarValues(pn):GetValue("RadarCategory_Mines"))
					or not IsCourseMode() and GetCurSteps(pn)
						and tostring(GetCurSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Mines"))
					or ""),
			},
			Def.BitmapText {
				Font="PaneDisplay text",
				InitCommand=cmd(x,84;y,174;zoom,.75),
				[stepschangedcommand]=
				cmd(settext,
					IsCourseMode() and GetCurTrail(pn)
						and tostring(GetCurTrail(pn):GetRadarValues(pn):GetValue("RadarCategory_Holds"))
					or not IsCourseMode() and GetCurSteps(pn)
						and tostring(GetCurSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Holds"))
					or ""),
			},
			Def.BitmapText {
				Font="PaneDisplay text",
				InitCommand=cmd(x,84;y,196;zoom,.75),
				[stepschangedcommand]=
				cmd(settext,
					IsCourseMode() and GetCurTrail(pn)
						and tostring(GetCurTrail(pn):GetRadarValues(pn):GetValue("RadarCategory_Rolls"))
					or not IsCourseMode() and GetCurSteps(pn)
						and tostring(GetCurSteps(pn):GetRadarValues(pn):GetValue("RadarCategory_Rolls"))
					or ""),
			},
		},
--[[
		Def.ActorFrame{
			InitCommand=mmafinit,
			modsmenu
		},
--]]
	}
end

local function extrapane(pn)
	local xoffset=-288*(PlayerIndex[pn]*2-3)
	local yoffset=0
	local width=224
	
	local slidewidth=width*(PlayerIndex[pn]*2-3)

	local otherpn=pn==PLAYER_1 and PLAYER_2 or PLAYER_1
	local stepschangedcommand=
		IsCourseMode() and "CurrentTrailP"..PlayerIndex[pn].."ChangedMessageCommand"
		or "CurrentStepsP"..PlayerIndex[pn].."ChangedMessageCommand"

	--score judgs

	local topname
	local usbscore,topscore
	local usbjudge,topjudge

	return Def.ActorFrame {
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+xoffset+slidewidth)
			s:y(SCREEN_CENTER_Y+yoffset)
			s:diffusealpha(CommonPaneDiffuseAlpha) 
			if GAMESTATE:GetNumPlayersEnabled()==2 then s:visible(false) end
			s:ztestmode("writeonpass")
		end,

		OnCommand=function(s) if GAMESTATE:IsPlayerEnabled(pn) then s:playcommand("SlideIn") end end,
		OffCommand=function(s) if GAMESTATE:IsPlayerEnabled(pn) then s:playcommand("SlideOut") end end,

		SlideInCommand=function(s) s:playcommand("SetPlayer") s:decelerate(0.5) s:addx(-slidewidth) end,
		SlideOutCommand=function(s) s:stoptweening() s:accelerate(0.5) s:addx(slidewidth) end,

		-- Handle late join
		PlayerJoinedMessageCommand=function(s,p)
			if p.Player==otherpn and GAMESTATE:IsPlayerEnabled(pn) then s:playcommand("SlideOut") end
		end,

		Def.Sprite {
			Texture=THEME:GetPathB(screenname,"underlay/extra pane p"..PlayerIndex[pn]),
			SetPlayerCommand=function(s) ApplyUIColor(s,pn) end,
		},

	--Top Score details

		[stepschangedcommand]=function()
			local songcourse=not IsCourseMode() and GetCurSong() or IsCourseMode() and GetCurCourse()
			local stepstrail=not IsCourseMode() and GetCurSteps(pn) or IsCourseMode() and GetCurTrail(pn)

			local scores={}

			local topnametext="Top" --TODO l10n

			local usbscoretext="N/A" --TODO L10n
			local topscoretext=FormatPercentScore(0)

			local usbjudgetext=""
			local topjudgetext=""

			if GetCurSong() and steps then
				local tnsindex={
					"TapNoteScore_W1",
					"TapNoteScore_W2",
					"TapNoteScore_W3",
					"TapNoteScore_W4",
					--"TapNoteScore_W5", --NOTE: No Wayoff. TODO put it back with fa+ timing
					"TapNoteScore_Miss"
				}

				local function getbestscore(p) return GetSortedScoresList(p,songcourse,stepstrail)[1] end

				local function getbestjudgetext(best)
					if best then
						local judges={}
						for i,tns in next,tnsindex,nil do
							judges[i]=tostring(best:GetTapNoteScore(tns))
						end
						return join("\n",judges)
					else return "" end
				end

				--Get machine best
				local machinebest=getbestscore(nil)
				local usbbest=PROFILEMAN:IsPersistentProfile(pn) and getbestscore(pn)
	
				topnametext=machinebest and machinebest:GetName() or "Top"
				topscoretext=FormatPercentScore(machinebest and machinebest:GetPercentDP() or 0)
				usbscoretext=FormatPercentScore(usbbest and usbbest:GetPercentDP() or 0)
				topjudgetext=getbestjudgetext(machinebest)
				usbjudgetext=getbestjudgetext(usbbest)
			end
			
			topname:settext(topnametext)
			topscore:settext(topscoretext)
			usbscore:settext(usbscoretext)
			topjudge:settext(topjudgetext)
			usbjudge:settext(usbjudgetext)
		end,


		--Top row (player names)
		Def.BitmapText{
			Font="_common white",
			Text="USB",
			InitCommand=function(s) s:y(-204) s:x(-72) s:zoom(.75) usbname=s end,
		},

		--Second row (top scores)
		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:y(-204) s:x(72) s:zoom(.75) topname=s end,
		},

		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:y(-180) s:x(-72) s:zoom(.75) usbscore=s end,
		},

		--Second row (top scores)
		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:y(-180) s:x(72) s:zoom(.75) topscore=s end,
		},

		--Third row (judgments)
		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:y(-120) s:x(-72) s:zoom(.75) usbjudge=s end,
		},

		Def.BitmapText{
			Font="_common white",
			Text="Fantastic\nExcellent\nGreat\nDecent\nMiss",
			InitCommand=cmd(y,-120;zoom,.75)
		},

		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:y(-120) s:x(72) s:zoom(.75) topjudge=s end,
		},

		--machine highscore display
		HighScoreListObject(pn,3,-100,-56,12,80)..{
			InitCommand=cmd(y,-36),
		},

		--NOTE: Fortunately the radar works great in SM5!! (unlike ITG's horribly broken one)
		Def.Sprite {
--			Condition=not GAMESTATE:IsCourseMode(),
			Texture=THEME:GetPathG("GrooveRadar","under"),
			OnCommand=cmd(y,112),
			SetPlayerCommand=function(s) ApplyUIColor(s,pn) end,
		},

		Def.GrooveRadar {
--			Condition=not IsCourseMode(),
			OnCommand=cmd(y,112;SetUpdateRate,5;hurrytweening,5), --the hardcoded tweens are too slow, let's speed it up
			OffCommand=cmd(SetUpdateRate,1),
			[stepschangedcommand]=function(s)
				--Works for both songs and courses. The builtin SetFromRadarValues assumes steps.
				local rv=IsCourseMode() and GetCurTrail(pn) and GetCurTrail(pn):GetRadarValues(pn)
					or not IsCourseMode() and GetCurSteps(pn) and GetCurSteps(pn):GetRadarValues(pn)

				if not rv then return end

				local numsongs=IsCourseMode() and table.getn(GetCurTrail(pn):GetTrailEntries()) or 1
				local categories={
					"Stream",
					"Voltage",
					"Air",
					"Freeze",
					"Chaos",
				}		
				local toset={}
				for i,cat in next,categories,nil do
					toset[i]=clamp(rv:GetValue("RadarCategory_"..cat)/numsongs,0,1) --mean average
				end
				s:SetFromValues(pn,toset)
			end,
		}
	}
end

local function joinprompt(pn)
	local xoffset=288*(PlayerIndex[pn]*2-3)
	local yoffset=0
	local width=224
	
	local slidewidth=width*(PlayerIndex[pn]*2-3)

	return Def.BitmapText {
		Condition=THEME:GetMetric("GameState","AllowLateJoin") and true,
		Font="_common white",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+xoffset)
			s:y(SCREEN_CENTER_Y+yoffset)
		end,
		ModsCommand=function(s)
			if GAMESTATE:IsPlayerEnabled(pn) then 
				s:visible(false)
			else
				s:playcommand("SetText")
			end
		end,
		PlayerJoinedMessageCommand=function(s,p)
			if p.Player==pn and GAMESTATE:IsPlayerEnabled(pn) then
				s:playcommand("SetText")
				s:decelerate(0.5)
				s:addx(slidewidth)
				s:diffusealpha(0)
			end
		end,
		SetTextCommand=function(s)
			local coins=GAMESTATE:GetCoinsNeededToJoin()-GAMESTATE:GetCoins()
			s:settext(
				coins<1 and "Press &START; to join game"
				or string.format("Insert %d more %s\nto join game", coins, coins~=1 and "coins" or "coin")
			)
		end,
		CoinInsertedMessageCommand=cmd(playcommand,"SetText"),
		RefreshCreditTextMessageCommand=cmd(playcommand,"SetText")
	}
end


------

return Def.ActorFrame {
	InitCommand=cmd(draworder,2),
		
	Def.ActorFrame{ --Wrap it in its own AF to save me needing to scale the transition back
		InitCommand=cmd(FitToAspect),
	--Player info panes
		Def.Quad{
			--Panemask
			InitCommand=function(s)
				s:clearzbuffer(true)
				s:zwrite(true)
				s:blend("noeffect")
				s:zoomto(352,432)
				s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
			end
		},
		pane(PLAYER_1),
		pane(PLAYER_2),

	--Additional opposite pane (for 1-player game)
		joinprompt(GAMESTATE:GetMasterPlayerNumber()==PLAYER_1 and PLAYER_2 or PLAYER_1),
		extrapane(GAMESTATE:GetMasterPlayerNumber()),


	--Song info bar
		Def.Quad { --Stats frame container
			InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-60;zoomto,352,24;
			diffusecolor,unpack(UIColors["SelectMusicSongInfoBar"]);diffusealpha,CommonPaneDiffuseAlpha),
		},

		--[[
		Def.BitmapText { --Tempo display. Def.BPMDisplay doesn't seem to work right. TODO is there a fix?
			Font="BPMDisplay bpm",
			OnCommand=cmd(horizalign,"left";zoom,.75;x,SCREEN_CENTER_X-168;y,SCREEN_CENTER_Y-60),
			CurrentSongChangedMessageCommand=function(s)
				local song=GAMESTATE:GetCurrentSong()
				s:settext(GetTempoString(song))
			end
		},
		--]]
		-- [[
		Def.BPMDisplay { --Tempo display. Def.BPMDisplay doesn't seem to work right. TODO is there a fix?
			Font="BPMDisplay bpm",
			Name="BPMDisplay", --needed to fetch metrics
			OnCommand=cmd(horizalign,"left";zoom,.75;x,SCREEN_CENTER_X-168;y,SCREEN_CENTER_Y-60),
			CurrentSongChangedMessageCommand=cmd(SetFromGameState),
			CurrentCourseChangedMessageCommand=cmd(SetFromGameState),
		},--]]

		Def.BitmapText {
			Font="ArtistDisplay text",
			OnCommand=cmd(zoom,0.75;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-60),
			CurrentSongChangedMessageCommand=function(s) local song=GAMESTATE:GetCurrentSong() s:settext(song and song:GetDisplayArtist() or "") end,
			SelectMenuOpenedMessageCommand=cmd(stoptweening;decelerate,0.3;diffusealpha,0),
			SelectMenuClosedMessageCommand=cmd(stoptweening;decelerate,0.3;diffusealpha,1)

		},

		Def.BitmapText { --folder name (when holding select)
			Font="ArtistDisplay text",
			OnCommand=cmd(zoom,0.75;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-60;diffusealpha,0),
			CurrentSongChangedMessageCommand=function(s) local song=GAMESTATE:GetCurrentSong() s:settext(song and split("/",song:GetSongDir())[3] or "") end,
			SelectMenuOpenedMessageCommand=cmd(stoptweening;decelerate,0.3;diffusealpha,1),
			SelectMenuClosedMessageCommand=cmd(stoptweening;decelerate,0.3;diffusealpha,0)

		},

		Def.BitmapText {
			Font=THEME:GetPathF(screenname,"total time"),
			OnCommand=cmd(horizalign,"right";zoom,0.75;x,SCREEN_CENTER_X+168;y,SCREEN_CENTER_Y-60),
			CurrentSongChangedMessageCommand=function(s) local song=GAMESTATE:GetCurrentSong() s:settext(song and SecondsToMMSS(song:MusicLengthSeconds()) or "") end,
			CurrentCourseChangedMessageCommand=function(s)
				if IsCourseMode() then
					local time=GetCurCourse() and GetCurCourse():GetTotalSeconds(GAMESTATE:GetCurrentStyle():GetStepsType())
					s:settext(time and SecondsToMMSS(time) or "")
				end
			end

		},

		--Song mods (rate, haste, etc)
		Def.BitmapText {
			Font="_common bordered white",
			InitCommand=cmd(zoom,.75;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-88),
			OnCommand=function(s) 
	--			local rate=GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
	--			s:settext(rate~=1 and string.format("%1.1fx",rate) or "")
				s:settext(GAMESTATE:GetSongOptionsString())

			end
		},

		--Help guide
		LoadActor("help popup")..{
			Condition=GAMESTATE:GetCurrentStageIndex()==0 and not GAMESTATE:IsAnyHumanPlayerUsingMemoryCard(),
			InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y)
		},
		
		--select button guide
		Def.BitmapText {
			Font="_common white",
			OnCommand=cmd(shadowlength,0;zoom,.75;diffusealpha,0;finishtweening;
				x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-12;settext,
				"&MENULEFT; Easier     &START; Change sort     &MENURIGHT; Harder"), --TODO L10n
			SelectMenuOpenedMessageCommand=cmd(stoptweening;linear,0.15;diffusealpha,1),
			SelectMenuClosedMessageCommand=cmd(stoptweening;linear,0.15;diffusealpha,0)
		},
	},
	LoadActor(THEME:GetPathB(THEME:GetMetric("SelectMusic","Fallback"),"overlay")), --TODO correct fallback without hardcoding it? 
}

--[[


	TwoPartConfirmCanceled

--]]