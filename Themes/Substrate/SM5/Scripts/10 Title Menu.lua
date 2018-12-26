do
	local metrics={
		frame={SCREEN_CENTER_X,SCREEN_CENTER_Y},
		headingx=0,
		rowspacingy=24,
		rowtopy=-128
	}

	local state={}

	local container

	local text
	local textblink=function() text:UpdateDiffuseCos(.5) end

	local newitem=function(rowi,rowdef)
		local bt
		return setmetatable(Def.BitmapText{
			Font="_common semibold white",
			Text=rowdef.Name,
			InitCommand=function(s)
				s:x(metrics.headingx)
				s:y((rowi-1)*metrics.rowspacingy+metrics.rowtopy)
				s:diffuse(.85,.85,.85,1)
				s:effectclock("beat")
				bt=s
			end,

			setactive=function(s,flag)
				bt:stoptweening()

				if flag then
					bt:diffusecolor(1,.5,.5,1)
					text=bt
				else
					bt:diffuse(.85,.85,.85,1)
				end
				bt:linear(0.15)
				bt:zoom(flag and 1.1 or 1)
			end,

		},{__index=rowdef})
	end

	local moveto=function(rowi)
		state.row[state.currow]:setactive(false)
		state.row[rowi]:setactive(true)
		state.currow=rowi
	end

	local movecursor=function(dir)
		local nextrow=state.currow
		nextrow=clamp(nextrow+dir,1,#state.row)
		moveto(nextrow)
	end
	
	local input
	input=function(attr)
		local p=attr.PlayerNumber
		local pn=PlayerIndex[p]

		if pn and attr.type=="InputEventType_FirstPress" then
			if attr.GameButton=="MenuLeft" or attr.GameButton=="MenuUp" then movecursor(-1)
			elseif attr.GameButton=="MenuRight" or attr.GameButton=="MenuDown" then movecursor(1)
			elseif attr.GameButton=="Start" then 
				SCREENMAN:PlayStartSound()
				local scr=GetScreen()
				local row=state.row[state.currow]

				if row.PlayMode then GAMESTATE:SetCurrentPlayMode(row.PlayMode) end
				if row.Style then GAMESTATE:SetCurrentStyle(row.Style) end
				GAMESTATE:JoinInput(p) --sets the style for us if unset

				scr:RemoveInputCallback(input)
				scr:SetNextScreenName(row.Screen)
				scr:StartTransitioningScreen("SM_GoToNextScreen")

			elseif attr.GameButton=="Back" then
				GetScreen():RemoveInputCallback(input)
				GetScreen():Cancel()
			end
		end
	end

	SimpleMenu=setmetatable({},{
		__call=function(mm,rowdefs)
			state.currow=1
			state.row={}

			container=Def.ActorFrame{
				InitCommand=cmd(SetUpdateFunction,textblink),

				OnCommand=function(s)
					GetScreen():AddInputCallback(input)
					Actor.xy(s,unpack(metrics.frame))
					movecursor(0)
				end,
			
				OffCommand=function(s)
				end,
			}

			--set rows:

			local ctroff=#container
			for i,rowdef in next,rowdefs,nil do

				local row=newitem(i,rowdef)
				container[ctroff+i]=row
				state.row[i]=row
			end

			return container
		end,
		__index=rowtypes
	})

end