--------------------------------
-- Service menu options
--------------------------------

--Bools

RowType.PrefBool=function(name,list)
	local handler={
		getchoices=function() return list and RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) or RowType.ListNames({"Off","On"},Languages[CurLanguage()].Mods.Bool) end,
		get=function(r,pn) return not not GetPref(name)==true end,
		set=function(r,pn,flag) SetPref(name,flag) end
	}
	return RowType.BoolBase(name,handler,true)
end

RowType.LuaPrefBool=function(name,list)
	local handler={
		getchoices=function() return list and RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) or RowType.ListNames({"Off","On"},Languages[CurLanguage()].Mods.Bool) end,
		get=function(r,pn) return not not GetSysConfig()[name]==true end,
		set=function(r,pn,flag) GetSysConfig()[name]=flag SetEnv("LuaPrefsChanged",1) end
	}
	return RowType.BoolBase(name,handler,true)
end

--Numbers

RowType.PrefNumber=function(name,scale,fmtstr,step,range)
	local handler={
		get=function(r,pn) return GetPref(name) end,
		set=function(r,pn,val) SetPref(name,val) end,
		format=function(r,pn,num) return sprintf(fmtstr or "%d",num*(scale or 1)) end
	}
	return RowType.Slider(name,handler,step or {slow=1, fast=5, snap=0},range or { min=0, max=100 },true)
end

RowType.PrefPercent=function(name,step,range) return RowType.PrefNumber(name,100,"%d%%",step or {slow=0.01, fast=0.05, snap=0},range or { min=0, max=1 }) end
RowType.PrefMS=function(name,step,range) return RowType.PrefNumber(name,1000,"%d ms",step or {slow=0.001, fast=0.005, snap=0},range or { min=0, max=0.5 }) end

RowType.LuaPrefNumber=function(name,scale,fmtstr,step,range) --RowType.LuaPrefNumber=function(name,suffix,step,range,formatstr)
	local handler={
		get=function(r,pn) return GetSysConfig()[name] or step.snap end,
		set=function(r,pn,val) GetSysConfig()[name]=val SetEnv("LuaPrefsChanged",1) end,
		format=function(r,pn,num) return sprintf(fmtstr or "%d",num*(scale or 1)) end
		--format=function(num) return string.format(formatstr or '%1.2f %s', num, suffix) end
	}
	return RowType.Slider(name,handler,step or {slow=1, fast=5, snap=0},range or { min=0, max=100 },true)
	--return RowType.Slider(name,handler,step,range,true)
end

--Time

RowType.PrefTime=function(name,step,range)
	local handler={
		get=function(r,pn) return GetPref(name) end,
		set=function(r,pn,val) SetPref(name,val) end,
		format=function(r,pn,val) return SecondsToMSS(val) end
	}
	return RowType.Slider(name,handler,step or {slow=15, fast=60, snap=0},range or { min=0, max=3600 },true)
end

RowType.LuaPrefTime=function(name,step,range)
	local handler={
		get=function(r,pn) return GetSysConfig()[name] or step.snap end,
		set=function(r,pn,val) GetSysConfig()[name]=val SetEnv("LuaPrefsChanged",1) end,
		format=function(r,pn,val) return SecondsToMSS(val) end
	}
	return RowType.Slider(name,handler,step or {slow=15, fast=60, snap=0},range or { min=0, max=3600 },true)
end

--Lists

RowType.MappedPrefList=function(name,mappedlist)
	local mappings={names={},values={}}
	for i,listitem in next,mappedlist,nil do mappings.names[i]=listitem[1] mappings.values[i]=listitem[2] end


	local handler={mappings=mappings}

	handler={
		mappings=mappings,
		getchoices=function() return RowType.ListNames(handler.mappings.names,Languages[CurLanguage()].Mods.Names[name]) end,
		get=function(r,pn)
			local out={}
			local f=false
			local val=GetPref(name)
			for i=1,table.getn(handler.mappings.values) do out[i]=val==handler.mappings.values[i] f=f or out[i] end
			if not f then out[1]=true end --got to return something
			return out
		end,
		set=function(r,pn,i,flag) SetPref(name,handler.mappings.values[i]) end,
	}
	return RowType.ListBase(name,handler,false,false,true)
end

RowType.MappedLuaPrefList=function(name,mappedlist)
	local mappings={names={},values={}}
	for i,listitem in next,mappedlist,nil do mappings.names[i]=listitem[1] mappings.values[i]=listitem[2] end
	local handler={mappings=mappings}

	handler={
		mappings=mappings,
		getchoices=function() return RowType.ListNames(handler.mappings.names,Languages[CurLanguage()].Mods.Names[name]) end,
		get=function(r,pn)
			local out={}
			local f=false
			local val=GetSysConfig()[name]
			for i=1,table.getn(handler.mappings.values) do out[i]=val==handler.mappings.values[i] f=f or out[i] end
			if not f then out[1]=true end --got to return something
			return out
		end,
		set=function(r,pn,i,flag) GetSysConfig()[name]=handler.mappings.values[i] SetEnv("LuaPrefsChanged",1) end,
	}
	return RowType.ListBase(name,handler,false,false,true)
end
