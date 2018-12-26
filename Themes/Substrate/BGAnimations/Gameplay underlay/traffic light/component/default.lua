return Def.ActorFrame {
	OnCommand=cmd(RunCommandsOnChildren,function(c) c:aux(self:getaux()) end),

	Def.Sprite {
		Texture="light",
		OnCommand=cmd(diffusecolor,self:getaux()==0 and 0.25 or 0.5,self:getaux()<3 and 0.5 or 0.25,0.25,1),
	},
	Def.Sprite {
		Texture="flash",
		OnCommand=cmd(diffuse,self:getaux()==0 and 0.5 or 1,self:getaux()<3 and 1 or 0.5,0.5,0),
		FlashCommand=cmd(finishtweening;diffusealpha,1;decelerate,0.5;diffusealpha,0),
	},
	Def.BitmapText {
		Font="_common semibold white",

		OnCommand=function(s) s:settext(s:getaux()>0 and tostring(s:getaux()) or "Step!") s:zoom(s:getaux()>0 and 1.25 or 1) s:shadowlength(0) s:diffusealpha(0) end,
		FlashCommand=function(s) s:finishtweening() s:playcommand(s:getaux()>0 and "TweenUp" or "TweenHit") end,

		TweenUpCommand=cmd(diffusealpha,1;y,0;linear,0.4;y,-64;queuecommand,"TweenTextOff"),
		TweenHitCommand=cmd(finishtweening;diffusealpha,1;zoom,1.2;decelerate,0.25;zoom,1;sleep,0.75;decelerate,0.5;diffusealpha,0),
		TweenTextOffCommand=cmd(diffusealpha,0),

		NoteCrossedMessageCommand=function(s,p) if s:getaux()==0 and p.ButtonName then s:settext(THEME:GetString("GameButton",p.ButtonName)) end end,
		NoteCrossedJumpMessageCommand=function(s) if s:getaux()==0 then s:settext("Jump") end end
	}
}