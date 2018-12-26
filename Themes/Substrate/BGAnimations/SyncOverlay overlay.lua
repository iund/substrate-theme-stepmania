
-- Only visible in gameplay.

local guidetextstr=function(str) return THEME:GetString("ScreenSyncOverlay",str) end

--NOTE: It's hardcoded in itg so replicate it here for now. TODO make a more intuitive/visual sync guide

local quad,guidetext
return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(s)
			s:diffuse(0,0,0,0)
			s:horizalign("left")
			s:y(SCREEN_TOP+100)
			quad=s
		end,
	},

	--Guide text box
	Def.BitmapText{
		Font="Common normal",
		InitCommand=function(s)
			--NOTE: ITG hardcodes these tweens; replicate it here to minimise differences.
			s:horizalign("left")
			s:zoom(.6)
			local edge=SCREEN_CENTER_X --local edge=SCREEN_RIGHT-s:GetZoomedWidth()-10
			s:x(edge-10)
			s:y(SCREEN_TOP+100)
			s:diffusealpha(0)

			quad:x(edge-20)
			quad:zoomto(s:GetZoomedWidth()+20,s:GetZoomedHeight()+20)
			guidetext=s
		end,
		Text=string.format(
			"%s\n    F4\n%s\n    F9/F10\n%s\n    F11/F12\n%s\n    Shift + F11/F12\n%s",
			guidetextstr("revert_sync_changes"),
			guidetextstr("change_bpm"),
			guidetextstr("change_song_offset"),
			guidetextstr("change_machine_offset"),
			guidetextstr("hold_alt")
		)
	},

	--status text (eg, autoplay, autosync machine, offset changed)
	Def.BitmapText{
		Font="Common normal",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X)
			s:y(SCREEN_CENTER_Y+160)
		end,
		SetStatusMessageCommand=function(s,p)
			s:settext(p.text)
		end,
	},

	--Autosync info
	Def.BitmapText{
		Font="_common bordered white",
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+(SCREEN_WIDTH/8))
			s:y(SCREEN_CENTER_Y+64)
		end,
		SetAdjustmentsMessageCommand=function(s,p)
			s:visible(p.visible)
			s:settext(p.text)
		end,
	},

	ShowCommand=function(s)
		local tween=function(s,a)
			s:stoptweening()
			s:linear(0.3) s:diffusealpha(a)
			s:sleep(4) s:linear(0.3) s:diffusealpha(0)
		end
		tween(quad,0.5)
		tween(guidetext,1)
	end,

	HideCommand=function(s)
		local tween=cmd(stoptweening;linear,0.3;diffusealpha,0)
		tween(quad)
		tween(guidetext)
	end
}
