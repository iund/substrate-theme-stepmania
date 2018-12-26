--------------------------------
-- Service menu presets
--------------------------------

RowType.FreePlay=function() return RowType.MappedPrefList("CoinMode",IsArcade() and {{"Pay",1},{"Free",2}} or {{"Home",0},{"Pay",1},{"Free",2}}) end
RowType.JointPremium=function() return RowType.MappedPrefList("Premium",{{"Off",0},{"Double",1},{"Versus",2}}) end
RowType.BGAMode=function() return RowType.MappedPrefList("BackgroundMode",{{"Off",0},{"On",2}}) end
RowType.BGAVideos=function() return RowType.MappedPrefList("MovieDrivers",{{"On","FFMpeg,DShow,Null"},{"Disable","Null"}}) end
RowType.BannerCache=function() return RowType.MappedPrefList("BannerCache",{{"Off",0},{"Load On Boot",1},{"Load On Demand",2}}) end
RowType.SaveEVNT=function() return RowType.MappedLuaPrefList("SaveEVNTName",{{"Event",1},{"Never",2},{"Always",3}}) end
RowType.DefaultCourseSort=function() return RowType.MappedLuaPrefList("DefaultCourseSort",{{"Songs",0},{"Meter",1},{"Meter Sum",2},{"Rank",3}}) end
RowType.DancingCharacters=function() return RowType.MappedPrefList("ShowDancingCharacters",{{"Off",0},{"Random",1},{"Choose",2}}) end

-- New oITG 
RowType.CabinetType=function() return RowType.MappedPrefList("CabinetType",{{"SD","SD"},{"HD","HD"}}) end

RowType.COMPort=function(name)
	local arch=GetArchName()	
	local prefix=arch=="windows" and "COM" or "ttyS"
	local start=arch=="windows" and 1 or 0
	local default=start

	local handler={
		get=function(r,pn) return GetPref(name)~="" and tonumber(string.sub(GetPref(name),string.len(prefix))) or default end,
		set=function(r,pn,val) SetPref(name,prefix..tostring(val)) end,
		format=function(r,pn,num) return prefix..tostring(num) end
	}
	return RowType.Slider(name,handler,{slow=1, fast=1, snap=0},{min=start, max=100},true)
end

RowType.PlayMode=function()
	local list={"Stages","Timer","Event"}
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) end,
		get = function(r,pn)
			local sel=GetPref("Event") and 3 or GetSysConfig().Timer and 2 or 1
			local out={}
			for i=1,table.getn(list) do out[i]=i==sel end
			return out
		end,
		set = function(r,pn,i,flag)
			if flag then
				SetPref("Event",i==3)
				GetSysConfig().Timer=i==2
			end
			SetEnv("LuaPrefsChanged",1) 
		end
	}
	return RowType.ListBase("PlayMode",handler,false,false)
end

RowType.DriveLetter=function(name)
	--oITG expects "P:", 3.95 expects "P:\"

	local letters={}
	for i=1,26 do letters[i]=string.char(i+64)..(OPENITG and ":" or ":\\") end -- A: to Z:
	local handler = {
		getchoices = function() return letters end,
		get = function(r,pn)
			local out={}
			local flag=false
			for i=1,table.getn(letters) do out[i] = string.sub(GetPref(name),1,2)==letters[i] flag=flag or out[i] end
			if not flag then out[pn]=true end --force A and B as defaults if can't decide
			return out
		end,
		set = function(r,pn,i,flag) if flag then SetPref(name,letters[i]) end end
	}
	return RowType.ListBase(name,handler,false,false,true)
end

--[[
RowType.DefaultFolder=function(name,firstupdaterow)
	local handler = {
		getchoices = function(pn)
			local list={"Random"} --TODO lang strings for these choices
			for i,folder in next,AllFolders,nil do table.insert(list,folder) end
			return list
		end,
		get = function(r,pn) --choice index
			local folder=GetSysConfig().DefaultFolder
			local f=folder and table.findkey(AllFolders,folder)
			return f and f+1 or 1
		end,
		set = function(r,pn,i)
			GetSysConfig().DefaultFolder = i>1 and AllFolders[i] or false
			GetSysConfig().DefaultSong = i>1 and AllSongsBy.Folder[AllFolders[i] ][1] or false --change the folder for the next column
			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
			SetEnv("LuaPrefsChanged",1) 
		end
	}
	local r=RowType.ListBase(name,handler,false,false,true)
	return r
end

RowType.DefaultSong=function(name,firstupdaterow)
	local handler = {
		getchoices = function(pn)
			local list={"Random"} --TODO lang strings for these choices
			local folder=GetSysConfig().DefaultFolder

			if folder then
				for i,song in next,AllSongsBy.Folder[folder],nil do
					table.insert(list,GetSongName(song))
				end
			end
			
			return list
		end,
		get = function(r,pn) --choice index
			local folder=GetSysConfig().DefaultFolder
			if folder then
				local dir="/Songs/"..folder.."/"..GetSysConfig().DefaultSong.."/"
				local i=table.findkey(AllSongsBy.Folder[folder],AllSongsBy.Dir[dir])
				return i or 1
			else
				return 1
			end
		end,
		set = function(r,pn,i)
			local folder=GetSysConfig().DefaultFolder
			GetSysConfig().DefaultSong = folder and i>1 and AllSongsBy.Folder[folder][i] or false --change the folder for the next column
			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
			SetEnv("LuaPrefsChanged",1) 
		end
	}
--	local r=RowType.UnsharedListBase(name,handler)
	local r=RowType.ListBase(name,handler,false,false,true)
	return r
end
--]]
-- [[
RowType.DefaultFolder=function(name,firstupdaterow)
	local handler = {
		getchoices = function(pn)
			return AllFolders
		end,
		get = function(r,pn)
			local folder=GetSysConfig().DefaultFolder
			return folder and table.findkey(AllFolders,folder) or 1
		end,
		set = function(r,pn,i)
			local folder=GetSysConfig().DefaultFolder
			GetSysConfig().DefaultFolder=AllFolders[i]
			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
			SetEnv("LuaPrefsChanged",1)
		end
	}
	local r=RowType.UnsharedListBase(name,handler,true)
	return r
end

RowType.DefaultSong=function(name,firstupdaterow)
	local handler = {
		getchoices = function(pn)
			local list={}
			for i,song in next,AllSongsBy.Folder[GetSysConfig().DefaultFolder],nil do
				table.insert(list,GetSongName(song))
			end
			return list
		end,
		get = function(r,pn)
			local list=AllSongsBy.Folder[GetSysConfig().DefaultFolder]
			for i,s in next,list,nil do
				local name=GetSongName(song)
				if GetSysConfig().DefaultSong==s:GetSongDir() then return i end
			end			
			return 1
		end,
		set = function(r,pn,i)
			GetSysConfig().DefaultSong=AllSongsBy.Folder[GetSysConfig().DefaultFolder][i]:GetSongDir()
			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
			SetEnv("LuaPrefsChanged",1) 
		end
	}
	local r=RowType.UnsharedListBase(name,handler,true)
	return r
end
--]]

RowType.DefaultDifficulty=function(name,firstupdaterow)
	local handler = {
		getchoices = function(pn)
			local out={}
			for i,d in next,SelectableDifficulties,nil do
				table.insert(out,Languages[CurLanguage()].Difficulty[d])
			end
			return out
		end,
		get = function(r,pn)
			local diff=GetSysConfig().DefaultDifficulty
			return diff and table.findkey(SelectableDifficulties,diff) or 1
		end,
		set = function(r,pn,i)
			local diffname=SelectableDifficulties[i]
			GetSysConfig().DefaultDifficulty=diffname
			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
			SetEnv("LuaPrefsChanged",1)
		end
	}
	local r=RowType.UnsharedListBase(name,handler,true)
	return r
end