	Tweens.Gameplay = {
		Stage = {
 			On = function(s) s:diffuse(1,1,1,1) s:shadowlength(0) s:zoom(15/20) Sweep.InCenter(s,1) end,
			Off = function(s) Sweep.OutCenter(s,1) end
		},
		SongName = {
 			On = function(s) s:zoom(15/20) Sweep.InCenter(s,1) end,
			Off = function(s) Sweep.OutCenter(s,1) end
		},

		--Top bar
		LifeFrame = {
			On=function(s) s:vertalign("middle") s:queuecommand("Set") Sweep.InCenter(s,-1) end,
			Off=function(s) Sweep.OutCenter(s,-1) end
		},
		ScoreFrame = {
 			On = function(s) s:visible(Bool[false]) end,
			Off = function(s) end
		},
		StageFrame = {
 			On = function(s) s:visible(Bool[false]) end,
			Off = function(s) end,
		},
		BPM = {
 			On = function(s) if GAMESTATE:PlayerUsingBothSides() then s:zoom(0) else s:diffuse(1,1,1,1) s:zoom(1.5) end Sweep.InCenter(s,-1) end,
			Off = function(s) Sweep.OutCenter(s,-1) end
		},
		Score = {
			On = function(s,pn) Sweep.InCenter(s,-1) end,
			Off = function(s,pn) Sweep.OutCenter(s,-1) end
		},
		SongProgress = {
			On=function(s) s:horizalign("center") s:vertalign("middle") Sweep.InCenter(s,-1) end,
			Off=function(s) Sweep.OutCenter(s,-1) end,
		},
		DifficultyMeter = {
			On=function(s,pn,reverse) s:diffusealpha(1) Sweep.InCenter(s,-1) end,
			Off=function(s,pn,reverse) Sweep.OutCenter(s,-1) end,
		},
		DifficultyMeterText = { --child of DifficultyMeter; just put formatting here.
			On=function(s,pn,reverse) s:shadowlength(0) s:zoom(1.5) end,
			Off=function(s,pn,reverse) end,
		},

		SongTimer={
			On = function(s,pn) Sweep.InCenter(s,-1) end,
			Off = function(s,pn) Sweep.OutCenter(s,-1) end
		},
		
		LyricText = {
			In=function(s) s:shadowlength(0) s:y(32) s:diffusealpha(0) s:finishtweening() s:decelerate(0.3) s:addy(-16) s:diffusealpha(1) end,
			Out=function(s) s:accelerate(0.3) s:diffusealpha(0) s:addy(-16) end,
		},
		
		--Lifebar
		Life = {
			On = function(s,pn)
				s:rotationz(-90) Sweep.In(s,pn)
				lifebar[pn].dangerglow:visible(Bool[false])
				s:SetUpdateRate(12) s:hurrytweening(12) -- faster lifebar fill/fall
			end,
			Update = function(s,pn)
				if lifebar and lifebar[pn] then
					local d=lifebar[pn].dangerglow
					local f=lifebar[pn].frame
					local math=math
					d:diffusealpha(f:getaux()*math.adcos(d:GetSecsIntoEffect()))
				end
			end,
			Danger = {
				Show = function(s,pn)
					if lifebar and lifebar[pn] then
						local lb=lifebar[pn]
						local d=lb.dangerglow
						local f=lb.frame
						--d:diffusecolor(.5,0,0,0)
						f:stoptweening() f:linear(0.25) f:aux(1)
							
						lb.stream.normal:diffusecolor(1,.25,.25,1)
					end
				end,	
				Hide = function(s,pn)
					if lifebar and lifebar[pn] then
						local lb=lifebar[pn]
						local d=lb.dangerglow
						local f=lb.frame
						f:stoptweening() f:linear(0.25) f:aux(0)

						lb.stream.normal:diffusecolor(unpack(PlayerColor(pn)))
					end
				end,
				Recover = function(s,pn)
					if lifebar and lifebar[pn] then
						local lb=lifebar[pn]
						local d=lb.dangerglow
						local f=lb.frame
						--d:diffusecolor(0,1,0,0)
						f:stoptweening() f:linear(0.25) f:aux(0)

						lb.stream.normal:diffusecolor(unpack(PlayerColor(pn)))
					end
				end,
			},
			ShowDeath = function(s,pn)
			end,
			Off = function(s,pn) s:SetUpdateRate(1) Sweep.Out(s,pn) end
		},
		
		LifeParts = {
			StreamOn = function(s,pn) if not s then return end
				s:diffusecolor(unpack(PlayerColor(pn)))
			end,
			StreamFullOn = function(s,pn)
			end,
			BackgroundOn = function(s,pn)
			end,
			DangerGlowOn = function(s,pn)
				--The red flashing is hardcoded in stepmania, but it can be overridden here.
				--Default hard-coded tween: s:diffuseshift() s:effectcolor1(1,0,0,0.8) s:effectcolor2(1,0,0,1) s:effectclock("beat")
				s:stopeffect()
			end,
			FrameOn = function(s,pn)
			end,
		},

		CourseStageSprite = {
			On = function(s) s:visible(Bool[false]) end,
			Off = function(s) end,
			ChangeIn=function(s) end,
			ChangeOut=function(s) end
		},
		
		-- Spare text objects
		CourseStageText = {
			On = function(s,pn)
				s:visible(Bool[false])
--[[
 				s:horizalign("center")
				s:zoom(15/20)
				s:shadowlength(0)
--]]
			end,
			Off = function(s,pn)
			end,
		},
		StepsDescription = {
			On = function(s,pn)
				s:visible(Bool[false])
--[[
 				s:horizalign("center")
				s:zoom(15/20)
				s:shadowlength(0)
				s:settext("")
--]]
			end,
			Off = function(s,pn) end,
		},
		Mods = { -- "PlayerOptionsPn"
			On = function(s,pn) 
				s:horizalign("center")
				s:zoom(15/20)
				s:shadowlength(0)
			end,
			Off = function(s,pn) end,
		},
		SongOptions = {
 			On = function(s) s:visible(Bool[false]) end,
			Off = function(s) end
		},
		ActiveAttackList = {
			On = function(s,pn)
				if not GAMESTATE:PlayerUsingBothSides() then s:horizalign(pn==1 and "right" or "left") end
				s:vertalign("bottom")
				s:shadowlength(0)
				s:zoom(.75)
				s:diffusealpha(.75)
			end,
			Off = function(s,pn) end,
		},
		Judgment = {
			Tween=function(s,jts,bs)
				s:diffusealpha(1)
				s:zoomx(jts.x) s:zoomy(jts.y) s:decelerate(1/30) s:zoom(bs) --tween for two frames assuming vsync on. looks better if it's synced to the frame length
				--s:zoomx(jts.x) s:zoomy(jts.y) s:decelerate(s:GetEffectDelta()*2) s:zoom(bs) --tween for two frames assuming vsync on. looks better if it's synced to the frame length
				s:sleep(.6) s:accelerate(.25) s:diffusealpha(0) s:zoom(0.25)
			end,
			Tilt=function(s,magnitude) --0 for fantastic, 5 for miss. (switches between neg/pos)
--				s:rotationz(magnitude*math.abs(magnitude))
			end
		},
		HoldJudgment = {
			Tween=function(s,h,hts,bs)
				s:diffusealpha(h)
				s:zoom(hts) s:decelerate(s:GetEffectDelta()*2) s:zoom(bs)
				s:sleep(0.3) s:accelerate(.25) s:diffusealpha(0) s:zoom(0.25)
			end,
			Tilt=function(s,magnitude) --0 for held, 1 for dropped.
--				s:rotationz(magnitude*20) -- only tilt if we dropped a hold
			end
		},
		Combo = {
			Tween=function(s,z,cts,fade)
				s:finishtweening()
				s:diffusealpha(fade) -- Fade in combo from "3 combo"
				s:zoomx(z*cts.x) s:zoomy(z*cts.y) s:decelerate(1/30) s:zoom(z)

				s:sleep(.6) s:accelerate(.25) s:diffusealpha(0) s:zoom(0.25)
			end,
			ColourApply=function(c,n)
				c:diffusecolor(1,1,1,1)
				c:diffuseshift()
				c:effectcolor1(ComboColours[1][n]())
				c:effectcolor2(ComboColours[2][n]())
				c:effectperiod(0.8)
			end,
			ColourCancel=function(c,n)
				c:stopeffect()
				local red=n==6 and 0 or 1
				c:diffusecolor(1,red,red,1) --miss
			end,
		},

		GhostDisplay = {
			On = function(s,pn) 
				s:horizalign("center")
				s:zoom(15/20)
				s:shadowlength(0)
			end,
			Off = function(s,pn) end,
		},
		
		DangerLayer = {
			BGOn=function(s)
				local pn=s:getaux()
				getmetatable(s)[({"faderight","fadeleft"})[pn]](s,.1)
				s:stretchto(
					(GAMESTATE:PlayerUsingBothSides() or GetNumPlayersEnabled()==1 and GetPref("SoloSingle") or pn==1) and SCREEN_LEFT or SCREEN_CENTER_X,
					SCREEN_TOP,
					(GAMESTATE:PlayerUsingBothSides() or GetNumPlayersEnabled()==1 and GetPref("SoloSingle") or pn==2) and SCREEN_RIGHT or SCREEN_CENTER_X,
					SCREEN_BOTTOM
				)
				s:diffuseshift() s:effectcolor1(1,0,0.24,0.3) s:effectcolor2(1,0,0,0.9)
				s:diffusealpha(0)
			end,
			TextOn = function(s,pn) s:diffusealpha(0) s:shadowlength(0) s:zoom(2) Actor.xy(s,PlayerX(s:getaux()),SCREEN_CENTER_Y+SCREEN_HEIGHT/4) end,
			
			ShowBG = function(s,pn) s:stoptweening() s:decelerate(0.3) s:diffusealpha(0.5) end,
			ShowText = function(s,pn) s:stoptweening() s:decelerate(0.3) s:diffusealpha(0.5) end,
			
			HideBG = function(s,pn) s:stoptweening() s:accelerate(0.3) s:diffusealpha(0) end,
			HideText = function(s,pn) s:stoptweening() s:accelerate(0.3) s:diffusealpha(0) end,
			
			RecoverBGOn=function(s,pn)
				getmetatable(s)[({"faderight","fadeleft"})[pn]](s,.1)
				s:stretchto(
					(GAMESTATE:PlayerUsingBothSides() or GetNumPlayersEnabled()==1 and GetPref("SoloSingle") or pn==1) and SCREEN_LEFT or SCREEN_CENTER_X,
					SCREEN_TOP,
					(GAMESTATE:PlayerUsingBothSides() or GetNumPlayersEnabled()==1 and GetPref("SoloSingle") or pn==2) and SCREEN_RIGHT or SCREEN_CENTER_X,
					SCREEN_BOTTOM
				)
				s:diffuse(0,1,0,0)
			end,
			RecoverBG = function(s,pn) s:stoptweening() s:decelerate(0.3) s:diffusealpha(0.5) s:accelerate(0.3) s:diffusealpha(0) end,
			
			DeathBG = function(s,pn)
				--Flash red then disappear when a player dies
				s:stopeffect() s:diffuse(1,0.25,0.25,0) s:finishtweening() s:decelerate(0.5) s:diffusealpha(1) s:accelerate(0.5) s:diffusealpha(0)
			end,
			DeathText = function(s,pn) s:accelerate(0.3) s:diffusealpha(0) end
		},
		DeathLayer = {
			BGOn = function(s,pn)
				getmetatable(s)[({"faderight","fadeleft"})[pn]](s,.1)
				s:stretchto(
					(GAMESTATE:PlayerUsingBothSides() or GetNumPlayersEnabled()==1 and GetPref("SoloSingle") or pn==1) and SCREEN_LEFT or SCREEN_CENTER_X,
					SCREEN_TOP,
					(GAMESTATE:PlayerUsingBothSides() or GetNumPlayersEnabled()==1 and GetPref("SoloSingle") or pn==2) and SCREEN_RIGHT or SCREEN_CENTER_X,
					SCREEN_BOTTOM
				)
				s:diffuse(0.1,0,0.1,0)
			end,
			TextOn = function(s,pn) s:diffuse(1,0,0.75,0) s:shadowlength(0) s:zoom(2) Actor.xy(s,PlayerX(s:getaux()),SCREEN_CENTER_Y+SCREEN_HEIGHT/4) end,
			ShowBG = function(s,pn) s:decelerate(0.3) s:diffusealpha(0.5) end,
			ShowText = function(s,pn) s:decelerate(0.3) s:diffusealpha(1) end
		},

		--Net stats
		Scoreboard={
			Names={
				On=function(s,pn) end,
				Off=function(s,pn) end,
			},
			Combo={
				On=function(s,pn) end,
				Off=function(s,pn) end,
			},
			Grade={
				On=function(s,pn) end,
				Off=function(s,pn) end,
			},
		},

		--Lifetime score display.
		LifeTime={
			TimerOn=function(s) s:shadowlength(0) s:zoom(2) s:effectclock("music") end,
			Delta={
				On=function(s) local pn=s:getaux() s:x(((pn*2)-3)*-112) s:shadowlength(0) end,
				Ready=function(s) local pn=s:getaux() s:diffusealpha(0) s:finishtweening() end,
				Judge=function(s,n) local pn=s:getaux()
					s:finishtweening()
					local c=(n<4 or n==7) and {0.5,1,0.5,1} or n>4 and {1,0.5,0.5,1} or {0.75,0.75,0.75,1}
					s:diffuse(unpack(c)) s:y(0)
					s:accelerate(0.5)
					s:diffusealpha(0) s:addy(-16)
				end,
			},
		},
	}
