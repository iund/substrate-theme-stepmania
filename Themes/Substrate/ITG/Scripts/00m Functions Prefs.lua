---Prefs
function GetPref(str) return PREFSMAN:GetPreference(str) end
function SetPref(str,val) return PREFSMAN:SetPreference(str,val) end
function GetPrefOrDefault(p,v) return GetPref('SoundVolume')~=-1 and GetPref(p) or v or DefaultPrefs[p] or 0 end
function GetPrefOrArchDefault(p,v) return GetPref('SoundVolume')~=-1 and GetPref(p) or v or ArchDefaults[p][GetArchName()] or 0 end

function ResetToDefaults()
	--resettofactorydefaults clears prefs, but doesn't reapply [Preferences] overrides. Manually fill in our defaults then reboot to make sure we're at a known state.
	GameCommand("resettofactorydefaults")
	for p,v in next,DefaultPrefs,nil do SetPref(p,v) end
	table.clear(GetSysProfile())
	for p,v in next,DefaultSettings,nil do GetSysProfile()[p]=v end
	SetPref('SoundVolume',-1)
	PROFILEMAN:SaveMachineProfile()
	SetScreen("ScreenReboot")
end

