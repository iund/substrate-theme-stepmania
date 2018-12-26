local cursongtext,nextsongstext
local curmetertext,nextmeterstext={},{}

--[[
	GameState GetLoadingCourseSongIndex and GetCourseSongIndex() both give -1 for some stupid reason,
	nudging this function should increment the value below and hopefully it'll work properly:
]] local curstage=1

local setcurrent=function()
	local i=math.max(0,GAMESTATE:GetLoadingCourseSongIndex())

	cursongtext:settext(GetCurCourse():GetCourseEntry(i):GetSong():GetDisplayFullTitle())
	
	ForeachEnabledPlayer(function(pn)
		curmetertext[pn]:settext(GetCurTrail(pn):GetTrailEntry(i):GetSteps():GetMeter())
	end)
end
	
local setnext=function()
	local ii=math.max(0,GAMESTATE:GetLoadingCourseSongIndex())+1
	local out={}

	local songtext={}
	local course=GetCurCourse()
	local numentries=course:GetNumCourseEntries()-1
	for i=ii,numentries do
		local entry=course:GetCourseEntry(i)
		assert(entry,i)
		songtext[i-ii+1]=not entry:IsSecret() and entry:GetSong():GetDisplayFullTitle() or "??????????"
	end
	nextsongstext:settext("\n"..join("\n",songtext))

	ForeachEnabledPlayer(function(pn)
		local metertext={}
		local trail=GetCurTrail(pn):GetTrailEntries()
		
		for i=ii+1,#trail do
			metertext[i-ii]=tostring(trail[i]:GetSteps():GetMeter())
		end
		nextmeterstext[pn]:settext("\n"..join("\n",metertext))
	end)
end

local out=Def.ActorFrame {
	OnCommand=function(s)
		setcurrent()
		setnext()
	end,
	BeforeLoadingNextCourseSongMessageCommand=function(s)
		setcurrent()
		setnext()
	end,
	Def.BitmapText {
		Font="_common semibold white",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X) s:y(SCREEN_CENTER_Y+56) s:vertalign("top")
			cursongtext=s
		end,
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
	},
	Def.BitmapText {
		Font="_common white",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X) s:y(SCREEN_CENTER_Y+56) s:vertalign("top") s:diffusecolor(.5,.5,.5,1)
			nextsongstext=s
		end,
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
	}
}

ForeachEnabledPlayer(function(pn)
	out[#out+1]=Def.BitmapText {
		Font="_common semibold white",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+(PlayerIndex[pn]*2-3)*176) s:y(SCREEN_CENTER_Y+56) s:vertalign("top")
			curmetertext[pn]=s
		end,
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
	}
	out[#out+1]=Def.BitmapText {
		Font="_common white",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+(PlayerIndex[pn]*2-3)*176) s:y(SCREEN_CENTER_Y+56) s:vertalign("top") s:diffusecolor(.5,.5,.5,1)
			nextmeterstext[pn]=s
		end,
		StartCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,1),
		FinishCommand=cmd(sleep,0.3;linear,0.3;diffusealpha,0),
		BeforeLoadingNextCourseSongMessageCommand=cmd(finishtweening;diffusealpha,0),
	}
end)

return out