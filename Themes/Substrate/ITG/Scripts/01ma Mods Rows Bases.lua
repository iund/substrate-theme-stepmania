----------------------
-- Mods Rows Functions
----------------------

--[[
		--test
		booltest={false,true}
		numtest={1.5,3}
		timetest={15,105}
	

	Template Example:
	
	RowListExample=function(name,list,mult,addOff)
		--TESTING
		local testnames = {'foo','bar','baz','quux','sam','bob'}
		local testvalues = {
			[1] = {false,true,true,false,false,true},
			[2] = {true,false,true,true,false,false}
		}

		local handler = {
			getchoices = function() return testnames end,
			get = function(r,pn) return testvalues[pn] end,
			set = function(r,pn,i,flag) testvalues[pn][i]=flag end
		}
		return RowListBase('List',handler,true,false)
	end

	will generate:
		p1: foo BAR BAZ quux sam BOB
		p2: FOO bar BAZ QUUX sam bob
		(caps = selected)
	
	How to use in metrics:
	
				{RowModsList, 'Test Mods', {'mirror','reverse','expand'}, false,true },
				{RowBool, 'Test Bool', booltest},
				{RowNumber, 'Test Num', numtest, {slow=0.5, fast=1.5}, { min=-4, max=3.5 }},
				{RowTime, 'Test Time', timetest, {slow=5, fast=15}, { min=0, max=300 }},

]]
RowType={}

RowType.ListNames=function(list,lookup) --Substitute language strings for each item in the list
	local out={}
	for i=1,table.getn(list) do out[i]=lookup and lookup[list[i]] or list[i] end
	--if lookup then DumpTable(lookup) end
	return out
end

-- Bases

RowType.Base=function(name,layout,sel,shared) return {
	Name=Languages[CurLanguage()].Mods.Titles[name] or name,
	OneChoiceForAllPlayers=shared,
	ExportOnChange=true,
	LayoutType=layout, --ShowAllInRow, ShowOneInRow
	SelectType=sel, --SelectOne, SelectMultiple, SelectNone
	Line=ModsMenu.CurLine(),
} end

--[[
extra:

	EnabledForPlayers={list of players}, eg {PLAYER_2}

--]]

RowType.ListBase=function(name,handler,mult,addOff,shared)
	local r=RowType.Base(name,'ShowOneInRow',mult and 'SelectMultiple' or 'SelectOne',shared)

	local getchoices=handler.getchoices()
	local list={}
	i=0 if not mult and addOff then list[1]='Off' i=i+1 end
	for j=1,table.getn(getchoices) do list[j+i]=getchoices[j] end
	r.Choices=list

	r.LoadSelections=function(r,l,p) local pn=pText[p]
		local none=not mult and addOff
		local var=handler.get(r,pn)
		for i=1,table.getn(l) do local ii=not mult and addOff and i+1 or i l[ii]=var[i] if l[ii] then none=false end end
		if none and not mult then l[1]=true end
	end
	r.SaveSelections=function(r,l,p) local pn=pText[p]
		local flags={false,true}
		for f=1,table.getn(flags) do --run the true ones last, otherwise it breaks stuff like noteskin ModsLists.
			for i=addOff and 2 or 1,table.getn(l) do
				local ii=not mult and addOff and i-1 or i
				if l[i]==flags[f] then handler.set(r,pn,ii,l[i]) end
				if addOff and l[1] then handler.set(r,pn,false,l[i]) end
			end
		end
	end
	r.handler=handler
	r.type=mult and ROW_TYPE_MULTI_LIST or ROW_TYPE_LIST
	return r
end

RowType.UnsharedListBase=function(name,handler,shared) --Different choices for each player.
	local r=RowType.Base(name,'ShowOneInRow','SelectOne',shared)
	r.Choices={'','',''}

	r.LastChoice={1,1} --cached values
	r.LastClock={Clock(),Clock()}
	r.ChoiceNames={} --names list
	r.NumChoices={0,0}
	r.CurListChoice={1,1}
	ForeachPlayer(function(pn)
		r.ChoiceNames[pn]=handler.getchoices(pn)
		r.NumChoices[pn]=table.getn(r.ChoiceNames[pn])
	end)

	r.LoadSelections=function(r,l,p) local pn=pText[p]
		l[1]=true
		r.LastChoice[pn]=1
		r.CurListChoice[pn]=handler.get(r,pn)
		CachedText[r.Line][pn]=r.ChoiceNames[pn][r.CurListChoice[pn]]
		SetRowText(r.Line,pn,CachedText[r.Line][pn])
	end
	r.SaveSelections=function(r,l,p) local pn=pText[p]
		local holding=Clock()-r.LastClock[pn]<=0.1
		for i=1,table.getn(l) do local s=l[i]
			if s and i~=r.LastChoice[pn] then --changed
				local c=r.LastChoice[pn]
				local delta=(math.mod(2+c-i,3)-0.5)*2 -- -1 (left), +1 (right)
				if delta~=0 and not (holding and (delta>0 and r.CurListChoice[pn]>=r.NumChoices[pn] or delta<0 and r.CurListChoice[pn]<=1)) then --move, stop at list end if holding down
					r.CurListChoice[pn]=math.mod(r.NumChoices[pn]+r.CurListChoice[pn]+(delta-1),r.NumChoices[pn])+1
					CachedText[r.Line][pn]=r.ChoiceNames[pn][r.CurListChoice[pn]]
					handler.set(r,pn,r.CurListChoice[pn])
				end
				r.LastChoice[pn]=i
			end
		end
		SetRowText(r.Line,pn,CachedText[r.Line][pn],true)
		r.LastClock[pn]=Clock()
	end
	r.handler=handler
	-- Grey out the row if there's only 1 choice
	--r.EnabledForPlayers={} ForeachPlayer(function(pn) if r.NumChoices[pn]>1 then table.insert(r.EnabledForPlayers,pNum[pn]) end end)
	r.type=ROW_TYPE_SLIDER
	return r
end

RowType.BoolBase=function(name,handler,shared)
	local r=RowType.Base(name,'ShowOneInRow','SelectOne',shared)
	r.Choices=RowType.ListNames(handler.getchoices() or {"Off","On"},Languages[CurLanguage()].Mods.Bool)
	r.LoadSelections=function(r,l,p) l[handler.get(r,p+1) and 2 or 1]=true end
	r.SaveSelections=function(r,l,p) handler.set(r,p+1,l[2]) end
	r.handler=handler
	r.type=ROW_TYPE_BOOL
	return r
end

RowType.Slider=function(name,handler,step,range,shared)
--This one splits shared values to work on 2-pane screens.
--TODO: Detect autorepeat events on NewModsMenu.
	local r=RowType.Base(name,'ShowOneInRow','SelectOne',GetEnv("ServiceMenu") and true) --shared)
	r.Choices={'','',''}

	r.LastChoice={1,1} --cached values
	r.LastClock={Clock(),Clock()}
	r.LastDir={0,0} --cache the last direction the player went, to stop rapid LRLRLRLR inputs going into fast step.

	r.LoadSelections=function(r,l,p) local pn=pText[p]
		l[1]=not (l[2] or l[3]) --l[1]=true 
		r.LastChoice={1,1}
		CachedText[r.Line][pn]=handler.format(r,pn,handler.get(r,pn),suffix)
		SetRowText(r.Line,pn,CachedText[r.Line][pn])
	end
	r.SaveSelections=function(r,l,p) local pn=pText[p]
		if GetEnv("ServiceMenu") and shared and pn==2 then return end

		local ForeachPlayerIfShared=function(func) if shared then ForeachPlayer(func) else func(pn) end end
		local lc=r.LastChoice[pn]
		for i=1,table.getn(l) do local s=l[i]
			if s and i~=r.LastChoice[pn] then
				local val=handler.get(r,pn)
				local vel=Clock()-r.LastClock[pn]>0.1 and step.slow or step.snap and val==step.snap and 0 or step.fast --the time delta is meant to be 1/12s (0.083) but it fluctuates wildly depending on vsync
				local c=r.LastChoice[pn]
				local dir=(math.mod(2+c-i,3)-0.5)*2 -- -1 goes left, +1 goes right
				if r.LastDir[pn]~=clamp(dir,-1,1) then vel=step.slow end --force step.slow in case of rapid LRLR inputs
				if dir~=0 and vel~=0 then --move
					local newval=clamp(quantize(val+vel*dir,vel),range.min,range.max)
					handler.set(r,pn,newval)
					ForeachPlayerIfShared(function(pn) CachedText[r.Line][pn]=handler.format(r,pn,newval) end)
				end
				r.LastDir[pn]=clamp(dir,-1,1)
				r.LastChoice[pn]=i
			end
		end
		ForeachPlayerIfShared(function(pn) SetRowText(r.Line,pn,CachedText[r.Line][pn],lc~=r.LastChoice[pn] or rows and table.getn(rows[r.Line].items.text)==2 and ModsMenu.GetCurrentRow(1)==ModsMenu.GetCurrentRow(2)) end)
		r.LastClock[pn]=Clock()
	end
	r.handler=handler
	r.type=ROW_TYPE_SLIDER
	return r
end
--[[
RowType.Slider=function(name,handler,step,range,shared)
--TODO: Detect autorepeat events on NewModsMenu.
	local r=RowType.Base(name,'ShowOneInRow','SelectOne',shared)
	r.Choices={'','',''}

	r.LastChoice={1,1} --cached values
	r.LastClock={Clock(),Clock()}
	r.LastDir={0,0} --cache the last direction the player went, to stop rapid LRLRLRLR inputs going into fast step.

	r.LoadSelections=function(r,l,p) local pn=pText[p]
		l[1]=not (l[2] or l[3]) --l[1]=true 
		r.LastChoice={1,1}
		CachedText[r.Line][pn]=handler.format(r,pn,handler.get(r,pn),suffix)
		SetRowText(r.Line,pn,CachedText[r.Line][pn])
	end
	r.SaveSelections=function(r,l,p) local pn=pText[p]
		if shared and GetNumPlayersEnabled()==2 and pn==2 then return end
		local lc=r.LastChoice[pn]
		for i=1,table.getn(l) do local s=l[i]
			if s and i~=r.LastChoice[pn] then
				local val=handler.get(r,pn)
				local vel=Clock()-r.LastClock[pn]<=(r.State and 0.25 or 0.1) and (step.snap and val==step.snap and 0 or step.fast) or step.slow --the time delta is meant to be 1/12s (0.083) but it fluctuates wildly
				local c=r.LastChoice[pn]
				local dir=(math.mod(2+c-i,3)-0.5)*2 -- -1 goes left, +1 goes right
				if r.LastDir[pn]~=clamp(dir,-1,1) then vel=step.slow end
				if dir~=0 then --move
					local newval=clamp((math.floor((vel/2+val)/vel)+dir)*vel,range.min,range.max)
					handler.set(r,pn,newval)
					CachedText[r.Line][pn]=handler.format(r,pn,newval)
				end
				r.LastDir[pn]=clamp(dir,-1,1)
				r.LastChoice[pn]=i
			end
		end
		SetRowText(r.Line,pn,CachedText[r.Line][pn],lc~=r.LastChoice[pn] or rows and table.getn(rows[r.Line].items.text)==2 and ModsMenu.GetCurrentRow(1)==ModsMenu.GetCurrentRow(2))
		r.LastClock[pn]=Clock()
	end
	r.handler=handler
	r.type=ROW_TYPE_SLIDER
	return r
end
--]]
--[[
RowType.Slider=function(name,handler,step,range,shared)
	local r=RowType.Base(name,'ShowOneInRow','SelectOne',shared)
	r.Choices={'','',''}

	r.Values={0,0} --cached
	r.LastChoice={1,1} --cached values
	r.LastClock={Clock(),Clock()}
	r.LastDir={0,0} --cache the last direction the player went, to stop rapid LRLRLRLR inputs going into fast step.

	r.LoadSelections=function(r,l,p) local pn=pText[p]
		r.Values[pn]=handler.get(r,pn)
		l[1]=not (l[2] or l[3]) --l[1]=true 
		r.LastChoice={1,1}
		CachedText[r.Line][pn]=handler.format(r.Values[pn],suffix)
		SetRowText(r.Line,pn,CachedText[r.Line][pn])
	end
	r.SaveSelections=function(r,l,p) local pn=pText[p]
		for i=1,table.getn(l) do local s=l[i]
			if s and i~=r.LastChoice[pn] then
				local vel=Clock()-r.LastClock[pn]<=0.1 and (step.snap and r.Values[pn]==step.snap and 0 or step.fast) or step.slow --the time delta is meant to be 1/12s (0.083) but it fluctuates wildly
				local c=r.LastChoice[pn]
				local dir=(math.mod(2+c-i,3)-0.5)*2 -- -1 goes left, +1 goes right
				if r.LastDir[pn]~=clamp(dir,-1,1) then vel=step.slow end
				if dir~=0 then --move
					local newval=clamp((math.floor((vel/2+r.Values[pn])/vel)+dir)*vel,range.min,range.max)
					handler.set(r,pn,newval)
					r.Values[pn]=newval
					CachedText[r.Line][pn]=handler.format(newval,suffix)
				end
				r.LastDir[pn]=clamp(dir,-1,1)
				r.LastChoice[pn]=i
			end
		end
		SetRowText(r.Line,pn,CachedText[r.Line][pn])
		r.LastClock[pn]=Clock()
	end
	r.handler=handler
	return r
end

--]]
RowType.Dummy=function(name,shared) --Dummy row that arbitrary row handlers can manipulate.
	local r=RowType.Base(name or ' ','ShowOneInRow','SelectNone',shared)
	r.Choices={'',''}
	r.EnabledForPlayers=SM_VERSION==5 and function() return {} end or {}
	r.LoadSelections=function(r,l,p) l[p+1]=true end
	r.SaveSelections=function(r,l,p) end
	r.type=ROW_TYPE_DUMMY
	return r
end

RowType.Info=function(name,handler,shared) --Show text on both tab preview and in menu.
	local r=RowType.Dummy(name,shared)
	r.Choices={}
	ForeachPlayer(function(pn) r.Choices[pn]=handler.gettext(pn) end)
	if handler.updatemessages then for i,msg in next,handler.updatemessages(),nil do r.ReloadRowMessages[i+1]=msg end end
	r.handler=handler
	return r
end
