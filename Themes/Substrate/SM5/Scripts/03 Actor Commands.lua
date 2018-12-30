--actors
function ScreenMessage(str,static) SCREENMAN:SystemMessage(str) if static then Broadcast("SystemMessageNoAnimate") end end
function Broadcast(str) MESSAGEMAN:Broadcast(str) end

function GetScreen() return SCREENMAN:GetTopScreen() end

function Sprite:stretchtoscreen() self:stretchto(SCREEN_LEFT,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM) end

function ActorFrame:FitToAspect()
	self:zoomx((SCREEN_WIDTH/SCREEN_HEIGHT)/(16/9))
	self:addx((426-SCREEN_CENTER_X)/(SCREEN_WIDTH/SCREEN_HEIGHT))
end
--run this via SetUpdateCommand. this is used in a few places so putting here to avoid pasting
function Actor:UpdateDiffuseCos(bias) self:diffusealpha(math.abs(math.cos(self:GetSecsIntoEffect()*math.pi))*bias+bias) end
function Actor:UpdateDiffuseSin(bias) self:diffusealpha(math.abs(math.sin(self:GetSecsIntoEffect()*math.pi))*bias+bias) end

function ActorFrame:ApplyAuxToChildren(val) local aux=val or self:getaux() self:RunCommandsOnChildren(function(child) child:aux(aux) end) end

-- UI
function ApplyUIColor(s,pn) s:diffusecolor(PlayerColors[GAMESTATE:Env().PlayerState[pn].UIColor]) end

--predicates
function IsActorFrame(s) return not not (s and (debug and debug.getmetatable(s).heirarchy.ActorFrame or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s).GetNumChildren)) end
function IsBitmapText(s) return not not (s and (debug and debug.getmetatable(s).heirarchy.BitmapText or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s).GetText)) end
function IsSprite(s) return not not (s and (debug and debug.getmetatable(s).heirarchy.Sprite or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s).customtexturerect)) end
function IsActor(s,class,method) return not not (s and (debug and debug.getmetatable(s).heirarchy[class] or getmetatable(s) and getmetatable(s)~="(hidden)" and getmetatable(s)[method])) end --generic ver

function Broadcast(msgstr) MESSAGEMAN:Broadcast(msgstr) end
function ScreenMessage(msgstr,isstatic) SCREENMAN[isstatic and "SystemMessageNoAnimate" or "SystemMessage"](SCREENMAN,msgstr) end

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

--layout

function IsPlayerCentered(pn) return
	GAMESTATE:GetCurrentStyle():GetStyleType()=="StyleType_OnePlayerTwoSides"
	or GetPref('Center1Player') and GAMESTATE:GetNumPlayersEnabled()==1
end
function PlayerX(pn)
	local ret=math.round(
		IsPlayerCentered(pn) and SCREEN_CENTER_X
		or pn==1 and SCREEN_CENTER_X-(SCREEN_WIDTH/4)
		or pn==2 and SCREEN_CENTER_X+(SCREEN_WIDTH/4))
	return ret
end

