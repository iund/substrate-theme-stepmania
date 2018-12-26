

--[[

Feed in a mods menu definition and out comes a mods menu.



in theory:

return ModsMenu({
	ModsMenu.speedmodtype,
	ModsMenu.speedmod,
	ModsMenu.modpercent("Mini",0,100),
	ModsMenu.noteskin,

	ModsMenu.modchoices("Persp",{"Distant","Overhead","Hallway"},false),
	ModsMenu.modpercent("Cover",0,100),
	ModsMenu.rate,
	ModsMenu.tempoinfo,
	ModsMenu.lengthinfo,

	ModsMenu.stepchart,
	ModsMenu.modbool("Reverse"),
	modchoices("Hide Notes",{"Hidden","Sudden","Stealth"},true),
})

--]]
do --NOTE: I don't think locals will persist and pollute the namespace but I'd rather be cautious

	local defaultmetrics={
		frame={SCREEN_CENTER_X,SCREEN_CENTER_Y},
		headingx=0,
		playerx={-256,256},
		dqy=156, --152 for the sprite
		rowspacingy=24,
		rowtopy=-156,
		exitrowy=192
	}
	local metrics=defaultmetrics

	local foreachplayer=ForeachEnabledPlayer

	local state

	-- Roll our own MessageMan
	local function receivemessage(msg,func) --(register
		table.insert(state.messagelisteners,{name=msg, cb=func})
	end

	local function sendmessage(msg,...)
		for i,v in next,state.messagelisteners,nil do
			if v.name==msg then v.cb(unpack(arg)) end
		end
	end

	------------------ Input logic
																																		
	local input

	local function isexitrow(rowi) return state.row[rowi].exit or false end

	local function isonexit(pn) return isexitrow(state.currow[pn]) end

	--local function isonexit(pn) return state.currow[pn]>=#state.row end
	local function allonexit() return
		(not state.cursor[1] or isonexit(1)) and
		(not state.cursor[2] or isonexit(2))
	end

	local function cursortween(s) s:stoptweening() s:decelerate(0.2) end

	local function screenback()
		GetScreen():RemoveInputCallback(input)
		GetScreen():Cancel()
	end
	local function screennext()
		SCREENMAN:PlayStartSound()
		GetScreen():RemoveInputCallback(input)
		GetScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end

	local sound=function(name) SOUND:PlayOnce(THEME:GetPathS("Options",name)) end --TODO "ModsMenu" not "Options"

	local function up(pn) state.cursor[pn]:move(-1) sound("prev") end
	local function down(pn) state.cursor[pn]:move(1) sound("next") end
	local function left(pn) state.row[state.currow[pn]]:nudge(pn,-1) sound("change") sendmessage("UpdateDQ") end
	local function right(pn) state.row[state.currow[pn]]:nudge(pn,1) sound("change") sendmessage("UpdateDQ") end

	input=function(attr)
		local p=attr.PlayerNumber
		local pn=PlayerIndex[p]

		if pn and attr.type~="InputEventType_Release" and GAMESTATE:IsPlayerEnabled(p) then
			if attr.GameButton=="MenuLeft" then left(pn,attr.type=="InputEventType_FirstPress")
			elseif attr.GameButton=="MenuRight" then right(pn,attr.type=="InputEventType_FirstPress")
			elseif attr.GameButton=="Start" then
				if attr.type=="InputEventType_FirstPress" and allonexit() then
					screennext()
				elseif state.currow[pn]<#state.row then
					down(pn)
				end
			elseif attr.GameButton=="MenuDown" then
				if attr.type=="InputEventType_FirstPress" and state.currow[pn]==#state.row then --wrap cursor from bottom row to top
					state.cursor[pn]:moveto(1,cursortween)
				elseif state.currow[pn]<#state.row then
					down(pn)
				end
			elseif attr.GameButton=="Select" or attr.GameButton=="MenuUp" then
				if attr.type=="InputEventType_FirstPress" and state.currow[pn]==1 then --wrap cursor from top row to bottom
					state.cursor[pn]:moveto(#state.row,cursortween)
				elseif state.currow[pn]>1 then
					up(pn)
				end
			elseif attr.GameButton=="Back" then screenback()
			end
		end
	end

	------------------ Containers

	local container

	------------------ Cursors

	local newcursor=function(pn)
		local cself,cmid,cleft,cright

		local spritepath=THEME:GetPathG("Options","cursor")
		return Def.ActorFrame{
			InitCommand=function(s) cself=s end,
			OnCommand=cmd(x,metrics.playerx[pn];y,metrics.rowtopy;finishtweening),

			Def.Sprite{ --middle
				Texture=spritepath,
				InitCommand=function(s) cmid=s s:animate(false) s:setstate(1) end,
			},
			Def.Sprite{ --left
				Texture=spritepath,
				InitCommand=function(s) cleft=s s:animate(false) s:setstate(0) s:horizalign("right") end,
			},
			Def.Sprite{ --right
				Texture=spritepath,
				InitCommand=function(s) cright=s s:animate(false) s:setstate(2) s:horizalign("left") end,
			},

			setwidth=function(s,width,tween)
				width=math.ceil(width/2)*2 --even widths only so the sides are properly pixel-aligned
				if tween then tween(cmid) tween(cleft) tween(cright) end
				cmid:zoomtowidth(width)
				cleft:x(-width/2)
				cright:x(width/2)
			end,
		
			moveto=function(s,rowi,tween)
				if tween then tween(cself) end
				cself:x(isexitrow(rowi) and 0 or metrics.playerx[pn])
				cself:y(isexitrow(rowi) and metrics.exitrowy or metrics.rowtopy+(rowi-1)*metrics.rowspacingy)
				
				s:setwidth(state.row[rowi]:getvaluewidth(pn),tween)
				
				state.row[state.currow[pn]]:setactive(pn,false)
				state.row[rowi]:setactive(pn,true)
				state.currow[pn]=rowi
			end,

			move=function(s,dir)
				local nextrow=state.currow[pn]
				repeat nextrow=nextrow+dir until state.row[nextrow].nudge or state.row[nextrow].exit --find the next selectable row
				s:moveto(nextrow,cursortween)
			end
		}
	end

	------------------ Row classes

	local rowbase=function(rowi)
		local stitle
		local svalues={}

		return Def.ActorFrame{
			InitCommand=function(s)  s:y((rowi-1)*metrics.rowspacingy+metrics.rowtopy) end,

			Def.BitmapText{
				InitCommand=function(s) stitle=s s:x(metrics.headingx) s:zoom(.75) end,
				Font="_common semibold black",
			},

			--player1
			Def.BitmapText{
				InitCommand=function(s) svalues[1]=s s:x(metrics.playerx[1]) s:zoom(.75) end,
				Font="_common white",
			},

			--player2
			Def.BitmapText{
				InitCommand=function(s) svalues[2]=s s:x(metrics.playerx[2]) s:zoom(.75) end,
				Font="_common white",
			},

			settitletext=function(s,text) stitle:settext(text) end,
			setvaluetext=function(s,pn,text)
				svalues[pn]:settext(text)
				if rowi==state.currow[pn] then state.cursor[pn]:moveto(rowi) end --update cursor width
				if not s.nudge then svalues[pn]:diffusealpha(0.5) end --NOTE: here isn't the best place for it since it gets set on each update
			end,
			setactive=function(s,pn,flag)
				local color=flag and 0 or 1
				cursortween(svalues[pn])
				svalues[pn]:diffusecolor(color,color,color,1)
			end,
			getvaluewidth=function(s,pn) return svalues[pn]:GetWidth()*svalues[pn]:GetZoomX() end,
		}
	end

	------------------ Row types
	--The only methods that get called externally are init() and nudge()
	--init() is called from container's OnCommand to set the initial onscreen text
	--nudge() is called when you nudge left/right (updates the current row)
	--(If nudge() isn't defined, then the player's cursor won't land on that row)
	local rowtypes={
		speedmodtype=function(rowi)
			local title="SpeedType" --TODO: Find an already-l10n string

			local choices={"M","C","X"} -- M before X since the game applies an xmod when setting an mmod  
			local val={1,1} --cache so we don't have to read PlayerOptions every time

			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						s:settitletext(title) --TODO: THEME:GetString("OptionTitles",title))
						foreachplayer(function(p) local pn=PlayerIndex[p]
							val[pn]=s:getvalue(pn)
							s:nudge(pn)
						end)
					end,

					nudge=function(s,pn,dir)
						if not GAMESTATE:IsPlayerEnabled(PlayerIndex[pn]) then return end
						if dir then s:setvalue(pn,dir) end
						local xcm=choices[val[pn]]
						s:setvaluetext(pn,xcm)
					end,

					getvalue=function(s,pn)
						local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
						for i,xcm in next,choices,nil do if PlayerOptions[xcm.."Mod"](mods) then return i end end
					end,

					setvalue=function(s,pn,dir)
						val[pn]=wrap(val[pn]+dir,1,#choices)
						local xcm=choices[val[pn]]
						sendmessage("ChangedSpeedModType",pn,xcm)
					end,
				}}
			)
		end,

		speedmod=function(rowi,customlimits,customstep)

			local limits=customlimits or {
				X={min=0.1, max=20},
				C={min=10, max=2000} --must be positive tempo values
			}
			local step=customstep or {
				X=0.05, C=5
			}

			limits.M=limits.M or limits.C
			step.M=step.M or step.C

			local mintempo
			local maxtempo

			local hidetempo=false

			if IsCourseMode() then
				--Iterate through each song; SM5 doesn't provide a lua function to access tempo values for a course/trail directly.
				local entries=GetCurCourse():GetCourseEntries()
				
				for i,entry in next,entries,nil do
					local song=entry:GetSong()
					local tempos=song:GetDisplayBpms() or {}
					
					mintempo=math.round(not mintempo and tempos[1] or math.min(mintempo,tempos[1]))
					maxtempo=math.round(not maxtempo and tempos[2] or math.max(maxtempo,tempos[2]))

					hidetempo=hidetempo or song:IsDisplayBpmSecret()		
				end
			else
				local song=GetCurSong()

				local tempo=song:GetDisplayBpms() or {}
				mintempo=math.round(tempo[1] or 100)
				maxtempo=math.round(tempo[2] or 100)

				hidetempo=hidetempo or song:IsDisplayBpmSecret()		
			end

			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						receivemessage("ChangedSpeedModType",function(pn,newxcm)
							local speed,oldxcm=s:getvalue(pn)

							--convert between xmod and tempo
							if oldxcm=="X" then
								speed=speed*maxtempo
							elseif newxcm=="X" then
								speed=speed/maxtempo
							end

							s:setvalue(pn,speed,newxcm)
							s:setvaluetext(pn,s:format(speed,newxcm))
						end)
						s:settitletext(THEME:GetString("OptionTitles","Speed"))
						foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
					end,

					format=function(s,v,xcm)
						local str
						if xcm=="X" then --"1.25x (90-180 bpm)"
							str=string.format("%1.2fx",v)
							if not hidetempo then
								str=string.format("%s (%s)",str,
									IsCourseMode() and GetCourseTempoString(GetCurCourse(),v)
									or not IsCourseMode() and GetTempoString(GetCurSong(),v))
							end
						else
							str=string.format("%.0f bpm",v)
							if xcm=="M" and not hidetempo then -- "880 bpm (5.65x)" (M-mod)
								local xmod=v/maxtempo
								str=string.format("%s (%1.2fx)",str,xmod)
							end
						end
						return str
						end,

					nudge=function(s,pn,dir)
						local speed,xcm=s:getvalue(pn)

						local dist=step[xcm]

						speed=clamp(
							(math.round(speed/dist)+(dir or 0))*dist,
							limits[xcm].min,limits[xcm].max
						)

						s:setvalue(pn,speed,xcm)
						s:setvaluetext(pn,s:format(speed,xcm))
					end,

					getvalue=function(s,pn)
						local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
						
						--mods:[XMod/CMod/MMod](speed)
						for _,xcm in next,{"M","C","X"},nil do
							local speed=PlayerOptions[xcm.."Mod"](mods)
							if speed then
								return speed,xcm
							end
						end
					end,

					setvalue=function(s,pn,speed,xcm)
						local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
						PlayerOptions[xcm.."Mod"](mods,speed)
					end,
				}}
			)
		end,

		noteskin=function(rowi)
			local val={1,1}

			local choices=NOTESKIN:GetNoteSkinNames()

			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						s:settitletext(THEME:GetString("OptionTitles","NoteSkins"))
						foreachplayer(function(p) local pn=PlayerIndex[p] val[pn]=s:getvalue(pn) s:nudge(pn) end)
					end,

					nudge=function(s,pn,dir)
						val[pn]=wrap(val[pn]+(dir or 0),1,#choices)
						s:setvalue(pn,val[pn])
						s:setvaluetext(pn,choices[s:getvalue(pn)])
					end,

					getvalue=function(s,pn)
						local noteskin=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
						for i,ns in next,choices,nil do
							if ns==noteskin then return i end
						end
					end,

					setvalue=function(s,pn,i)
						GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin(choices[i])
					end,
				}}
			)
		end,

		rate=function(min,max)
			return function(rowi)
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionTitles","Rate"))
							foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
						end,

						format=function(s,v) return string.format("%1.1fx",v) end,

						nudge=function(s,pn,dir)
							local val=s:getvalue()

							local dist=0.1
							local rate=clamp(val+((dir or 0)*dist),min,max)

							s:setvalue(rate)
							foreachplayer(function(p) s:setvaluetext(PlayerIndex[p],s:format(rate)) end)
						end,

						getvalue=function(s)
							return GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
						end,

						setvalue=function(s,val)
							GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(val)
							sendmessage("ChangedMusicRate",val)
						end,
					}}
				)
			end
		end,

		tempoinfo=function(rowi)
			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						receivemessage("ChangedMusicRate",function(rate)
							s:update(rate)
						end)
						s:settitletext(THEME:GetString("OptionTitles","Tempo"))
						s:update()
					end,

					update=function(s,rate)
						local str=not IsCourseMode() and GetTempoString(GetCurSong(),rate) or GetCourseTempoString(GetCurCourse(),rate)
						foreachplayer(function(p) s:setvaluetext(PlayerIndex[p],str) end)
					end,
				}}
			)
		end,

		lengthinfo=function(rowi)
			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						receivemessage("ChangedMusicRate",function(rate)
							s:update(rate)
						end)
						s:settitletext(THEME:GetString("SortOrder","Length")) --HACK: Only l10n string is in the sort menu.
						s:update()
					end,

					update=function(s,rate)
						local r=rate or GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
						foreachplayer(function(p)
							local length=not IsCourseMode() and GetCurSong():MusicLengthSeconds()
								or IsCourseMode() and GetCurTrail(p):GetLengthSeconds() or 0
							local str=SecondsToMSS(length/r)
							s:setvaluetext(PlayerIndex[p],str)
						end)
					end,
				}}
			)
		end,

		stepchart=function(rowi)
			local val={1,1}

			local choices
			if not IsCourseMode() then
				choices=SongUtil.GetPlayableSteps(GetCurSong()) or {}
			else
				choices=GetPlayableTrails(GetCurCourse())
			end

			local showstyle=THEME:GetMetric("Common","AutoSetStyle")
			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						s:settitletext(THEME:GetString("OptionTitles","Difficulty"))
						foreachplayer(function(p) local pn=PlayerIndex[p] val[pn]=s:getvalue(pn) s:nudge(pn,0) end)
					end,

					nudge=function(s,pn,dir)
						val[pn]=wrap(val[pn]+dir,1,#choices)
						s:setvalue(pn,val[pn])

						local text
						if not IsCourseMode() then
							local steps=GetCurSteps(PlayerIndex[pn])

							text=
							showstyle and
								string.format("%s %s (%d)",
									CustomDifficultyToLocalizedString(StepsToCustomDifficulty(steps)),
									GAMEMAN:StepsTypeToLocalizedString(steps:GetStepsType()),
									steps:GetMeter())
							or
								string.format("%s (%d)",
									CustomDifficultyToLocalizedString(StepsToCustomDifficulty(steps)),
									steps:GetMeter())
						else
							local trail=GetCurTrail(PlayerIndex[pn])

							text=
							showstyle and
								string.format("%s %s (%d)",
									CustomDifficultyToLocalizedString(TrailToCustomDifficulty(trail)),
									GAMEMAN:StepsTypeToLocalizedString(trail:GetStepsType()),
									steps:GetMeter())
							or
								string.format("%s (%d)",
									CustomDifficultyToLocalizedString(TrailToCustomDifficulty(trail)),
									trail:GetMeter())
						end
						s:setvaluetext(pn,text)
					end,

					getvalue=function(s,pn)
						if not IsCourseMode() then
							for i,chart in next,choices,nil do
								if GetCurSteps(PlayerIndex[pn])==chart then return i end
							end
						else
							for i,trail in next,choices,nil do
								if GetCurTrail(PlayerIndex[pn])==trail then return i end
							end
						end
						return 1
					end,

					setvalue=function(s,pn,i)
						local p=PlayerIndex[pn]
						if not IsCourseMode() then
							SetCurSteps(p,choices[i])
						else
							SetCurTrail(p,choices[i])
						end
						GAMESTATE:SetPreferredDifficulty(p,choices[i]:GetDifficulty())
					end,
				}}
			)
		end,

		modpercent=function(modname,min,max,step)
			return function(rowi)
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionNames",modname))
							foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
						end,
			
						format=function(s,v) return string.format("%d%%",v) end,
			
						nudge=function(s,pn,dir)
							if dir then s:setvalue(pn,dir) end
							s:setvaluetext(pn,s:format(s:getvalue(pn)))
						end,
			
						getvalue=function(s,pn)
							local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
							
							return math.round(PlayerOptions[modname](mods)*100)
						end,
						setvalue=function(s,pn,dir)
							local val=s:getvalue(pn)
							val=clamp(val+dir*(step or 10),min,max)
			
							local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
							PlayerOptions[modname](mods,val/100)
						end,
					}}
				)
			end
		end,

		modbool=function(modname)
			return function(rowi)
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionNames",modname))
							foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
						end,
			
						nudge=function(s,pn,dir)
							if dir then s:setvalue(pn,dir) end
							s:setvaluetext(pn,THEME:GetString("OptionNames",s:getvalue(pn) and "On" or "Off"))
						end,

						getvalue=function(s,pn)
							local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
							return PlayerOptions[modname](mods)~=0
						end,
						setvalue=function(s,pn,dir)
							local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
							PlayerOptions[modname](mods,s:getvalue(pn) and 0 or 1)
						end,
					}}
				)
			end
		end,

		modchoices=function(title,choices,addnone)
			--Note that the mods we use may be a mix of boolean and numeric types.
			if addnone then table.insert(choices,1,"None") end
			return function(rowi)
				local val={1,1}
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionTitles",title))
							foreachplayer(function(p) local pn=PlayerIndex[p] val[pn]=s:getvalue(pn) s:nudge(pn,0) end)
						end,

						nudge=function(s,pn,dir)
							val[pn]=wrap(val[pn]+dir,1,#choices)
							s:setvalue(pn,val[pn])
							s:setvaluetext(pn,THEME:GetString("OptionNames",choices[s:getvalue(pn)]))
						end,

						getvalue=function(s,pn)
							local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
							for i=(addnone and 2 or 1),#choices do
								local state=PlayerOptions[choices[i]](mods)
								if state and state~=0 then return i end
							end
							return 1
						end,

						setvalue=function(s,pn,i)
							local mods=GAMESTATE:GetPlayerState(PlayerIndex[pn]):GetPlayerOptions("ModsLevel_Preferred")
							--unset the others first
							for j=(addnone and 2 or 1),#choices do
								if j~=i then
									local modtype=type(PlayerOptions[choices[j]](mods))
									PlayerOptions[choices[j]](mods,modtype~='boolean' and 0)
								end
							end
							--then set our choice
							if i>(addnone and 1 or 0) then
								local modtype=type(PlayerOptions[choices[i]](mods))
								PlayerOptions[choices[i]](mods,modtype=='boolean' or 1)
							end
						end,
					}}
				)
			end
		end,
		exit=function(rowi)
			local text
			return Def.BitmapText{
				Font="_common white",
				Text=THEME:GetString("ScreenOptionsMaster","Exit"),
				InitCommand=function(s) s:y(metrics.exitrowy) s:zoom(.75) text=s end,

				init=function() end,
				getvaluewidth=function() return text:GetWidth()*text:GetZoomX() end,
				setactive=function(s,pn,flag)
					local color=flag and 0 or 1
					cursortween(text)
					text:diffusecolor(color,color,color,1)
				end,
				exit=true
			}
		end
	}
	------------------ Row definitions

	ModsMenu=setmetatable({},{
		__call=function(mm,rowdefs,onlypn,overridemetrics,paneless) --NOTE: the latter 3 are only set for other menus like the selectmusic mods menu
			metrics=overridemetrics or defaultmetrics

			foreachplayer=
				not onlypn
				and ForeachEnabledPlayer
				or function(func) func(PlayerIndex[onlypn]) end

			state={
				currow={1,1},
				cursor={},
				row={},
				messagelisteners={}
			}
			container=Def.ActorFrame{
				OnCommand=function(s)
					if not paneless then
						GetScreen():AddInputCallback(input)
					end

					Actor.xy(s,unpack(metrics.frame))
					for i,row in next,state.row,nil do row:init() end
			
					foreachplayer(function(p) local pn=PlayerIndex[p]
						while not state.row[state.currow[pn]].nudge do
							state.currow[pn]=state.currow[pn]+1
						end
						state.cursor[pn]:move(0)
					end)
				end,
			
				OffCommand=function(s)
				end
			}
			if not paneless then
				--middle pane
				container[#container+1]=
				Def.Sprite{
					Texture=THEME:GetPathG("Options","middle pane"),
					InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha)
				}

				container[#container+1]=
				Def.BitmapText{
					Font="_common semibold black",
					InitCommand=cmd(y,-192;zoom,.75),
					OnCommand=function(s)
						if IsCourseMode() then
							s:settext(GetCurCourse():GetDisplayFullTitle()) 
						else
							s:settext(string.format("%s\n(%s)",
								GetCurSong():GetDisplayFullTitle(),
							split("/",GetCurSong():GetSongDir())[3]))
						end
					end
				}
			end

			foreachplayer(function(p) local pn=PlayerIndex[p]
				if not paneless then
					container[#container+1]=Def.Sprite{
						Texture=THEME:GetPathG("Options","player pane"),
						InitCommand=function(s)
							s:x(metrics.playerx[pn])
							s:diffusealpha(CommonPaneDiffuseAlpha)
						end,
						OnCommand=function(s)
							ApplyUIColor(s,p)
						end
					}

					--difficulty meter
					container[#container+1]=Def.ActorFrame{

						InitCommand=cmd(x,(pn*2-3)*376;y,-192),

						Def.Sprite{
							Texture=THEME:GetPathG("PlayerOptions","page/player/meter/meter frame"), --TODO: redir the sprite
						},

						Def.StepsDisplay{
					                InitCommand=cmd(Load,"Gameplay StepsDisplay"), --TODO new section
					                OnCommand=cmd(SetFromGameState,p),
					                ["CurrentStepsP"..pn.."ChangedMessageCommand"]=cmd(SetFromGameState,p),
					                ["CurrentTrailP"..pn.."ChangedMessageCommand"]=cmd(SetFromGameState,p)
					        }
					}

					-- player name
					container[#container+1]=
					Def.BitmapText{
						Font="_common white",
						InitCommand=cmd(x,(pn*2-3)*240;y,-204),
						Text=GAMESTATE:GetPlayerDisplayName(p)
					}

					-- chart name
					container[#container+1]=
					Def.BitmapText{
						Font="_common white",
						InitCommand=cmd(x,(pn*2-3)*240;y,-180;zoom,.75),
						OnCommand=cmd(playcommand,"Set"),
				                ["CurrentStepsP"..pn.."ChangedMessageCommand"]=cmd(playcommand,"Set"),
				                ["CurrentTrailP"..pn.."ChangedMessageCommand"]=cmd(playcommand,"Set"),
						SetCommand=cmd(settext,
							--TODO move this and the SelectMusic chart tag into its own function
							not IsCourseMode() and
			                                        GetCurSteps(p) and GetCurSteps(p):GetChartName()
                        			        or IsCourseMode() and
			                                        GetCurTrail(p) and
                                        			                CustomDifficultyToLocalizedString(TrailToCustomDifficulty(GetCurTrail(p)))
			                                or "")
					}

					container[#container+1]=Def.ActorFrame{ --DQ
						InitCommand=cmd(x,metrics.playerx[pn];y,metrics.dqy),
				
						OnCommand=function(s) 
							local function update()
								if not IsCourseMode() and GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Preferred"):IsEasierForSongAndSteps(GetCurSong(),GetCurSteps(p),p)
									or IsCourseMode() and GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Preferred"):IsEasierForCourseAndTrail(GetCurCourse(),GetCurTrail(p),p)
								then
									s:stoptweening() s:linear(.2) s:diffusealpha(1)
								else
									s:stoptweening() s:linear(.2) s:diffusealpha(0)
								end
							end
							receivemessage("UpdateDQ",update)
							update()
						end,

						Def.Quad{
							InitCommand=cmd(zoomto,288,24;diffusecolor,0.5,0,0,1),
						},

						Def.BitmapText{
							Font="_common white",
							Text="Will disqualify from ranking", --TODO l10n
							InitCommand=cmd(zoom,.75),
						}
					}
				end
			
				--add cursors
				local cursor=newcursor(pn)
				container[#container+1]=cursor
				state.cursor[pn]=cursor
			end)

			--set rows:

			local ctroff=#container
			for i,rowdef in next,rowdefs,nil do
				local row=rowdef(i)
				container[ctroff+i]=row
				state.row[i]=row
			end
		
			return container
		end,
		__index=rowtypes
	})
end
