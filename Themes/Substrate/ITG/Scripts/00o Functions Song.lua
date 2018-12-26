---Song
function GetSongName(song) local ptr=song or GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong() return ptr and ptr:GetDisplayFullTitle() or "" end
function GetFolder(song) return split("/",song:GetSongDir())[3] end

function GetFolderBannerPath(folder) --takes the course dir and swaps .crs for .png or whatever file exists for the banner.
	local out for _,ext in next,{"png","jpg","bmp","gif"},nil do out=GetPathG(sprintf("/Songs/%s/*.%s",folder,ext)) if out then break end end
	return out or GetPathG("Common fallback banner",true)
end

function GetCourseFolder(course) return split("/",course:GetCourseDir())[3] end
function GetBPM() return SongDisplayBPMs[CurSong() and CurSong():GetSongDir()] or LoudReturn(Env().SongBPM,"GetBPM") end --local out= { GetEnv('bpm1'), GetEnv('bpm2') } DumpTable(out,"GetBPM") return out end
function GetBPMString(rate,bpmtab)
	local rate=rate or 1
	local bpm=bpmtab or GetBPM()
	DumpTable(bpm)
	return bpm[2] and string.format('%d%s%d',bpm[1]*rate,Metric('BPMDisplay','Separator',true), bpm[2]*rate)
		or bpm[1] and string.format('%d',bpm[1]*rate) or Metric('BPMDisplay','NoBPMText',true)
end

function DisplayScaledBPM(r)
	local bpm=GetBPM()
	return bpm[2]
		and string.format('%i-%i', v, r*bpm[1], r*bpm[2])
		or string.format('%i', v, r*bpm[1])
end

function GetNumSongs(song) return song:IsMarathon() and 3 or song:IsLong() and 2 or 1 end --SM5 only
