-- List types

RowType.ModsList=function(name,mods,mult,addOff,shared)
	local handler = {
		getchoices = function()
			local out={} local i=0 if addOff then out[1]='Off' i=i+1 end for j=1,table.getn(mods) do out[j+i]=mods[j] end --add Off
			return RowType.ListNames(out,Languages[CurLanguage()].Mods.Names[name])		
		end,
		get = function(r,pn)
			local flag=false
			local out={} for m=1,table.getn(mods) do
				local i=addOff and m+1 or m
				if not shared then out[i]=UsingModifier(pn,mods[m]) else out[i]=Env().SongMods[mods[m]] end
				if out[i] then flag=true end
			end
			if not flag and not mult then out[1]=true end
			return out
		end,
		set = function(r,pn,i,flag)
			local mod=mods[addOff and i-1 or i]
			if mod==nil then return end
			ApplyModifier(not shared and pn or nil,mod,flag)
			if not shared then
				local flag2=false
				local list=ModsSaveList
				for j=1,table.getn(list) do if mod==list[j] then flag2=true end end
				if flag2 then GetProfile(pn).Mods[mod]=flag end
			else
				Env().SongMods[mod]=flag
			end
		end
	}


	return RowType.ListBase(name,handler,mult,false,shared)
end

RowType.EnvList=function(name,list,mode,addOff)
	--return single selection from table
	--mode: true = use names, false = use id
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) end,
		get = function(r,pn)
			local out={}
			for i=1,table.getn(list) do out[i] = (mode and list[i] or i)==(GetProfile(pn)[name] or nil) end
			return out
		end,
		set = function(r,pn,i,flag) GetProfile(pn)[name] = flag and (mode and list[i] or i) or false end
	}
	return RowType.ListBase(name,handler,false,addOff)
end
