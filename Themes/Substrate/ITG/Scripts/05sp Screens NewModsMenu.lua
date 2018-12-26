--[[BGA version:
Capture.NewModsMenu=function(s)
	local r=Capture.ActorFrame.GetChildren(s)
	local colsctr=r.children[4].children[1] --columns
	local cs={}
	for i=1,table.getn(colsctr.children) do
		local col=colsctr.children[i].children[1]
		local rrows=col.children
		local rows={}
		for r,rrow in next,rrows,nil do
			local row=rrow.children[1]
			rows[r]={ self=row.self, text={} }
			for i,text in next,row.children,nil do rows[r].text[i]=text.children[1] end
		end
		cs[i]={ self=col.self, rows=rows }
	end
	local bcctr=r.children[5] --breadcrumb
	local bc={ self=bcctr.self, text={} }
	for t,text in next,bcctr.children[1].children,nil do
		bc.text[t]=text.children[1]
	end
	return {
		prompt={
			self=r.children[1].self,
			text=r.children[1].children[1].children[1].children[1],
			--highlight=r.children[1].children[1].children[2].children[1],
		},
		frame={
			self=r.self,
			panesprite=r.children[2].children[1],
			cursor=r.children[3].children[1],
			cols=cs,
			breadcrumb=bc,
			navhelp=r.children[6]
		}
	}
end
--]]

-- [[default.xml version:
Capture.NewModsMenu=function(s)
	local root=Capture.ActorFrame.GetChildren(s)

	local body=root.children[2]
	local header=body.children[2]
	local footer=root.children[3]

	--columns
	local colsctr=body.children[4]
	local cs={}
	for i=1,table.getn(colsctr.children) do
		local col=colsctr.children[i]
		local rrows=col.children
		local rows={}
		for r,rrow in next,rrows,nil do
			local row=rrow
			rows[r]={ self=row.self, text={} }
			for i,text in next,row.children,nil do rows[r].text[i]=text end
		end
		cs[i]={ self=col.self, rows=rows }
	end

	--breadcrumb
	local bcctr=header.children[1]
	local bc={ self=bcctr.self, text={} }
	for t,text in next,bcctr.children,nil do
		bc.text[t]=text
	end
	
	return { --pane
		self=root.self,
		mask=root.children[1],
		body={
			self=body.self,
			bg=body.children[1],
			header={
				self=header.self,
				breadcrumb=bc,
				playerinfo={
					self=header.children[2].self,
					name=header.children[2].children[1],
					chart=header.children[2].children[2],
					mods=header.children[2].children[3],
					difficulty={
						frame=header.children[2].children[4],
						meter=header.children[2].children[5].self,
						text=header.children[2].children[5].children[1]
					},
				},
			},
			cursor=body.children[3],
			cols=cs,
			colsctr=colsctr.self,
		},
		footer={
			self=footer.self,
			bg=footer.children[1],
			prompt={
				self=footer.children[2].self,
				text=footer.children[2].children[1],
			},
			navhelp=footer.children[3],
		},
	}
end
--]]

Screens.NewModsMenu={
		Init=function(s)
			Env().NewModsMenu={}
			CachedText={} --compatibility table to accommodate existing mods menu functions. this whole thing could be rewritten from scratch but CBA.
		end,
		
	--screen flow
		PlayerPane={
			On=function(s)
			--TODO: Unhardcode the actor positions and tweens
				local pn=s:getaux()
				Capture.ActorFrame.ApplyPNToChildren(s,s:getaux())
				s:visible(Bool[IsPlayerEnabled(pn)])

				local pane=Capture.NewModsMenu(s)
				Env().NewModsMenu[pn]={
					Pane=pane,
					MenuStack={},
					CursorStack={},
					CurCol=0,
				}

				pane.self:x(GetEnv("ServiceMenu") and SCREEN_CENTER_X or SCREEN_CENTER_X+(pn*2-3)*SCREEN_WIDTH/4)
				pane.self:y(SCREEN_CENTER_Y)

				----Body
				pane.body.self:y(248)

				--Set mask
				--TODO separate player masks, how do??
				pane.mask:y(-40)
				pane.mask:zoomto(pane.body.bg:GetWidth(),pane.body.bg:GetHeight())
				pane.mask:blend("noeffect")
				pane.mask:ztestmode("writeonfail")
				pane.mask:zbuffer(Bool[true])
				for _,o in next,{pane.body.self},nil do o:ztestmode("writeonfail") end

				Screens.NewModsMenu.TweenCloseMenu(pn)
				pane.self:finishtweening()

				--column and row spacing
				local spacingx=128
				local spacingy=16
				local cols=table.getn(pane.body.cols)
				for c,col in next,pane.body.cols,nil do
					col.self:x(spacingx*(c-0.5)-spacingx*cols/2)
					local rows=table.getn(col.rows)
					for r,row in next,col.rows,nil do
						row.self:y(spacingy*(r-0.5)-spacingy*rows/2)
						for t,text in next,row.text,nil do
							text:shadowlength(0)
							text:zoom(0.75)
						end
						CachedText[r]=CachedText[r] or {} --compatibility
					end				
				end
				
				----Header
				pane.body.header.self:y(-148)

				local bctexts=pane.body.header.breadcrumb.text
				for i,bc in next,bctexts,nil do bc:shadowlength(0) bc:zoom(0.75) end

				local pi=pane.body.header.playerinfo
--[[
				pi.name:settext(PlayerName(pn))
				pi.chart:settext(CurSteps(pn):GetDescription())
				pi.mods:settext(PlayerMods(pn))
--]]
				for _,t in next,{pi.name,pi.chart,pi.mods},nil do t:shadowlength(0) end

				local dx=(pn*2-3)*164
				pi.difficulty.frame:x(dx)
				pi.difficulty.meter:x(dx)

				pi.name:y(-24)
				pi.mods:y(24)
--[[
				playerinfo={
					self=header.children[2].self,
					name=header.children[2].children[1],
					chart=header.children[2].children[2],
					mods=header.children[2].children[3],
					difficulty={
						frame=header.children[2].children[4],
						meter=header.children[2].children[5].self,
						text=header.children[2].children[5].children[1]
					},
				},
--]]

				----Footer
				pane.footer.self:y(168)
				pane.footer.prompt.text:shadowlength(0)

				pane.footer.prompt.text:ztestmode("writeonpass")
				pane.footer.prompt.text:settext("Press [] to select options")
				
			end,
			Off=function(s,pn)
			end,
		},
		On=function(s) --runs before PlayerPane On.
			FitScreenToAspect(GetScreen())
			s:effectperiod(math.huge) LuaEffect(s,"Update") --timer
			Env().NewModsMenu.Opened=false
		end,
		InitMenu=function(menu)
			Env().NewModsMenu.Menu=menu
			
			if GetEnv("ServiceMenu") or GetEnv("WorkoutMode") then
				ForeachPlayer(function(pn)	if IsPlayerEnabled(pn) then Screens.NewModsMenu.OpenMenu(pn,menu) Screens.NewModsMenu.TweenOpenMenu(pn) end end)
				Broadcast("TweenAwayStageBox") 
				Env().NewModsMenu.Opened=true
			end
		end,
		FirstUpdate=function(s)
			--todo? shouldn't be needed in theory because its a custom screen, and firstupdate should be avoided as much as possible.
		end,
		Update=function(s)
			--go to next screen after 3 seconds if start wasn't pressed
			if Env().NewModsMenu and
				(Env().NewModsMenu.Opened==false and s:GetSecsIntoEffect()>3 or s:GetSecsIntoEffect()>90 and GetPref("MenuTimer")) then
				s:stopeffect()
				for pn=1,2 do Screens.NewModsMenu.TweenCloseMenu(pn) Env().NewModsMenu[pn].Finished=true end
				Broadcast("TweenBackStageBox") 
				Screens.NewModsMenu.NextScreen()
			end
		end,
		Alarm=function()
			SetScreen(Branch.SelectMusicNext())
		end,
		Off=function(s) --Run this last when the screen is about to change
			ForeachPlayer(function(pn)
				--clear the stack
				local menustack=Env().NewModsMenu[pn].MenuStack for i=1,stack.size(menustack) do stack.pop(menustack) end
				local cursorstack=Env().NewModsMenu[pn].CursorStack for i=1,stack.size(cursorstack) do stack.pop(cursorstack) end
			end)
			Env().NewModsMenu=nil
		end,

--

		TweenAwayStageBox=function(s)
			s:finishtweening() s:decelerate(0.5) s:addy(-288)
		end,
		
		TweenBackStageBox=function(s)
			s:finishtweening() s:accelerate(0.5) s:y(SCREEN_CENTER_Y-80)		
		end,

		TweenOpenMenu=function(pn)
			local menuobj=Env().NewModsMenu[pn]

			local o=menuobj.Pane.body.self
			o:stoptweening() o:decelerate(0.5) o:y(-40)

			local n=menuobj.Pane.footer.navhelp.self
			n:stoptweening() n:decelerate(0.5) n:y(0)
			
			local t=menuobj.Pane.footer.prompt.text
			t:stoptweening() t:decelerate(0.5) t:y(-288)
		end,

		TweenCloseMenu=function(pn)
			local menuobj=Env().NewModsMenu[pn]

			local o=menuobj.Pane.body.self
			o:stoptweening() o:accelerate(0.5) o:y(248)

			local n=menuobj.Pane.footer.navhelp.self
			n:stoptweening() n:accelerate(0.5) n:y(288)

			local t=menuobj.Pane.footer.prompt.text
			t:stoptweening() t:accelerate(0.5) t:y(0)
		end,

--

		OpenMenu=function(pn,entry)
			local menuobj=Env().NewModsMenu[pn]
			menuobj.CurCol=wrap(menuobj.CurCol+1,1,table.getn(menuobj.Pane.body.cols))

			local ty=Screens.NewModsMenu.GetType(entry)
			if ty~=ROW_TYPE_SUBMENU then --mod
				--find which option in the row is selected and put the cursor there:
				local r=ModsMenu.ModLineRaw(entry)
				r.State={} for i=1,table.getn(r.Choices) do r.State[i]=false end
				local parentrow=stack.top(menuobj.CursorStack)
				Env()._tabline=parentrow --hacky af
				r.LoadSelections(r,r.State,pNum[pn])
				local sel=ty==ROW_TYPE_SLIDER and stack.top(menuobj.CursorStack) or table.findkey(r.State,true)
				Env()._tabline=nil 
				stack.push(menuobj.MenuStack,r)
				stack.push(menuobj.CursorStack,sel or 1) --default to first entry as a safety net if nothing was picked

			else --submenu: pick the first entry
				stack.push(menuobj.MenuStack,entry)
				stack.push(menuobj.CursorStack,1)

				--Preview mod values
				local numcols=table.getn(menuobj.Pane.body.cols)
				local coli=wrap(stack.size(menuobj.MenuStack),1,numcols) --want the column right of current
				Screens.NewModsMenu.UpdateCol(pn,coli,entry)

			end
			Screens.NewModsMenu.UpdateAllCols(pn,1)
			if ty==ROW_TYPE_SLIDER or ty==ROW_TYPE_SUBMENU then Screens.NewModsMenu.Move(pn,0) end --refresh the column
		end,
		CloseMenu=function(pn)
			local menuobj=Env().NewModsMenu[pn]

			--Clear out old text:
			for r,row in next,menuobj.Pane.body.cols[wrap(menuobj.CurCol+1,1,table.getn(menuobj.Pane.body.cols))].rows,nil do
				for t,text in next,row.text,nil do text:settext("") end
			end

			menuobj.CurCol=wrap(menuobj.CurCol-1,1,table.getn(menuobj.Pane.body.cols))
			stack.pop(menuobj.MenuStack)
			stack.pop(menuobj.CursorStack)
			Screens.NewModsMenu.UpdateAllCols(pn,-1)

			if stack.size(menuobj.MenuStack)==0 then
				menuobj.Pane.footer.prompt.text:settext("Ready, waiting for "..PlayerName(math.mod(pn,2)+1).."...")
				--player becomes ready
				Screens.NewModsMenu.TweenCloseMenu(pn) menuobj.Finished=true
			end

			if stack.size(Env().NewModsMenu[1].MenuStack)==0 and stack.size(Env().NewModsMenu[2].MenuStack)==0 then
				--all players are ready, go to next screen
				Broadcast("TweenBackStageBox") Screens.NewModsMenu.NextScreen()
			end

		end,

		Move=function(pn,dir) --dir:  -1=left  +1=right
			local menuobj=Env().NewModsMenu[pn]
			local r=stack.top(menuobj.MenuStack)
			if Screens.NewModsMenu.GetType(r)==ROW_TYPE_SUBMENU then --cursor is on a menu entry

--[[
				--skip over disabled rows:
				for i=stack.top(menuobj.CursorStack),table.getn(stack.top(menuobj.MenuStack)) do
					local line=stack.top(menuobj.MenuStack).Contents[i]
					local ty=Screens.NewModsMenu.GetType(line)
					if ty~=ROW_TYPE_SUBMENU then
						local r=ModsMenu.ModLineRaw(line)
						
						if r.EnabledForPlayers and not table.find(r.EnabledForPlayers,pNum[pn]) then
							dir=dir+clamp(dir,-1,1)
						end
						if i>=table.getn(stack.top(menuobj.MenuStack)) then dir=0 end
					end
				end
--]]

				--move the cursor:
				menuobj.CursorStack[stack.size(menuobj.CursorStack)]=clamp(stack.top(menuobj.CursorStack)+dir,1,table.getn(r.Contents))

				--preview menu contents on next column:
				if Screens.NewModsMenu.GetType(r.Contents[stack.top(menuobj.CursorStack)])==ROW_TYPE_SUBMENU then
					local entry=r.Contents[stack.top(menuobj.CursorStack)]
					local numcols=table.getn(menuobj.Pane.body.cols)

					local coli=wrap(stack.size(menuobj.MenuStack)+1,1,numcols) --want the column right of current
					Screens.NewModsMenu.UpdateCol(pn,coli,entry)
				else
					--dim the rows other than selected
					for r,row in next,menuobj.Pane.body.cols[wrap(menuobj.CurCol+1,1,table.getn(menuobj.Pane.body.cols))].rows,nil do
						for t,text in next,row.text,nil do
							text:diffusealpha(r==stack.top(menuobj.CursorStack) and 1 or 0.5)
						end
					end
				end

				
			else --moving in a mod
				local ty=Screens.NewModsMenu.GetType(r)

				local numcols=table.getn(menuobj.Pane.body.cols)
				local coli=wrap(stack.size(menuobj.MenuStack),1,numcols)

				if ty==ROW_TYPE_LIST then	--move the cursor:
					menuobj.CursorStack[stack.size(menuobj.CursorStack)]=wrap(stack.top(menuobj.CursorStack)+dir,1,table.getn(r.Choices))
					--menuobj.CursorStack[stack.size(menuobj.CursorStack)]=clamp(stack.top(menuobj.CursorStack)+dir,1,table.getn(r.Choices))

					--get the cursor position and fire it to SaveSelections in a way that's also compatible with OptionRow
					local sel=stack.top(menuobj.CursorStack)
					for i=1,table.getn(r.State) do r.State[i]=sel==i end
					r.SaveSelections(r,r.State,pNum[pn])

					Screens.NewModsMenu.UpdateCol(pn,coli,r)
				elseif ty==ROW_TYPE_MULTI_LIST then --just move the cursor, don't update
					menuobj.CursorStack[stack.size(menuobj.CursorStack)]=wrap(stack.top(menuobj.CursorStack)+dir,1,table.getn(r.Choices))
					--menuobj.CursorStack[stack.size(menuobj.CursorStack)]=clamp(stack.top(menuobj.CursorStack)+dir,1,table.getn(r.Choices))

				elseif ty==ROW_TYPE_SLIDER then --move slider value
					--
					local currow=stack.top(menuobj.CursorStack)

					--set up state for SaveSelections:
					local sel=table.findkey(r.State,true)
					sel=wrap(sel+dir,1,table.getn(r.Choices))
					for i=1,table.getn(r.State) do r.State[i]=sel==i end

					r.SaveSelections(r,r.State,pNum[pn])

					--update onscreen text
					local text=r.handler.format(r,pn,r.handler.get(r,pn))
					menuobj.Pane.body.cols[coli].rows[currow].text[1]:settext(text)
				end
			end
			Screens.NewModsMenu.SetCursor(pn)
		end,
		MoveRow=function(pn,dir) Screens.NewModsMenu.Move(pn,Screens.NewModsMenu.GetType(stack.top(Env().NewModsMenu[pn].MenuStack))==ROW_TYPE_SLIDER and -dir or dir) end,
		
		Toggle=function(pn,entry)
			local menuobj=Env().NewModsMenu[pn]
		
			local numcols=table.getn(menuobj.Pane.body.cols)
			--local coli=wrap(stack.size(menuobj.MenuStack)+1,1,numcols)
			local coli=wrap(stack.size(menuobj.MenuStack),1,numcols)

			local r=ModsMenu.ModLineRaw(entry)

			local state={}
			for i=1,table.getn(r.Choices) do state[i]=false end
			r.LoadSelections(r,state,pNum[pn])

			local sel=table.findkey(state,true)
			sel=math.mod(sel,table.getn(r.Choices))+1
			for i=1,table.getn(state) do state[i]=sel==i end

			r.SaveSelections(r,state,pNum[pn])

			if r.OneChoiceForAllPlayers then Broadcast("UpdateAllPanes") end

			Screens.NewModsMenu.UpdateCol(pn,coli,stack.top(menuobj.MenuStack))
		end,

--

		UpdateAllPanes=function(s) --Called from "UpdateAllPanes" messageman. s = overlay container
			ForeachPlayer(Screens.NewModsMenu.UpdateAllCols)
		end,

		UpdateAllCols=function(pn,tweendir)	--tweendir: 1=slide left (open entry), -1=slide right (close entry)
			local menuobj=Env().NewModsMenu[pn]

			local numcols=table.getn(menuobj.Pane.body.cols)
			local stacksize=stack.size(menuobj.MenuStack)	

--[[
			--find which column to wrap

			1 2 3 4 5 6
			1 2 3 1 2 3
			
			a
					3 4 5
					3 1 2
			b
				2 3 4
				2 3 1
				
			then col 2 needs to be wrapped
--]]
--[[ todo:
			Trace("wrapcol "..(wrap(stacksize+tweendir,1,numcols)))
			local wrapcol=menuobj.Pane.body.cols[wrap(stacksize+tweendir,1,numcols)].self
			
			local spacing=128 --todo
			wrapcol:x(numcols*spacing*-tweendir)
			wrapcol:finishtweening()
--]]

			--refresh col
			for i=1,numcols do
				local entryi=stacksize-numcols+i
				if entryi>0 then
					local coli=wrap(entryi,1,numcols)
					local entry=menuobj.MenuStack[entryi]
					Screens.NewModsMenu.UpdateCol(pn,coli,entry)
				end

--[[ todo:
				if tweendir then
					menuobj.Pane.body.cols[i].self:x(i*-tweendir*128)
				end
--]]			

			end

			--breadcrumb
			local bctext={} for i,m in next,menuobj.MenuStack,nil do bctext[i]=IsTable(m) and m.Name or "" end
			menuobj.Pane.body.header.breadcrumb.text[1]:settext(join(" > ",bctext))

			--cursor
			if stack.size(menuobj.CursorStack)>0 then Screens.NewModsMenu.SetCursor(pn) end
		end,

		UpdateCol=function(pn,coli,entry)
			Env()._tabline=stack.top(Env().NewModsMenu[pn].CursorStack) --get current row
			local list=ModsMenu.ModLineRaw(entry)

			local menuobj=Env().NewModsMenu[pn]
			local updatecol=menuobj.Pane.body.cols[coli]
			local updatecontentcol=menuobj.Pane.body.cols[wrap(coli+1,1,table.getn(menuobj.Pane.body.cols))]

			if list.Contents then --submenu list
				for r,row in next,updatecol.rows,nil do
					local title=""
					local value=""

					if list.Contents[r] then
						Env()._tabline=r --such a dirty hack, yolo
						local rd=ModsMenu.ModLineRaw(list.Contents[r]) --this reads _tabline because most of the RowType functions depend on it or CachedText, todo: find a better way to do it
						title=Screens.NewModsMenu.GetTitle(rd,pn)..(
							 Screens.NewModsMenu.GetType(rd)==ROW_TYPE_SUBMENU and " >" or "")
						
						
						if Screens.NewModsMenu.GetType(list.Contents[r])~=ROW_TYPE_SUBMENU then value=Screens.NewModsMenu.GetValue(rd,pn) end
					end
					row.text[1]:diffusealpha(1) --undim text
					row.text[1]:settext(title)
					row.text[2]:settext("")

					updatecontentcol.rows[r].text[1]:settext("")
					updatecontentcol.rows[r].text[2]:settext(value)
					updatecontentcol.rows[r].text[2]:diffusealpha(0.5)

					CachedText[r][pn]=value
				end
			else --mod
			--(use the elseif if you want the other mod row values to remain visible when moving a slider value) -- elseif Screens.NewModsMenu.GetType(entry)~=ROW_TYPE_SLIDER then --mods
				local r=list
				local value=""

				if r.LoadSelections then
					local l={} for i=1,table.getn(r.Choices) do l[i]=false end
					r.LoadSelections(r,l,pNum[pn])

					for ri,row in next,updatecol.rows,nil do
						CachedText[ri][pn]=""
						value=r.Choices[ri]
						local highlighted=l[ri]
				
						row.text[1]:settext("")
						row.text[2]:diffusealpha(highlighted and 1 or 0.5)
						row.text[2]:settext(value or "")
					end
				end
			end
			Env()._tabline=nil --such a dirty hack, yolo
		end,

		SetCursor=function(pn)
			local menuobj=Env().NewModsMenu[pn]
			local x=menuobj.Pane.body.cols[menuobj.CurCol].self:GetX()

			local row=menuobj.Pane.body.cols[menuobj.CurCol].rows[stack.top(menuobj.CursorStack)]
			local y=row.self:GetY()
			local width=row.text[1]:GetWidth()*row.text[1]:GetZoomX() + row.text[2]:GetWidth()*row.text[2]:GetZoomX()
			
			local cursor=menuobj.Pane.body.cursor
			
			cursor.self:stoptweening()
			cursor.self:linear(0.15)
			Actor.xy(cursor.self,x,y)
			
			for c,child in next,cursor.children,nil do child:stoptweening() child:linear(0.15) end
			SetHighlightWidth(cursor,width)
		end,

--

		GetTitle=function(rowdata)
			local title=(IsFunction(rowdata) and rowdata() or rowdata).Name
			return Languages[CurLanguage()].Menus[title] or title
		end,
		
		GetValue=function(rowdata,pn)
			return ModsMenu.GetInfoText(pn,ModsMenu.ModLineRaw(rowdata)) or ""
		end,

		GetType=function(entry)
			--There must be a more efficient way to do this:
			if IsTable(entry) and entry.Contents then return ROW_TYPE_SUBMENU
			elseif IsTable(entry) and entry.Screen then return ROW_TYPE_SCREEN
			elseif IsTable(entry) and entry.Action then return ROW_TYPE_ACTION
			elseif IsTable(entry) and entry.Command then return ROW_TYPE_COMMAND
			else
				local r=ModsMenu.ModLineRaw(entry)
				return r.type or
					--no type defined; guess it: (we shouldn't be using this because it assumes r.handler is there)
					r.handler and (
						r.handler.getchoices and (r.SelectType=="SelectMultiple" and ROW_TYPE_MULTI_LIST or ROW_TYPE_LIST)
						or r.handler.format and ROW_TYPE_SLIDER
						or r.handler.gettext and ROW_TYPE_DUMMY)
					or ROW_TYPE_DUMMY --safety net
			end
		end,

--

		--AutoRepeatInput fires on each initial press/autorepeat. On initial press, Input() gets fired after.
		AutoRepeatInput=function(pn,dirtype,dir) --dirty: 1=LR, 2=UD, dir: -1=left, 1=right
			local tab={ {[-1]="MenuLeft",[1]="MenuRight"}, {[-1]="MenuUp",[1]="MenuDown"}, }
			if GetScreen():getaux()==1 then Screens.NewModsMenu.Input(tab[dirtype][dir],pNum[pn],true) end
			GetScreen():aux(1)
		end,
		
		Back=function(screen) Env().NextScreen=screen Broadcast("PrevScreen") return screen end,
		NextScreen=function() Broadcast("NextScreen") end,
		BranchScreen=function() SetScreen(Env().NextScreen) Env().NextScreen=nil end,
		GoToNextScreen=function(screen) SetScreen(screen) end,
		GoToPrevScreen=function(screen) SetScreen(screen) end,

		Input=function(btn,p,ar) --handles Start, Menu buttons, Select.
			local pn=GetEnv("ServiceMenu") and 1 or pText[p]

			GetScreen():aux(0) --clear autorepeat flag

			if pn and Env().NewModsMenu and not Env().NewModsMenu[pn].Finished then
				if stack.size(Env().NewModsMenu[pn].MenuStack)==0 then
					if btn=="Start" then --open the menu
						
						if stack.size(Env().NewModsMenu[1].MenuStack)==0 and stack.size(Env().NewModsMenu[2].MenuStack)==0 then
							Broadcast("TweenAwayStageBox")
						end

						Screens.NewModsMenu.TweenOpenMenu(pn)
						Env().NewModsMenu.Opened=true
						Screens.NewModsMenu.OpenMenu(pn,Env().NewModsMenu.Menu)
					end
					return
				end

				local menuobj=Env().NewModsMenu[pn]
				local entryi=stack.top(menuobj.CursorStack)
				local curentry=stack.top(menuobj.MenuStack)

				if btn=="Start" then
					local ty=Screens.NewModsMenu.GetType(curentry) --curentry is the menu you're already on, not the highlighted entry in it.
					if ty==ROW_TYPE_SUBMENU then

						if curentry.Contents[entryi] then --valid row (not an exit row)
							local entry=curentry.Contents[entryi]
							local ty=Screens.NewModsMenu.GetType(entry)

							if ty==ROW_TYPE_SUBMENU then --entering a submenu
								Screens.NewModsMenu.OpenMenu(pn,entry)
							elseif ty==ROW_TYPE_COMMAND then
								GameCommand(entry.Command,pn)
							elseif ty==ROW_TYPE_ACTION then
								entry.Action(pn)
							elseif ty==ROW_TYPE_SCREEN then
								Env().NextScreen=entry.Screen
								GetScreen():playcommand("Off") GetScreen():queuecommand("BranchScreen") --queuecommand means it waits for tween-out then runs
							elseif ty==ROW_TYPE_LIST or ty==ROW_TYPE_MULTI_LIST or ty==ROW_TYPE_SLIDER then --enter the mod so the user can change values with arrow buttons
								Screens.NewModsMenu.OpenMenu(pn,entry)
							elseif ty==ROW_TYPE_BOOL then
								Screens.NewModsMenu.Toggle(pn,ModsMenu.ModLineRaw(entry)) --toggle on/off
							end
						else --hitting start on exit row
							Screens.NewModsMenu.CloseMenu(pn)
						end
					elseif ty==ROW_TYPE_MULTI_LIST then --toggle the selected value
						local r=stack.top(menuobj.MenuStack)
						local sel=stack.top(menuobj.CursorStack)
						r.State[sel]=not r.State[sel]
						r.SaveSelections(r,r.State,pNum[pn])

						Screens.NewModsMenu.UpdateCol(pn,menuobj.CurCol,r)

					else --not on a entry (eg, inside a mod selector)
						Screens.NewModsMenu.CloseMenu(pn) --back out
					end
				elseif btn=="Select" then
					Screens.NewModsMenu.CloseMenu(pn)
				elseif btn=="MenuLeft" then
					Screens.NewModsMenu.Move(pn,-1)
				elseif btn=="MenuRight" then
					Screens.NewModsMenu.Move(pn,1)
				elseif btn=="MenuDown" then
					Screens.NewModsMenu.MoveRow(pn,1)
				elseif btn=="MenuUp" then
					Screens.NewModsMenu.MoveRow(pn,-1)
				elseif btn=="Back" then
					--Hit back. DelayedBack applies except for the escape key.
				end
			end
		end,
	}