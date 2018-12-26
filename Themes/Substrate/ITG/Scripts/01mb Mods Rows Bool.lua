-- Bool types

RowType.ModsBool=function(mod,shared)
	local handler = {
		getchoices = function() return RowType.ListNames({"Off","On"},Languages[CurLanguage()].Mods.Bool) end,
		get = function(r,pn) return shared and Env().SongMods[mod] or UsingModifier(pn,mod) end,
		set = function(r,pn,flag)
			if not shared then 
				ApplyModifier(pn,mod,flag) --(flag and '' or 'no ')..mod)
				local flag2=false
				for i=1,table.getn(ModsSaveList) do if mod==ModsSaveList[i] then flag2=true end end
				if flag2 then GetProfile(pn).Mods[mod]=flag end
			else
				ApplyModifier(nil,mod,flag) --(flag and '' or 'no ')..mod)
				Env().SongMods[mod]=flag
			end
		end
	}
	return RowType.BoolBase(mod,handler,shared)
end

RowType.EnvBool=function(name,list,shared)
	local handler = {
		getchoices = function() return list and RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) or RowType.ListNames({"Off","On"},Languages[CurLanguage()].Mods.Bool) end,
		get = function(r,pn)
			return not not (shared and Env().SongMods[name]==true or GetProfile(pn)[name]==true)
		end,
		set = function(r,pn,flag)
			if shared then Env().SongMods[name]=flag else GetProfile(pn)[name]=flag end
		end
	}
	return RowType.BoolBase(name,handler,shared)
end

--[[
RowType.BranchBool=function(name,list,shared)
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) or RowType.ListNames({"Off","On"},Languages[CurLanguage()].Mods.Bool) end,
		get = function(r,pn) return false end,
		set = function(r,pn,flag) SetEnv(name,flag) end
	}
	return RowType.BoolBase(name,handler,shared)
end
--]]