--Load default prefs if SoundVolume == -1

function CheckPrefDefaults(sv)
	if GetPref("SoundVolume")==-1 then
		for p,v in next,DefaultPrefs,nil do SetPref(p,v) end
	end
	return sv
end