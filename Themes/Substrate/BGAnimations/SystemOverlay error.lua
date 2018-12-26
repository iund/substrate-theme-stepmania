--I don't like the default error pane.

local showseconds=6
local textsize=0.75

local tweeninseconds=0.3
local fadeoutseconds=1.5

local msg,msgframe

local log={}

local function snap() msg:finishtweening() msgframe:finishtweening() end

local function show()
	snap()
	
	local height=msg:GetZoomedHeight()+8
	msg:y(clamp(height,8,SCREEN_HEIGHT))
	msg:decelerate(tweeninseconds) msg:diffusealpha(1) 

	msgframe:cropbottom(1) msgframe:diffusealpha(0)
	msgframe:zoomto(msg:GetZoomedWidth()+8,math.min(SCREEN_HEIGHT,height)+8)
	msgframe:decelerate(tweeninseconds) msgframe:cropbottom(0) msgframe:diffusealpha(1)
end

local function wait() msgframe:sleep(showseconds) msg:sleep(showseconds) end

local function hide()
	msgframe:accelerate(fadeoutseconds) msgframe:diffusealpha(0) 
	msg:accelerate(fadeoutseconds) msg:diffusealpha(0)
end

local logtext=function(ago)
	local text={}
	local time=clock:GetSecsIntoEffect()
	
	local prunedlog={}

	for i=1,#log do
		if not ago or time-log[i].time<ago then --5 seconds ago
			table.insert(prunedlog,log[i])
			table.insert(text,log[i].text)
		end
	end

	log=prunedlog

	return join("\n",text)
end

return Def.ActorFrame {
	InitCommand=function(s)
		s:x(SCREEN_CENTER_X) s:y(SCREEN_TOP)
		s:visible(GetPref("ShowThemeErrors"))
		s:effectperiod(math.huge) --clock
		clock=s
	end,

	Def.Quad {
		InitCommand=function(s) msgframe=s
			s:diffuse(0.2,0,0,0) s:vertalign("top") s:cropbottom(1)
			s:clearzbuffer(1) s:zbias(1) s:zbuffer(1)
		end,
	},

	Def.BitmapText {
		Font="_common semibold white",
		InitCommand=function(s) msg=s
			s:addy(8) s:shadowlength(0) s:vertalign("bottom") s:wrapwidthpixels(SCREEN_WIDTH/textsize)
			s:zoom(textsize)
			s:ztestmode("writeonfail")
		end,
	},

	ScriptErrorMessageCommand=function(s,p)
		local time=s:GetSecsIntoEffect()

		table.insert(log,{time=time, text=p.message})

		msg:settext(logtext(5))

		show() wait() hide()
	end,

	ShowThemeErrorsChangedMessageCommand=function(s)
		local doshow=GetPref("ShowThemeErrors")
		s:visible(doshow)

		if doshow then
			msg:settext(logtext(5))
			show() wait() hide()
		end
	end,

	--debug menu:
	ToggleScriptErrorMessageCommand=function(s) --debug menu: Show Recent Errors
		--Toggle whether to keep the last error on screen

		msg:settext(logtext())

		show() snap()
	end,
	ClearScriptErrorMessageCommand=function(s) --debug menu: Clear Errors
		msg:settext(" "..logtext(0)) --clear log
		hide() snap()
	end,
}

