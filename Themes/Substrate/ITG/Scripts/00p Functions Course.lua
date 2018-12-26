---Course
function CurCourse() return GAMESTATE:GetCurrentCourse() end
function CurTrail(pn) return GAMESTATE:GetCurrentTrail(pNum[pn]) end

function Course.GetBannerPath(course) --takes the course dir and swaps .crs for .png or whatever file exists for the banner.
	assert(Course.GetCourseDir) --required
	local crs=course:GetCourseDir()
	local path=string.sub(crs,1,string.len(crs)-3)
	local out for _,ext in next,{"png","jpg","bmp","gif"},nil do out=GetPathG(path..ext) if out then break end end
	return out or GetPathG("_blank",true)
end

function CanPlayMarathons() return table.getn(SONGMAN:GetAllCourses(false))>0 and (GAMESTATE:IsEventMode() or GetPref('SongsPerPlay')>2 and StageIndex()==0) end
