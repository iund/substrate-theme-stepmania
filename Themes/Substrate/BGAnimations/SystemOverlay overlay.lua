-- System overlay.

--[[
	MESSAGEMAN->Broadcast( "HideSystemMessage" );
	MESSAGEMAN->Broadcast( "RefreshCreditText" );
--]]

-- NOTE Do some crazy dance since Def.whatever doesn't put the actor self in the returned table.

local function creditmsg(pn)
	return Def.BitmapText {
		Font="_common semibold white",
		InitCommand=function(s) s:zoom(.75) s:horizalign(pn==PLAYER_1 and "left" or "right") s:vertalign("bottom") s:shadowlength(0)
			s:y(SCREEN_BOTTOM-4) s:x(pn==PLAYER_1 and SCREEN_LEFT+32 or SCREEN_RIGHT-32)
		end,
		CoinInsertedMessageCommand=cmd(playcommand,"SetText"),
		RefreshCreditTextMessageCommand=cmd(playcommand,"SetText"),
		SetTextCommand=function(s,p) s:settext(ScreenSystemLayerHelpers.GetCreditsMessage(pn)) end
	}
end

local msg, msgframe

local cmds={
	MsgInit=function(s) s:x(SCREEN_CENTER_X) s:y(SCREEN_TOP) end,

	MsgFrameShow=function() 
		msgframe:zoomto(msg:GetWidth()*msg:GetZoomX()+16,msg:GetHeight()*msg:GetZoomY()+16)
		msgframe:finishtweening() msgframe:decelerate(0.3) msgframe:cropbottom(0)
	end,
	MsgFrameHide=function() msgframe:sleep(2.5) msgframe:accelerate(0.3) msgframe:cropbottom(1) end,

	MsgShow=function() msg:finishtweening() msg:decelerate(0.3) msg:diffusealpha(1) end,
	MsgHide=function() msg:sleep(2.5) msg:accelerate(0.3) msg:diffusealpha(0) end
}

return Def.ActorFrame {
	Def.Quad {
		InitCommand=function(s) msgframe=s cmds.MsgInit(s) s:diffuse(0,0,0,0.8) s:vertalign("top") s:cropbottom(1) s:clearzbuffer(1) s:zbias(1) s:zbuffer(1) end,
		HideSystemMessageMessageCommand=cmd(finishtweening;playcommand,"Hide"),
	},
	Def.BitmapText {
		Font="_common semibold white",
		InitCommand=function(s) msg=s cmds.MsgInit(s) s:addy(8) s:shadowlength(0) s:vertalign("top") s:maxwidth(SCREEN_WIDTH) s:maxheight(SCREEN_HEIGHT) s:ztestmode("writeonfail") end,
		HideSystemMessageMessageCommand=cmd(finishtweening;playcommand,"Hide"),
	},

	creditmsg(PLAYER_1),
	creditmsg(PLAYER_2),

	SystemMessageMessageCommand=function(s,p)
		msg:settext(p.Message)
		cmds.MsgFrameShow() cmds.MsgShow()
		if p.NoAnimate then msgframe:finishtweening() msg:finishtweening() end
		cmds.MsgFrameHide() cmds.MsgHide()
	end,
}
