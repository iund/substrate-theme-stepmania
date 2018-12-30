
do --NOTE: this is wrapped in a do block so rowbase doesn't pollute the global namespace 
	local function texttween(s) s:stoptweening() s:decelerate(0.2) end

	local rowbase=function(rowi)

		local screenname=lua.GetThreadVariable("LoadingScreen")

		local stitle
		local svalues={}

		local rowtopy=THEME:GetMetric(screenname,"TopRowY")
		local rowitemx={
			THEME:GetMetric(screenname,"RowItemP1X"),
			THEME:GetMetric(screenname,"RowItemP2X")
		}

		local rowspacingy=THEME:GetMetric(screenname,"RowSpacingY")
		local rowtitlex=THEME:GetMetric(screenname,"RowTitleX")

		return Def.ActorFrame{
			InitCommand=function(s)  s:y((rowi-1)*rowspacingy+rowtopy) end,

			Def.BitmapText{
				InitCommand=function(s) stitle=s s:x(rowtitlex) s:zoom(.75) end,
				Font="_common semibold black",
			},

			--player1
			Def.BitmapText{
				InitCommand=function(s) svalues[1]=s s:x(rowitemx[1]) s:zoom(.75) end,
				Font="_common white",
			},

			--player2
			Def.BitmapText{
				InitCommand=function(s) svalues[2]=s s:x(rowitemx[2]) s:zoom(.75) end,
				Font="_common white",
			},

			settitletext=function(s,text) stitle:settext(text) end,
			setvaluetext=function(s,pn,text)
				svalues[pn]:settext(text)
				if not s.nudge then svalues[pn]:diffusealpha(0.5) end --NOTE: here isn't the best place for it since it gets set on each update
			end,
			setactive=function(s,pn,flag)
				local color=flag and 0 or 1
				texttween(svalues[pn])
				svalues[pn]:diffusecolor(color,color,color,1)
			end,
			getvaluewidth=function(s,pn) return svalues[pn]:GetZoomedWidth() end,
		}
	end

	------------------ Row types
	--The only methods that get called externally are init() and nudge()
	--init() is called from container's OnCommand to set the initial onscreen text
	--nudge() is called when you nudge left/right (updates the current row)
	--(If nudge() isn't defined, then the player's cursor won't land on that row)

	ModsMenu={
		speedmodtype=function(rowi)
			local title="SpeedType" --TODO: Find an already-l10n string

			local choices={"M","C","X"} -- M before X since the game applies an xmod when setting an mmod  
			local val={1,1} --cache so we don't have to read PlayerOptions every time

			return setmetatable(
				rowbase(rowi),
				{__index={
					init=function(s)
						s:settitletext(title) --TODO: THEME:GetString("OptionTitles",title))
						ForeachEnabledPlayer(function(p) local pn=PlayerIndex[p]
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
						--sendmessage("ChangedSpeedModType",pn,xcm)
						MESSAGEMAN:Broadcast("ChangedSpeedModType",{Player=pn,SpeedType=xcm})
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

			local row row=rowbase(rowi)..{
				ChangedSpeedModTypeMessageCommand=function(s,p)
					local pn=p.Player
					local newxcm=p.SpeedType

					local speed,oldxcm=row:getvalue(pn)

					--convert between xmod and tempo
					if oldxcm=="X" then
						speed=speed*maxtempo
					elseif newxcm=="X" then
						speed=speed/maxtempo
					end

					row:setvalue(pn,speed,newxcm)
					row:setvaluetext(pn,row:format(speed,newxcm))
				end,
				
				init=function(s)
					s:settitletext(THEME:GetString("OptionTitles","Speed"))
					ForeachEnabledPlayer(function(p) s:nudge(PlayerIndex[p]) end)
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
			}
			return row
		end,

		noteskin=function(rowi)
			local val={1,1}

			local choices=NOTESKIN:GetNoteSkinNames()

			return rowbase(rowi)..{
				init=function(s)
					s:settitletext(THEME:GetString("OptionTitles","NoteSkins"))
					ForeachEnabledPlayer(function(p) local pn=PlayerIndex[p] val[pn]=s:getvalue(pn) s:nudge(pn) end)
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
				end
			}
		end,

		rate=function(min,max)
			return function(rowi)
				return rowbase(rowi)..{
					init=function(s)
						s:settitletext(THEME:GetString("OptionTitles","Rate"))
						ForeachEnabledPlayer(function(p) s:nudge(PlayerIndex[p]) end)
					end,

					format=function(s,v) return string.format("%1.1fx",v) end,

					nudge=function(s,pn,dir)
						local val=s:getvalue()

						local dist=0.1
						local rate=clamp(val+((dir or 0)*dist),min,max)

						s:setvalue(rate)
						ForeachEnabledPlayer(function(p) s:setvaluetext(PlayerIndex[p],s:format(rate)) end)
					end,

					getvalue=function(s)
						return GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
					end,

					setvalue=function(s,val)
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(val)
						--sendmessage("ChangedMusicRate",val)
						MESSAGEMAN:Broadcast("ChangedMusicRate",{Rate=val})
					end
				}
			end
		end,

		tempoinfo=function(rowi)
			local row
			local update=function(s,p)
				local rate=p and p.Rate or GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
				local str=not IsCourseMode() and GetTempoString(GetCurSong(),rate) or GetCourseTempoString(GetCurCourse(),rate)
				ForeachEnabledPlayer(function(p) row:setvaluetext(PlayerIndex[p],str) end)
			end
			row=rowbase(rowi)..{
				ChangedMusicRateMessageCommand=update,
				init=function(s)
					s:settitletext(THEME:GetString("OptionTitles","Tempo"))
					update(s)
				end
			}
			return row
		end,

		lengthinfo=function(rowi)
			local row
			local update=function(s,p)
				local r=p and p.Rate or GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
				ForeachEnabledPlayer(function(p)
					local length=not IsCourseMode() and GetCurSong():MusicLengthSeconds()
						or IsCourseMode() and GetCurTrail(p):GetLengthSeconds() or 0
					local str=SecondsToMSS(length/r)
					row:setvaluetext(PlayerIndex[p],str)
				end)
			end
			row=rowbase(rowi)..{
				ChangedMusicRateMessageCommand=update,
				init=function(s)
					s:settitletext(THEME:GetString("SortOrder","Length")) --HACK: Only l10n string is in the sort menu.
					update(s)
				end
			}
			return row
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
			local row
			local update=function(p)
				local pn=PlayerIndex[p] val[pn]=row:getvalue(pn) row:nudge(pn,0)
			end
			row=rowbase(rowi)..{
				--In pump, moving to routine will also force set the other side.
				CurrentStepsP1ChangedMessageCommand=function(s) update(PLAYER_1) end,
				CurrentStepsP2ChangedMessageCommand=function(s) update(PLAYER_2) end,
				CurrentStepsP1ChangedMessageCommand=function(s) update(PLAYER_1) end,
				CurrentStepsP2ChangedMessageCommand=function(s) update(PLAYER_2) end,
				init=function(s)
					s:settitletext(THEME:GetString("OptionTitles","Difficulty"))
					ForeachEnabledPlayer(update)
				end,

				nudge=function(s,pn,dir)
					val[pn]=wrap(val[pn]+dir,1,#choices)
					if dir~=0 then --avoid getting trapped in a recursing loop
						s:setvalue(pn,val[pn])
					end

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
			}
			return row
		end,

		modpercent=function(modname,min,max,step)
			return function(rowi)
				return rowbase(rowi)..{
					init=function(s)
						s:settitletext(THEME:GetString("OptionNames",modname))
						ForeachEnabledPlayer(function(p) s:nudge(PlayerIndex[p]) end)
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
				}
			end
		end,

		modbool=function(modname)
			return function(rowi)
				return rowbase(rowi)..{
					init=function(s)
						s:settitletext(THEME:GetString("OptionNames",modname))
						ForeachEnabledPlayer(function(p) s:nudge(PlayerIndex[p]) end)
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
				}
			end
		end,

		modchoices=function(title,choices,addnone)
			--Note that the mods we use may be a mix of boolean and numeric types.
			if addnone then table.insert(choices,1,"None") end
			return function(rowi)
				local val={1,1}
				return rowbase(rowi)..{
					init=function(s)
						s:settitletext(THEME:GetString("OptionTitles",title))
						ForeachEnabledPlayer(function(p) local pn=PlayerIndex[p] val[pn]=s:getvalue(pn) s:nudge(pn,0) end)
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
				}
			end
		end,
		exit=function(rowi)
			local text
			local screenname=lua.GetThreadVariable("LoadingScreen")

			return Def.BitmapText{
				Font="_common white",
				Text=THEME:GetString("ScreenOptionsMaster","Exit"),
				InitCommand=function(s)
					s:y(THEME:GetMetric(screenname,"ExitRowY"))
					s:zoom(.75)
					text=s
				end,

				init=function() end,
				getvaluewidth=function() return text:GetZoomedWidth() end,
				setactive=function(s,pn,flag)
					local color=flag and 0 or 1
					texttween(text)
					text:diffusecolor(color,color,color,1)
				end,
				exit=true
			}
		end
	}
end