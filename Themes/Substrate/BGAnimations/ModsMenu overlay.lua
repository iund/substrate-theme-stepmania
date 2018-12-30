--[[
	return Def.ActorFrame{
	OnCommand=function(s)
		SOUND:PlayOnce(THEME:GetPathS("Options","open"))
	end,
	LoadActor(THEME:GetPathB(THEME:GetMetric("ModsMenu","Fallback"),"overlay")),
	ModsMenu(ModsMenuEntries())
}
--]]

local screenname=lua.GetThreadVariable("LoadingScreen")

local defaultmetrics={ --TODO figure out how to pull these from metrics.ini (ie: get the current screen name)
	meteroffsetx=280,
	metery=-192,
	playernameoffsetx=176,
	playernamey=-204,
	chartnameoffsetx=176,
	chartnamey=-180,
}

local rowtopy=THEME:GetMetric(screenname,"TopRowY")
local rowitemx={ --playerx
	THEME:GetMetric(screenname,"RowItemP1X"),
	THEME:GetMetric(screenname,"RowItemP2X")
}

local rowspacingy=THEME:GetMetric(screenname,"RowSpacingY")
local rowtitlex=THEME:GetMetric(screenname,"RowTitleX")
local exitrowy=THEME:GetMetric(screenname,"ExitRowY")

---

local metrics=defaultmetrics

local foreachplayer=ForeachEnabledPlayer

local state

------------------ Input logic
																																	
local input

local function isexitrow(rowi) return state.row[rowi].exit or false end

local function isonexit(pn) return isexitrow(state.currow[pn]) end

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

local function up(pn) state.cursor[pn]:move(-1) end
local function down(pn) state.cursor[pn]:move(1) end
local function left(pn)
	state.row[state.currow[pn]]:nudge(pn,-1)
	state.cursor[pn]:moveto(state.currow[pn]) --update cursor width
	sound("change")
	MESSAGEMAN:Broadcast("UpdateDQ",{Player=pn})
end
local function right(pn)
	state.row[state.currow[pn]]:nudge(pn,1)
	state.cursor[pn]:moveto(state.currow[pn]) --update cursor width
	sound("change")
	MESSAGEMAN:Broadcast("UpdateDQ",{Player=pn})
end

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
				down(pn) sound("prev")
			end
		elseif attr.GameButton=="MenuDown" and attr.button~="UpRight" then
			if attr.type=="InputEventType_FirstPress" and state.currow[pn]==#state.row then --wrap cursor from bottom row to top
				state.cursor[pn]:moveto(1,cursortween) sound("next")
			elseif state.currow[pn]<#state.row then
				down(pn) sound("next") 
			end
		elseif attr.GameButton=="Select" or attr.GameButton=="MenuUp" or 
				(attr.GameButton=="MenuDown" and attr.button=="UpRight") then --override the default UpRight behavior (ie, move down)
			if attr.type=="InputEventType_FirstPress" and state.currow[pn]==1 then --wrap cursor from top row to bottom
				state.cursor[pn]:moveto(#state.row,cursortween) sound("prev")
			elseif state.currow[pn]>1 then
				up(pn) sound("prev")
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
	local rowtopy=THEME:GetMetric(screenname,"TopRowY")
	local rowitemx=THEME:GetMetric(screenname,"RowItemP"..pn.."X")
	local exitrowy=THEME:GetMetric(screenname,"ExitRowY")

	return Def.ActorFrame{
		InitCommand=function(s) cself=s end,
		OnCommand=cmd(x,rowitemx;y,rowtopy;finishtweening),

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
			cself:x(isexitrow(rowi) and 0 or rowitemx)
			cself:y(isexitrow(rowi) and exitrowy or rowtopy+(rowi-1)*rowspacingy)
			
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

---------------------------




local mm=setmetatable({},{
	__call=function(mm,rowdefs,onlypn,overridemetrics,paneless) --NOTE: the latter 3 are only set for other menus like the selectmusic mods menu
		local metrics={}
		for k,v in next,defaultmetrics,nil do
			metrics[k]=overridemetrics and overridemetrics[k] or v
		end

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

				Actor.xy(s,
					THEME:GetMetric(screenname,"CenterFrameX"),
					THEME:GetMetric(screenname,"CenterFrameY"))
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
						s:x(THEME:GetMetric(screenname,"FrameP"..pn.."X"))
						s:y(THEME:GetMetric(screenname,"FrameP"..pn.."Y"))
						s:diffusealpha(CommonPaneDiffuseAlpha)
					end,
					OnCommand=function(s)
						ApplyUIColor(s,p)
					end
				}

				--difficulty meter
				container[#container+1]=Def.ActorFrame{

					InitCommand=cmd(x,(pn*2-3)*metrics.meteroffsetx;y,metrics.metery),

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
					InitCommand=cmd(x,(pn*2-3)*metrics.playernameoffsetx;y,metrics.playernamey),
					Text=GAMESTATE:GetPlayerDisplayName(p)
				}

				-- chart name
				container[#container+1]=
				Def.BitmapText{
					Font="_common white",
					InitCommand=cmd(x,(pn*2-3)*metrics.chartnameoffsetx;y,metrics.chartnamey;zoom,.75),
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

				--DQ sprite
				local function updateDQ(s,param)
					if param and param.Player~=p then return end
					if not IsCourseMode() and GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Preferred"):IsEasierForSongAndSteps(GetCurSong(),GetCurSteps(p),p)
						or IsCourseMode() and GAMESTATE:GetPlayerState(p):GetPlayerOptions("ModsLevel_Preferred"):IsEasierForCourseAndTrail(GetCurCourse(),GetCurTrail(p),p)
					then
						s:stoptweening() s:linear(.2) s:diffusealpha(1)
					else
						s:stoptweening() s:linear(.2) s:diffusealpha(0)
					end
				end
				container[#container+1]=Def.ActorFrame{ --DQ
					InitCommand=cmd(						
						x,THEME:GetMetric(screenname,"DisqualifyP"..pn.."X");
						y,THEME:GetMetric(screenname,"DisqualifyY")),
			
					UpdateDQMessageCommand=updateDQ,
					OnCommand=updateDQ,

					Def.Quad{
						InitCommand=cmd(
							zoomto,THEME:GetMetric(screenname,"DisqualifyWidth"),
								THEME:GetMetric(screenname,"DisqualifyHeight");
							diffusecolor,0.5,0,0,1),
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

return mm(ModsMenuEntries())