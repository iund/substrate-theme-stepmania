Capture.RateMod=function() --Read SongOptions text to determine what ratemod is being used.
		local rate=1
		local find=string.find
		local gsub=string.gsub
		local songoptions=split("\n",string.lower(GetScreen():GetChild('SongOptions'):GetText()))
		
		for i=1,table.getn(songoptions) do
			local mod=songoptions[i]
			if find(mod,'xmusic') then --openitg uses "xMusic" (capital M)
				rate=tonumber(tostring(gsub(mod,'xmusic','')))
			end
		end
		return rate
	end
Capture.BPMObject=function(s) BPMText=s end
Capture.BPM=function(text,sep)
		local delim=sep or THEME:GetMetric('BPMDisplay','Separator')
		local bpm=type(text)=='string' and text or text:GetText()
		Env().SongBPM={}
		local delimpos=string.find(bpm,delim,2,true)
		if delimpos then --2 values
			local left=tonumber(string.sub(bpm,1,delimpos-1))
			local right=tonumber(string.sub(bpm,delimpos+1))
			Env().SongBPM={left,right}
			--local bpmlist=split(delim,bpm)
--			if bpmlist[1]~="" then --bug: "-128-0" becomes {"", "128", "0"}
			--Env().SongBPM=bpmlist
		elseif tonumber(bpm) then --1 value
			Env().SongBPM[1]=tonumber(bpm)
		else --unknown
			Env().SongBPM={}
		end
	end
Capture.BPMSpeedLine=function(s)
		--Gets the bpm from the "Speed" line of a ScreenPlayerOptions screen, where ShowBpmInSpeedTitle=true
		--eg: "Speed (71-142)" -> {71,142}
		if not rows then return end
		local text=rows[1].title:GetText()
		local bp=string.find(text,"(",1,true)
		local str=bp and string.sub(text,bp+1,-2) or ''

		Capture.BPM(str,'-')
		Capture.ModsMenu.Off() --clean up
	end	
--[[
Capture.SongLength=function()
		if not GetScreen():GetChild('TotalTime') then return end --backing out of a song seems to crash 
		local time=GetScreen():GetChild('TotalTime'):GetText()
		SetEnv('SongSeconds', time~='' and time~="xx:xx.xx" and MSSMsMsToSeconds(time) or -1)
		if not IsCourseMode() then SetEnv('SongStages', tonumber(GetScreen():GetChild('NumSongs'):GetText())) end
	end
--]]
Capture.SongTime=function(s)
	local t=s:GetText()
	local time=t~='' and t~="xx:xx.xx" and MSSMsMsToSeconds(t) or -1
	SetEnv("SongSeconds",time)

	--scale displayed time with ratemod
	s:settext(time>=0 and SecondsToMSS(time/tonumber(Env().SongMods.Rate)) or "")
end
Capture.NumSongs=function(s)
	SetEnv("SongStages",tonumber(s:GetText()))
end