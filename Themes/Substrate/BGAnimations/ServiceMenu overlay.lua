--TODO: Stop gap. Abstract it out later in v1.1
local ServiceMenu
do
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
		local pn=1 --either. local pn=PlayerIndex[p]

		if pn and attr.type~="InputEventType_Release" then
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
				cself:y(isexitrow(rowi) and metrics.exitrowy or metrics.rowtopy+(rowi-1)*metrics.rowspacingy)
				
				cself:x(isexitrow(rowi) and 0 or metrics.playerx[pn])
				
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

		prefnumber=function(prefname,min,max,step)
			return function(rowi)
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionTitles",prefname) or prefname)
							foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
						end,
						format=function(s,v) return string.format("%d",v) end,
						nudge=function(s,pn,dir)
							if dir then s:setvalue(pn,dir) end
							s:setvaluetext(pn,s:format(s:getvalue(pn)))
						end,
						getvalue=function(s,pn)
							return math.round(GetPref(prefname))
						end,
						setvalue=function(s,pn,dir)
							local val=s:getvalue(pn)
							val=clamp(val+dir*(step or 10),min,max)

							SetPref(prefname,val)
						end,
					}}
				)
			end
		end,

		prefpercent=function(prefname,min,max,step)
			return function(rowi)
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionTitles",prefname) or prefname)
							foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
						end,
						format=function(s,v) return string.format("%d%%",v) end,
						nudge=function(s,pn,dir)
							if dir then s:setvalue(pn,dir) end
							s:setvaluetext(pn,s:format(s:getvalue(pn)))
						end,
						getvalue=function(s,pn)
							return math.round(GetPref(prefname)*100)
						end,
						setvalue=function(s,pn,dir)
							local val=s:getvalue(pn)
							val=clamp(val+dir*(step or 10),min,max)

							SetPref(prefname,val/100)
						end,
					}}
				)
			end
		end,

		prefbool=function(prefname)
			return function(rowi)
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionTitles",prefname) or prefname)
							foreachplayer(function(p) s:nudge(PlayerIndex[p]) end)
						end,
			
						nudge=function(s,pn,dir)
							if dir then s:setvalue(pn,dir) end
							s:setvaluetext(pn,THEME:GetString("OptionNames",s:getvalue(pn) and "On" or "Off"))
						end,

						getvalue=function(s,pn)
							return GetPref(prefname)
						end,
						setvalue=function(s,pn,dir)
							SetPref(prefname,not s:getvalue(pn))
						end,
					}}
				)
			end
		end,

		prefchoices=function(prefname,choices,addnone)
			--Note that the mods we use may be a mix of boolean and numeric types.
			if addnone then table.insert(choices,1,"None") end
			return function(rowi)
				local val={1,1}
				return setmetatable(
					rowbase(rowi),
					{__index={
						init=function(s)
							s:settitletext(THEME:GetString("OptionTitles",prefname))
							foreachplayer(function(p) local pn=PlayerIndex[p] val[pn]=s:getvalue(pn) s:nudge(pn,0) end)
						end,

						nudge=function(s,pn,dir)
							val[pn]=wrap(val[pn]+dir,1,#choices)
							s:setvalue(pn,val[pn])
							local choice=choices[val[pn]]
							s:setvaluetext(pn,choice) --TODO- THEME:GetString("OptionNames",choice) or choice)
						end,

						getvalue=function(s,pn)
							local val=GetPref(prefname)
							for i=(addnone and 2 or 1),#choices do
								if val==(prefname.."_"..choices[i]) then return i end
							end
							return 1
						end,

						setvalue=function(s,pn,i)
							--then set our choice
							if i>(addnone and 1 or 0) then
								SetPref(prefname,choices[i-(addnone and 1 or 0)])
							else
								SetPref(prefname,"")
							end
							Broadcast("RefreshCreditText")
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

	ServiceMenu=setmetatable({},{
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
			if not paneless then container[#container+1]=
				Def.Sprite{
					Texture=THEME:GetPathG("Options","middle pane"),
					InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha)
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
						end
					}
--[[
					container[#container+1]=Def.Sprite{
						Texture=THEME:GetPathG("ModsMenu","dq sprite"),
						InitCommand=cmd(x,metrics.playerx[pn];y,metrics.dqy),
				
						OnCommand=function(s) 
							local song=GetCurSong()
							local function update()
								if GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Preferred"):IsEasierForSongAndSteps(song,GetCurSteps(p),p)
								then
									s:stoptweening() s:linear(.2) s:diffusealpha(1)
								else
									s:stoptweening() s:linear(.2) s:diffusealpha(0)
								end
							end
							receivemessage("UpdateDQ",update)
							update()
						end
					}
--]]

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

--------------------------------------------

local entries={
	ServiceMenu.prefnumber("SongsPerPlay",2,5,1),
	ServiceMenu.prefnumber("CoinsPerCredit",1,10,1),
	ServiceMenu.prefchoices("Premium",{"Off","DoubleFor1Credit","2PlayersFor1Credit"},false),
	ServiceMenu.prefbool("EventMode"),
	ServiceMenu.prefbool("MenuTimer"),
	ServiceMenu.prefchoices("CoinMode",{"Free","Pay","Home"},false),
	ServiceMenu.prefpercent("BGBrightness",0,100,10),
	ServiceMenu.prefpercent("SoundVolume",0,100,5),
	ServiceMenu.prefpercent("SoundVolumeAttract",0,100,5),
	ServiceMenu.exit
--[[
		Insert Credit
		Clear Credits
		Coin Options
			Songs Per Play
			Coins Per Credit
			Joint Premium
			Freeplay
			Event
			Menu Timer
		Sound Options
			Attract Volume
			Attract Frequency
		Profile Options
			Enable USB
			Custom Songs
		Advanced
			Global Offset
			Give Up Time
			2-song threshold
			3-song threshold
			Pad Lights Mode
		View/Clear Coin Data (ie, Bookkeeping screen)
		Test Input/Lights/Screen
		Hardware Status
		Actions
			Add/Delete Packs
			Backup Stats
			Restore Stats
			Reboot
		Set Time
		Cabinet Setup
--]]

}
return Def.ActorFrame{
	OnCommand=function(s)
		SOUND:PlayOnce(THEME:GetPathS("Options","open"))
	end,
	LoadActor(THEME:GetPathB(THEME:GetMetric("ModsMenu","Fallback"),"overlay")),
	--rowdefs,onlypn,overridemetrics,paneless)
	ServiceMenu(entries,1,false,false)
}
