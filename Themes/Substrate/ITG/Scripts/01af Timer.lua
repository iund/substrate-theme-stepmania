-- For timed sets.

MenuTimer={
	Seconds=function(sec)
		--[[

			Don't set this to -1 on SelectMusic, it causes a crash:

			With [MenuTimer] TimerSeconds=-1, SWME doesn't load the MenuTimer object,
			But SSM will still try to MenuTimer->Stall() (which assumes the MenuTimer object exists).

		--]]
		local out=GetPref('EventMode') and -1 or GetSysConfig().Timer and Timer and Timer.GetRemainingSeconds()>0 and Timer.GetRemainingSeconds() or sec
		return out
	end,

	Format={
		Integer=function(sec)
			return GetSysConfig().Timer and Timer and Timer.GetRemainingSeconds()>0 and FastSecondsToMSS(sec) or tostring(math.ceil(sec))
		end,
		Fraction=function(sec)
			if sec==0 then Broadcast("MenuTimer") end
			return math.mod(sec,1)
		end,
	}
}

-- Timer gets set, timer counts down, timer fires AlarmMessage when it hits zero.
TimerInit = function(s)
	local TimerInternal={
		self=s,
		StartTime=Clock(),
		EndTime=Clock(), --this will get overridden
		EndExtraTime=Clock(),
		Active=false,
		WarningThreshold=false,
		PassedWarningThreshold=false --Used so the effect tween won't get applied on every frame
	}

	local Format=SecondsToMSS
	
	local function ClearWarning()
		TimerInternal.WarningThreshold=false
		TimerInternal.PassedWarningThreshold=false
		TimerInternal.self:stopeffect()
	end
	
	local function GetElapsedSeconds() return Clock()-TimerInternal.StartTime end
	local function GetRemainingSeconds() return TimerInternal.EndTime-Clock() end

	return {
		Clear = function() TimerInternal.StartTime=Clock() TimerInternal.EndTime=Clock() TimerInternal.Active=false ClearWarning() end,
		Cancel = function() TimerInternal.Active=false end,
		SetSeconds = function(seconds) TimerInternal.EndTime=Clock()+seconds TimerInternal.Active=true ClearWarning() end,
		SetWarningThreshold = function(seconds) ClearWarning() TimerInternal.WarningThreshold=seconds end,

		GetElapsedSeconds=GetElapsedSeconds,
		GetRemainingSeconds=GetRemainingSeconds,
	
		GetState = function()
			return TimerInternal.Active
		end,

		Update = function()
			local seconds=GetRemainingSeconds()
			local s=TimerInternal.self
			if not TimerInternal.PassedWarningThreshold then
				--flash text upon threshold time
				if TimerInternal.WarningThreshold and seconds<TimerInternal.WarningThreshold then
					TimerInternal.PassedWarningThreshold=true
--					s:diffuseblink() s:effectperiod(0.5) s:effectcolor1(1,1,1,1) s:effectcolor2(1,0,0,1) --white/red
				end
			end

			if seconds<=0 and TimerInternal.Active and not GetPref("EventMode") then
				--timer ran out
				SetEnv("Alarm",1)
				Broadcast("Alarm")
				TimerInternal.Active=false
			end

			--update text
			local lastseconds=s:getaux()
			local sec=math.floor(seconds)
			s:aux(sec)
			if lastseconds~=sec then
				s:settext(
					--format counter display
					TimerInternal.Active
					and (
						GetPref("EventMode") and Format(GetElapsedSeconds())
						or seconds>0 and Format(math.max(seconds,0))
					)
					or "" --if it's blank, then luaeffect stops working
				)
			end
		end
	}
end

