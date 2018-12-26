---Time
function Clock() return GlobalClock:GetSecsIntoEffect() end
function MusicClock() return GetScreen():GetSecsIntoEffect() end
--function MSSMsMsToSeconds(time) if time=="" then return 0 end local t=split(":",time) --[[Trace("MSSMsMs "..table.dump(t)) ]] return tonumber(t[1])*60+tonumber(t[2]) end --
function MSSMsMsToSeconds(time) if time=="" then return 0 else return (tonumber(string.sub(time,1,-7)) or 0)*60 + (tonumber(string.sub(time,-5)) or 0) end end
function CurTime() return sprintf("%04d/%02d/%02d %02d:%02d:%02d",Year(),MonthOfYear(),DayOfMonth(),Hour(),Minute(),Second()) end

function SecondsToMSS(seconds) --Depending on input value, this returns: hh:mm:ss, mm:ss, ss
	local comps={}
	local ins=table.insert
	local floor=math.floor
	local mod=math.mod

	if seconds>=86400 then ins(comps,tostring(floor(seconds/86400))) end --days
	if seconds>=3600 then ins(comps,sprintf("%02d",mod(floor(seconds/3600),24))) end --hours
	if seconds>=60 then ins(comps,sprintf("%02d",mod(floor(seconds/60),60))) end --minutes
	table.insert(comps,sprintf("%02d",mod(floor(seconds),60))) --seconds

	return join(":",comps)

--	return string.sub(SecondsToMSSMsMs(seconds),1,-4)
end --doesnt work properly on neg seconds (oh well)

function FastSecondsToMSS(seconds) return string.sub(SecondsToMSSMsMs(seconds),1,-4) end
