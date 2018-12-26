--------------------------------
-- Generate choice lists for ScreenSelect and friends
--------------------------------

--SM5 will read CHOICE_NAMES twice

function MenuNames(t,field,value,trunc)
	--Why does SM5 not give you GetScreen()? Remove aux dependency.

	if true then -- GetScreen():getaux()<1 then
		local function LookupTable(t,field,value) for i,v in pairs(t) do if i=='Entries' then return LookupTable(v,field,value) elseif v[field]==value then return v end end end
		MenuList = {}
		local tab = field and value and LookupTable(t,field,value) or t
		if tab.Filter then
			string.gsub(tab.Filter, "([^,]+)", function(s) table.insert(MenuList,tab.Entries and tab.Entries[tonumber(s)] or tab[tonumber(s)]) end)
		else
			MenuList = tab.Entries or tab
		end
		if SM_VERSION==3.95 then GetScreen():aux(1) else MenuI=1 end --GetScreen():getaux()+1)
		local numentries=trunc and math.min(table.getn(MenuList),trunc) or table.getn(MenuList)
		local ret=string.rep('s,',numentries)
		return ret
	else
		local ret=MenuEntries()
		return ret
	end
end

function MenuEntries(lang) --Still needs to be separate, because of MusicWheel ModeMenuChoices.
	local pos = SM_VERSION==3.95 and GetScreen():getaux() or MenuI
	local c = MenuList[pos]
	local out

	if type(c)=='table' and (c.Name or c.Style) then
		if c.Type then
			out=c.Type..','..c.Name
		elseif c.Style then
		--Player entry choices
			out="style,"..c.Style
				..";applydefaultoptions"
				..(c.Mode and ';playmode,'..c.Mode or '')
				..";difficulty,"..(c.Difficulty or GetSysConfig().DefaultDifficulty or "beginner")
--				..(not (GetSysConfig().StartOnFullMode or IsAnyPlayerUsingProfile()) and ";songgroup,In The Groove;sort,Preferred" or "") --Simple mode
				..";screen,"..(c.Screen or Branch.PlayerEntrySelection())
		elseif c.Folder or c.Sort or c.Mode or c.Action then
		--Sort menu
			out='name,'..(lang and lang[c.Name] or c.Name)
				..(c.Action and (IsString(c.Action) and ";"..c.Action or ';lua,'..string.gsub(string.format("loadstring(%q)",string.dump(c.Action)),";","\\059")) or "")
				..(c.Sort and ';sort,'..c.Sort or '')
				..(c.Mode and ';playmode,'..c.Mode or '')
				..(c.Screen and ';screen,'..c.Screen or '')
		else
		--Service menu? idk can't rember
			out='name,'..(lang and lang[c.Name] or c.Name)
			if c.Command then
				out=out..';'..c.Command..';screen,'..(c.Screen or 'ServiceMenu')
			elseif c.Screen then
				out=out..';screen,'..c.Screen
			elseif c.Submenu then
				out=out..';setenv,Screen,'..c.Name..';screen,'..(c.Submenu and 'LuaSubmenu' or 'OptionsSubmenu')
			end
		end
	elseif type(c)=='function' then
		out='lua,'..string.format("loadstring(%q)",string.gsub(string.dump(c),";","\\059"))
	else
		local t = typ or type(c)=='table' and c.Type or string.find(c,')') and 'lua' or 'conf'
		out = string.format('%s,%s',t,c)
	end

	--wrap back to 1 when finished. On ScreenSelectMaster, the menu entries are loaded all at once, then the Icon parts (etc) are loaded all at once.
	
	if SM_VERSION==3.95 then GetScreen():aux(math.mod(pos,table.getn(MenuList))+1) else MenuI=MenuI+1 end
	
	if pos>table.getn(MenuList) then MenuList=nil MenuI=nil end
	return out
end

--Iterates over the sort table in Metrics.lua
function SortMenuNames(tab,addtab)
	if SM_VERSION==3.95 then GetScreen():aux(1) else MenuI=1 end --GetScreen():aux(1)
	MenuList=table.duplicate(tab or {})
--	if GetSysConfig().ModesInSort~=false then --TODO: Why is 
		local c = table.getn(MenuList)
		for i=1,table.getn(addtab) do MenuList[i+c]=addtab[i] end
--	end
	assert(MenuList~={},'Blank sort list passed to function MusicWheel.lua:SortMenuNames()')
	return LineNumbers(1,table.getn(MenuList))
end
