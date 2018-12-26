-- Mod-specific rows

RowType.SpeedModType=function(name,updaterow)
	local list=GetSysConfig().UseXMods and {"M","C","X"} or {"M","C"}
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names.SpeedModType) end,
		get = function(r,pn)
			local type_=GetProfile(pn).SpeedMod.Type
			local out={}
			for i=1,table.getn(list) do out[i] = list[i]==type_ end
			return out,type_
		end,
		set = function(r,pn,i,flag)
			if pn~=0 then
				if flag then
					ApplySpeedModBPM(pn,GetProfile(pn).SpeedMod.Type,list[i])
					GetProfile(pn).SpeedMod.Type = list[i]
				end
				if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
				ApplyStageSpeedMod(pn)
			end
		end
	}
	local r=RowType.ListBase(name,handler,false,addOff)
	r.handler=handler
	return r
end

RowType.SpeedMod=function(name,step,range,simple,updaterow)
	local handler = {
		get = function(r,pn)
			local sm=GetProfile(pn).SpeedMod
			return sm.Type=="X" and sm.XMod*100 or sm.BPM
		end,
		set = function(r,pn,val)
			local sm=GetProfile(pn).SpeedMod
			if sm.Type=="X" then sm.XMod=val/100 else sm.BPM=val end
			ApplyStageSpeedMod(pn)
			if pn~=0 and updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
		end,
		format = function(r,pn,val)
			local sm=GetProfile(pn).SpeedMod
			local bpm=GetBPM()
			return sm.Type=="X" and 
				(bpm and not simple and 
				sprintf("%1.2fx (%s bpm)",val/100, GetBPMString(val/100,bpm))
				or sprintf("%1.2fx",val/100))
			or
				sm.Type=="M" and bpm and
				sprintf("%d bpm (%1.2fx)",val, val/(bpm[2] or bpm[1]))
			or
				val.." bpm"
		end,
	}
	return RowType.Slider(name,handler,step,range)
end

RowType.InfoSpeedXModBPM=function(name)
	local visible=GetSysConfig().UseXMods
	return RowType.Info(visible and name or " ",{gettext=function(pn) 
		local env=GetProfile(pn).SpeedMod
		return env.Type=="X" and "("..GetBPMString(env.XMod,GetBPM() or "")..")" or ""
	end})
end

--previous:

RowType.SpeedModBPM=function(name,step,range)
	local handler = {
		get = function(r,pn) return GetProfile(pn).SpeedMod.BPM end,
		set = function(r,pn,val) GetProfile(pn).SpeedMod.BPM=val ApplyStageSpeedMod(pn) end,
		format = function(r,pn,val) return val..' bpm' end
	}
	return RowType.Slider(name,handler,step,range)
end

RowType.Noteskin=function(name,noteskinlist)
	local handler = {
		getchoices = function() return RowType.ListNames(noteskinlist,Languages[CurLanguage()].Mods.Names[name]) end,
		get = function(r,pn)
			local flag=false
			local out={}
			for i=1,table.getn(noteskinlist) do
				out[i]=UsingNoteskin(pn,noteskinlist[i])
				flag=flag or out[i]
			end
			if not flag then out[1]=true end --make sure something is selected
			return out
		end,
		set = function(r,pn,i,flag) if flag then ApplyNoteskin(pn,noteskinlist[i]) end end
	}
	return RowType.ListBase(name,handler,false,false,false)
end

RowType.JudgeFontList=function(name,list,_,addOff)
	local handler = {
		getchoices = function() return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names.JudgeFonts) end,
		get = function(r,pn) local out={} for i=1,table.getn(list) do out[i] = list[i]==(GetProfile(pn)[name] or nil) end return out end,
		set = function(r,pn,i,flag)
			GetProfile(pn)[name] = list[i]
--[[
	--special case: preview judge font?
			local icon = rows[r.Line].icons[pn]
			icon.self:x(rows[r.Line].items.text[pn]:GetX())
			icon.self:hidden(0)
			icon.sprite:Load(THEME:GetPath(EC_GRAPHICS,'','_judge fonts/'..list[i]))
			icon.sprite:animate(0)
			icon.sprite:zoom(
				rows[r.Line].items.text[pn]:GetHeight()/
				icon.sprite:GetHeight()
			)
			icon.text:hidden(1)
]]
		end
	}
	return RowType.ListBase(name,handler,false,false,false)
end

RowType.RateMod=function(name,step,range,updaterow) -- returns mod (bpm), for example 1.0x (134) / 1.1x (80-160)
	--Rate mods in 3.95 literally only works between 0.1 and 2.0 in 0.1 steps.
	local handler = {
		get = function(r,_) return tonumber(Env().SongMods.Rate) or 1 end,
		set = function(r,pn,rate) ApplyMod(string.format('%1.1fxmusic',rate)) Env().SongMods.Rate=rate
			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
		end,
		format = function(r,_,rate) return string.format('%1.1fx',rate) end
	}
	return RowType.Slider(name,handler,step or {slow=0.1, fast=0.1, snap=1},range or { min=GAMESTATE:IsEventMode() and 0.2 or 1, max=2 },true)
end

RowType.InfoBPM=function(name,shared) return RowType.Info(name,{gettext=function(_) return GetBPMString(Env().SongMods.Rate,GetBPM() or "").." bpm" end},shared) end
RowType.InfoLength=function(name,shared) return RowType.Info(name,{gettext=function(_) return SecondsToMSS((GetEnv('SongSeconds') or Song.MusicLengthSeconds and CurSong():MusicLengthSeconds() or 0)/(Env().SongMods.Rate or 1)) end},shared) end
--RowType.InfoLength=function(name) return RowType.Info(name,{gettext=function(_) return GetEnv("SongSeconds") and SecondsToMSS(GetEnv("SongSeconds")*Env().SongMods.Rate) or "" end},true) end

RowType.BatteryLives=function(name,step,range)
	local handler = {
		get = function(r,_) return tonumber(Env().SongMods.Lives) or 4 end,
		set = function(r,_,lives) ApplyMod(string.format('%d lives',lives)) Env().SongMods.Lives=lives end,
		format = function(r,_,lives) return string.format('%d',lives) end
	}
	return RowType.Slider(name,handler,step,range,true)
end

RowType.JudgeWindow=function(name,readonly)
	local handler = {
		getchoices = function() 
			local names={}
			for name,_ in next,JudgeList,nil do table.insert(names,name) end

			return names
			--return RowType.ListNames(list,Languages[CurLanguage()].Mods.Names[name]) end,
		end,		
		get = function(r,pn)
			local out={}
			for i=1,table.getn(r.Choices) do out[i]=i==(Env().SongMods[name] or 1) end
			return out
		end,
		set = function(r,pn,i,flag)
			local apply="Default"
			if flag then
				if i==1 then --default
					Env().SongMods[name]=false
				end
				for j,v in next,JudgeList[r.Choices[i]],nil do SetPref(j,v) end
			end
		end
	}
	local r=RowType.ListBase(name,handler,false,false,true)
	if readonly then r.EnabledForPlayers={} end
	return r
end

RowType.AutoMod=function(mod,shared)
	--reads ModTypes[] and returns the correct row type.
	local t=ModTypes[mod]
	if t=='number' then return RowType.ModNumber(mod,1,'%d%%', {slow=1, fast=2, snap=0}, { min=0, max=100 },shared)
	elseif t=='boolean' then return RowType.ModsBool(mod,shared)
	else assert(false,"RowType.AutoMod(): "..mod.."\'s type is "..(t~=nil and "missing from ModTypes[]" or "invalid ("..t..")").."!")
	--Official ITG binaries (eg, R23) have asserts disabled. Give it a dummy row instead to stop ScreenOptions from crashing.
	return RowType.Dummy()
	end
end
