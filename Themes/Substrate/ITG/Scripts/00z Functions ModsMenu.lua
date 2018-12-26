ModsMenu={
	--tabs
	--Only show tabs in gameplay menus. Prev and NextScreen= is ignored in editing mode, and the service menu crashes when leaving predefined submenu screens (eg, ScreenProfileOptions)
	ShowTabList=function(page) return false end,--GetEnv("ProfileLoaded") and page.Contents and ModsMenu.IsSubmenuLine(page.Contents[1]) or false end, --submenus cannot be shared with mod rows on the same screen

	--menu stack
	GetTop=function(parentdistance) return Env().MenuStack and Env().MenuStack[table.getn(Env().MenuStack)-(parentdistance or 0)] or {} end,
	Push=function(submenu) Env().MenuStack[table.getn(Env().MenuStack)+1]=submenu end,
	Pop=function() Env().MenuStack[table.getn(Env().MenuStack)]=nil end,
	BreadcrumbText=function() local out={} local stack=Env().MenuStack or {} for i=1,table.getn(stack) do out[i]=stack[i].Name end return join("/",out) end,
	
	--screen branching
	Branch=function(curscr,exitscr,isnext)
		if Frame then --in 3.95, NextScreen= is evaluated 3 times when exiting
			if isnext and Frame:getaux()>0 and ModsMenu.ShowTabList(ModsMenu.GetTop()) then
				ModsMenu.Push(ModsMenu.GetTop().Contents[Frame:getaux()])
			else
				ModsMenu.Pop()
			end
		end
		if not isnext or not Frame then ModsMenu.Off() end --values are exported AFTER FrameOff.
		return table.getn(Env().MenuStack)==0 and exitscr or Env().MenuStack[table.getn(Env().MenuStack)].Screen or curscr
	end,
	
	--setup
	Init=function(top)
		CachedText={}
		if not Env().MenuStack or table.getn(Env().MenuStack)==0 then Env().MenuStack={top} end
		local page=ModsMenu.GetTop()
		return string.rep('s,',ModsMenu.ShowTabList(page) and Metrics.ModsMenu.NumItems or table.getn(page.Contents))
	end,
	GetPageType=function() --1=submenu list, 2=player cursors, 3=shared cursor
		local page=ModsMenu.GetTop()
		return ({
			--forceallplayers is necessary on service menu, or a blank screen gets loaded
			'forceallplayers;explanations;together;smnavigation','explanations','explanations;together'
		})[page.Type or page.Contents and 1 or 3] --smnavigation is used for submenu lists. (eg, service menu root)
	end,
	RowY=function() --gets run at once before rows load
		--TODO: First line y position is wrong on net screen.
		local line=GetScreen():getaux()
		GetScreen():aux(math.mod(GetScreen():getaux(),Metrics.ModsMenu.NumItems)+1)
		--if ModsMenu.ShowTabList(page) and line<1 then return Metrics.ModsMenu.ItemsTopY-16 end
		return Metrics.ModsMenu.ItemsTopY+(Metrics.ModsMenu.ItemsHeight/Metrics.ModsMenu.NumItems)*line
	end,
	
	--lines
	IsSubmenuLine=function(rowdata) return not not (IsTable(rowdata) and rowdata.Name and (rowdata.Contents or rowdata.Command or rowdata.Action or rowdata.Screen)) end,
	IsContents=function(rowdata) return not not (rowdata.Contents and not (IsTable(rowdata.Contents[1]) and rowdata.Contents[1].Name)) end,
-- IsContents=function(rowdata) return rowdata.Contents and (type(rowdata.Contents[1])~='table' or not rowdata.Contents[1].Name) end,

	CurLine=function() return Env()._tabline or Env()._reloadline or table.getn(CachedText) end,

	NextLine=function()
		local page=ModsMenu.GetTop()
		local insert=table.insert
		local line=table.getn(CachedText)+1 --ModsMenu.CurLine()+1
		local rowdata=page.Contents[line]
		CachedText[line]={}
		local out=ModsMenu.ShowTabList(page) and (line==1 and "lua,RowType.TabList(ModsMenu.GetTop())" or "lua,RowType.Dummy()")
			or (ModsMenu.IsSubmenuLine(rowdata) and "list,OptionRow"
			or IsString(rowdata) and rowdata
			or "lua,ModsMenu.ModLine()")
		return out
	end,
	ModLine=function()
		local page=ModsMenu.GetTop()
		local line=ModsMenu.CurLine()
		local rowdata=page.Contents[line]
		return ModsMenu.ModLineRaw(rowdata)
	end,
	ModLineRaw=function(rowdata)
		local out
		if IsTable(rowdata) and IsFunction(rowdata[1]) then --mods functions - {RowFunction, ...}
			local insert=table.insert
			local args={} for i=2,table.getn(rowdata) do insert(args,rowdata[i]) end --remove 1st item (function name)
			out=rowdata[1](unpack(args))
		else --other
			out=IsFunction(rowdata) and rowdata() or rowdata
		end
		--assert(out.Choices and table.getn(out.Choices)>0, table.dump(out))
		return out
	end,
	SubmenuLine=function()
		local page=ModsMenu.GetTop()
		local insert=table.insert
		local line=ModsMenu.CurLine()
		local rowdata=page.Contents[line]

		return
			IsTable(rowdata) and --submenu
				"name,"..(Languages[CurLanguage()].Menus[rowdata.Name] or rowdata.Name)..";"
				..(rowdata.Contents and sprintf("lua,function() ModsMenu.Push(ModsMenu.GetTop().Contents[%i]) end;",line) or "")
				..(rowdata.Command and rowdata.Command..";" or "")
				--..(rowdata.Action and sprintf("lua,loadstring(%q);",string.dump(rowdata.Action)) or "")
				--..(rowdata.Action and string.gsub(string.format("lua,loadstring(%q)",string.dump(rowdata.Action)),";","\\059")or "")
				--..(rowdata.Action and sprintf("lua,ModsMenu.GetTop().Contents[%i].Action;",line) or "")
				..(rowdata.Action and (IsString(rowdata.Action) and rowdata.Action..";" or sprintf("lua,ModsMenu.GetTop().Contents[%i].Action;",line)) or "")
				..";screen,"..(rowdata.Screen or ModsMenu.IsContents(rowdata) and "ServiceMenuContents" or "ServiceMenu")
			or IsFunction(rowdata) and luastr(rowdata) --entry
	end,
	
	--finish
	ItemColor=function(col,static) return ({"0,0,0,1","1,1,1,1","0.5,0.5,0.5,1"})[col] end,
	AfterInit=function() --Runs on each explanation text change.
		if not rows then return end 

		--initialise mods status text
		for pn=1,2 do
			for line=1,table.getn(rows) do
				local modicon=rows[line].icons[pn]
				modicon.self:visible(Bool[true])
				modicon.sprite:visible(Bool[false])
				modicon.text:shadowlength(0)
			end
		end
	
--		ForeachPlayer(function(pn) ModsMenu.MoveCursor(linehighlights[pn]) end)

		--init tab bar text
		local page=ModsMenu.GetTop()
		if ModsMenu.ShowTabList(page) then for j,o in next,rows[1].items.text,nil do local c=j==1 and 0 or 1 o:diffuse(c,c,c,1) end end

		--init tab contents
		if page.Contents and ModsMenu.ShowTabList(page) then
			local r=RowType.TabList(page)
			r.Line=1 --Assume tabs is top row.
			ForeachPlayer(function(pn) r.settabs(r,pn,Env().SelectedTab or 1) end)
		end
	end,

	GetCurrentRow=function(pn)
		local currow=0
		for i=1,table.getn(rows) do
			if rows[i].icons[pn].text:GetText()=="" then currow=i end
			rows[i].icons[pn].text:settext(" ")
--			Trace(sprintf("row %d text%d=%q",i,pn,rows[i].icons[pn].text:GetText()))
--			Trace(sprintf("title=%q",rows[i].title:GetText()))
		end
		return currow
	end,

	--interaction
	MoveCursor=function(lh) --Always gets run on both players when changing a row, gets run on both players twice when moving a shared cursor
		if not rows then return end --catch a crash on SMO login screen
--		local pn=lh:getaux()

		local pn=linehighlights[2]==lh and 2 or 1

		--detect currently selected row by checking mod icon text changed
		--TODO: isn't working on service menu top screen
		local currow=ModsMenu.GetCurrentRow(pn)

		if currow>0 then lh:aux(currow) end

		--ummm:  Runs before row change.
		--if not (page.Contents and ModsMenu.ShowTabList(page)) then SetRowText(currow,pn) end

--		rows[currow].title:diffuse(ModsMenu.ItemColor(2,true)) --keep title colour


-- [[Disabled for now; text doesn't display right.
		--refresh submenu name preview list (non tab bar)
		local page=ModsMenu.GetTop()
		if page.Contents and not ModsMenu.ShowTabList(page) and page.Contents[currow] and type(page.Contents[currow])=='table' and page.Contents[currow].Contents then
			--for i=1,table.getn(rows) do for pn=1,2 do rows[i].icons[pn].text:settext("") end end --clear text
			for line,rowdata in next,page.Contents[currow].Contents,nil do
				local row=rows[line]
				if not row then return end
				local r=ModsMenu.ModLineRaw(rowdata)

				--title
				row.icons[1].text:settext(r.Name or "?")

				--value
				row.icons[2].text:settext(ModsMenu.GetInfoText(pn,r) or "")
--[[
				if r.handler then
					ForeachPlayer(function(pn)
						local val
						if r.handler.getchoices then
							local t=r.handler.get(r,pn)
							if IsTable(t) then for i=1,table.getn(t) do if t[i] then val=i end end else val=t end
						else
							val=r.handler.get(r,pn)
						end
						row.icons[2].text:settext(r.handler.format and r.handler.format(r,pn,val) or r.handler.getchoices()[type(val)=='boolean' and (val and 2 or 1) or val] or "?")
					end)
				end
--]]
			end
		end
--]]

	end,
	RefreshModsText=function(lh)
		local pn=lh:getaux()

		--Update mod icons text. Only for rows that get changed (icon text gets overwritten with "")

		local rowsdata=ModsMenu.GetTop().Contents

--[[
		for line=1,table.getn(rows) do
			local rowdata=rowsdata[line]
			local modicon=rows[line].icons[pn]
			modicon.text:diffusealpha(0.5)
			if modicon.text:GetText()=="" then
				modicon.text:settext(rowdata.StatusFunction and rowdata.StatusFunction(pn) or " ")
			end
		end
--]]
	end,

	ReloadRow=function(r)
		Env()._reloadline=r
		--Frame:queuemessage("ReloadRow"..r)
--		Broadcast("ReloadRow"..r)
--	r.LoadSelections(r,l,pn-1)--todo
		Env()._reloadline=nil
	end,

	GetInfoText=function(pn,r)
		if IsTable(r) and r.handler then
			local val
			local text
			if r.handler.getchoices then
				local t=r.handler.get(r,pn)
				local choices=r.handler.getchoices(pn) --the only rowtype that uses pn is UnsharedList.
				if IsTable(t) then
					local tvals={}
					for i=1,table.getn(t) do if t[i] then tvals[table.getn(tvals)+1]=choices[i] end end
					if table.getn(tvals)==0 then tvals[1]="None" end
					text=join(",",tvals)
					--for i=1,table.getn(t) do if t[i] then val=i end end
				elseif IsBoolean(t) then
					val=t and 2 or 1
					text=choices[val]
				elseif IsNumber(t) then
					val=t
					text=choices[val]
				end
			elseif r.handler.format then
				val=r.handler.get(r,pn)
				text=r.handler.format(r,pn,val)
			else
				text=r.handler.gettext(pn)
			end
			return text
		end
	end,
	UpdateInfoLine=function(r,pn,lines)
		local base=r.Line
		if not (IsTable(ModsMenu.GetTop()) and ModsMenu.GetTop().Contents) then return end --failsafe
		local setline=function(l)
			local line=base+l
			local r=ModsMenu.ModLineRaw(ModsMenu.GetTop().Contents[line])
			local text=ModsMenu.GetInfoText(pn,r) or "?"
			SetRowText(line,pn,text)
			if CachedText and CachedText[line] then CachedText[line][pn]=text end --stupid thing crashing on menu exit
		end
		if IsTable(lines) then --range
			if lines.start and lines["end"] then
				for line=lines.start,lines["end"] do setline(line) end
			else
				for i,line in next,lines,nil do setline(line) end
			end
		elseif IsNumber(lines) then
			setline(lines)
		elseif lines==true then
			--all
			for line=1,table.getn(ModsMenu.GetTop().Contents) do setline(line) end
		end
	end,

	--misc
	FirstUpdate=function(s)
		--for some reason, the text on slider rows gets overwritten on shared-cursor menus after screen load. put the text back again
		if CachedText then
			--DumpTable(CachedText,"CachedText")
			for i=table.getn(CachedText),1,-1 do for pn,text in next,CachedText[i],nil do SetRowText(i,pn,text,i==1) end end
		end

		ForeachPlayer(function(pn) linehighlights[pn]:aux(1) end) --try and fix cursor width issue

		for i,row in next,rows,nil do
			row.title:maxwidth(224/row.title:GetZoomX())
			if row.items then for i,t in next,row.items.text,nil do t:maxwidth(256/t:GetZoomX()) end end
		end --TODO un-hardcode it.
	end,
	Off=function()
		local seconds=GetScreen():GetChild("Timer") and GetScreen():GetChild("Timer"):GetChild("Text1"):GetText()
		if seconds==0 then Frame:aux(0) end --force Back
		CachedText=nil
	end
}

-- actor functions

SetHighlightWidth=function(hl,w)
	local parts=hl.children --sprite order: middle, left, right
	local framewidth=parts[2]:GetWidth()
	local width=math.ceil(w/2)*2 --even widths only
	parts[1]:zoomtowidth(width)
	parts[2]:x(-width/2-framewidth/2)
	parts[3]:x(width/2+framewidth/2)
end

SetRowText=function(line,pn,newtext,setcursorwidth)
	if not (rows and rows[line]) then return end
	local row=rows[line]
	local text=row.items.text[row.shared and 1 or pn]
	if newtext then text:settext(newtext) end
	if setcursorwidth then
		local currow=linehighlights[pn]:getaux()
		if currow>0 then 
			local row=rows[currow]
			local text=row.items.text[row.shared and 1 or pn]
			local width=text:GetWidth()*text:GetZoomX()*text:GetBaseZoomX()
			SetHighlightWidth(cursors[pn],width)
			SetHighlightWidth(row.items.highlight[pn][1], width)
		end

	end
end

--[[

SetRowText=function(line,pn,newtext,setcursorwidth)
	if not (rows and rows[line]) then return end
	local row=rows[line]
	local text=row.items.text[row.shared and 1 or pn]
	if newtext then text:settext(newtext) end
	if setcursorwidth then
		local width=text:GetWidth()*text:GetZoomX()*text:GetBaseZoomX()
		SetHighlightWidth(cursors[pn],width)
		SetHighlightWidth(row.items.highlight[pn][1], width)
	end
end
--]]