---Screen / actors
function ScreenMessage(str,static) Trace("ScreenMessage: "..str) SCREENMAN:SystemMessage(str) if static then Broadcast("SystemMessageNoAnimate") end end
function Broadcast(str) MESSAGEMAN:Broadcast(str) end
--function Broadcast(str) Trace("Broadcast: "..str) MESSAGEMAN:Broadcast(str) Trace("Broadcast finished: "..str) end

function GetScreen() return SCREENMAN:GetTopScreen() or TopScreen or nil end
function SetScreen(scr) SCREENMAN:GetTopScreen():finishtweening() SCREENMAN:SetNewScreen(scr) end

function PrepareScreen(name) assert(GameState.ApplyGameCommand,"no PrepareScreen for you") GAMESTATE:ApplyGameCommand("preparescreen,"..name) end
function DeletePreparedScreens() assert(GameState.ApplyGameCommand,"no PrepareScreen for you") GAMESTATE:ApplyGameCommand("deletepreparedscreens") end

function GameCommand(command,pn) GAMESTATE:ApplyGameCommand(command,pn and pNum[pn]) end

--function IsType(actor,type_) return string.find(tostring(actor),type_) end
function IsType(actor,actortype) return split(" ",tostring(actor))[1]==actortype end

function Actor.GetType(s) return split(" ",tostring(s))[1] end
function Actor.xy(s,x,y) s:x(x) s:y(y) end
function Actor.XYOn(s,sec,name,pn) if pn then Actor.xy(s,Metrics[sec][name.."X"][pn],Metrics[sec][name.."Y"]) else Actor.xy(s,unpack(Metrics[sec][name.."XY"])) end Tweens[sec][name].On(s) end
function Actor.Off(s,sec,name) Tweens[sec][name].Off(s) end

function Sprite.stretchtoscreen(s) s:stretchto(SCREEN_LEFT-1,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM) end --used in screen fade transitions (Stretch=1 rounds to nearest int and doesn't catch the leftmost column of pixels)

function IsActorFrame(s) return not not (s and (debug and debug.getmetatable(s).heirarchy.ActorFrame or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s).GetNumChildren)) end
function IsBitmapText(s) return not not (s and (debug and debug.getmetatable(s).heirarchy.BitmapText or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s).GetText)) end
function IsSprite(s) return not not (s and (debug and debug.getmetatable(s).heirarchy.Sprite or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s).customtexturerect)) end
function IsActor(s,class,method) return not not (s and (debug and debug.getmetatable(s).heirarchy[class] or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s)[method])) end --generic ver
--function IsActor(s,class) return s and debug and debug.getmetatable(s).heirarchy[class] or getmetatable(s) and getmetatable(s)~="(hidden)" and _G[class]==getmetatable(s) end --generic ver
--function IsActor(s,class) return s and debug and debug.getmetatable(s).heirarchy[class] or class==string.left(tostring(s),string.find(" ") and true end --generic ver
if not color then color=function(str) return split(",",str) end end --I don't know where this is defined in SM5. It returns a table, eg color("1,1,1,1") yields {1,1,1,1}

ActorScroller.propagatecommand=function(s,c) s:propagate(1) s:playcommand(c) s:propagate(0) end

---Updates
function RunLuaEffectList() if Env().TempLuaEffectList then for s,func in next,Env().TempLuaEffectList,nil do func(s) end end end

--oITG has SetUpdateFunction, might be faster? BUT it doesn't have GetCommand 
function LuaEffect(s,cmdstr)
	if IsActorFrame(s) and ActorFrame.SetUpdateFunction and Actor.GetCommand then --SM5 (actorframe)
		s:SetUpdateFunction(cmdstr and s:GetCommand(cmdstr) or nil)
	elseif not Actor.luaeffect then --SM5 (non-actorframe)
		--register it
		local func=s:GetCommand(cmdstr)
		Env().TempLuaEffectList[s]=func
	else --3.95
		if cmdstr then s:luaeffect(cmdstr) else s:stopeffect() end
	end
end

--[[
function LuaEffect(s,cmdstr)
	if Actor.luaeffect then --3.95
		if cmdstr then s:luaeffect(cmdstr) else s:stopeffect() end
	else --sm5
		if IsActorFrame(s) then
			s:SetUpdateFunction(cmdstr and s:GetCommand(cmdstr) or nil) --only works on actorframes
		else
			--register it
			local func=s:GetCommand(cmdstr)
			Env().TempLuaEffectList[s]=func
		end
	end
end
--]]

--[[
function runcmd(s,str)
	-- run for example "	abc,123;def,456;ghi" with metatables (note that lua args won't work)
	local cmds=split(";",str)
	for _,cmd in next,cmds,nil do
		if string.find(cmd,",") then
			local args=split(",",cmd)
			getmetatable(s).arg[1](s,arg[2]) --s:arg[1](arg[2])
		else
			getmetatable(s).cmd(s)
		end
	end
end
--]]

function Actor.runcmds(s,str) -- "abc,123;def,456;ghi" -> "function(s) s:abc(123) s:def(456) s:ghi() end" -> run it
	local run={}
	local cmds=split(";",str)
	for i,c in next,cmds,nil do
		local arg=split(",",c)
		run[i]=string.format("s:%s(%s) ",arg[1],arg[2] or "")
	end
	loadstring(sprintf("return function(s) %s end",table.concat(run)))(s)
end


---Textures
Mask={
	--UNTESTED
	Set=function(s,f) s:zbias(1) s:blend(f and "noeffect" or "normal") s:zwrite(Bool[f]) end,
	Apply=function(s,f) s:ztestmode(f and "writeonfail" or "off") end,
	Clear=function(s,f) assert(not IsActorFrame(s),"no clearzbuffer 4 u") s:clearzbuffer(Bool[f]) end,
}

---Actors
function AlignTexts(align,...) --Format multiple BitmapText actors into a single line of text
	local totw=0 local w={} local cumuw={}
	for i=1,arg.n do local
		text=arg[i]
		w[i]=text:GetWidth()*text:GetZoomX()
		totw=totw+w[i]
		cumuw[i]=totw
	end
	local offset=(({left=0,right=totw})[align] or totw/2)
	for i=1,arg.n do arg[i]:x((cumuw[i]-w[i])-offset+w[i]/2) end
	return totw
end

--[[
function AlignTextsMaxWidth(align,xoffset,maxwidth,...) --Format multiple BitmapText actors into a single line of text
	local totalwidth=0
	local widths={}
	local cumuwidths={}
	for i=1,arg.n do
		local text=arg[i]
		widths[i]=text:GetWidth()*text:GetZoomX()
		totalwidth=totalwidth+widths[i]
		cumuwidths[i]=totalwidth
	end

	local offset=({left=0,right=totalwidth})[align] or totalwidth/2

	--scale text to max width:
	local zoom=arg[1]:GetZoomY()
	local scale=math.min(1,maxwidth/totalwidth)*zoom
	
	--getting this alignment formula right is a right ballache. TODO.

	--offset is used to shift left
	for i=1,arg.n do
		arg[i]:x((cumuwidths[i]-widths[i]/(2/scale)-offset)*scale+xoffset)
		arg[i]:zoomx(scale)
	end
end
--]]