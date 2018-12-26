local meterxoffset=158
local clearlampxoffset=176

local meter=function(pn) --Difficulty meter
	return Def.BitmapText {
		Font="_common white",
		OnCommand=cmd(zoom,1;shadowlength,0;x,meterxoffset*(PlayerIndex[pn]*2-3)),
		SetMessageCommand=function(s,p)
			if p.Song and GAMESTATE:IsPlayerEnabled(pn) then
				local steps=GetNearestDifficulty(p.Song,pn)
				s:settext(steps and steps:GetMeter() or "")
				s:diffusecolor(DifficultyColors[steps and steps:GetDifficulty() or "Difficulty_Invalid"])
			else
				s:settext("")
			end
		end,
		["PreferredDifficultyP"..PlayerIndex[pn].."ChangedMessageCommand"]=function(s)
			s:finishtweening()
			local z=s:GetZoomY()
			local h=s:GetHeight()
			s:y(-h/2) s:zoomy(0)
			s:decelerate(0.25)
			s:y(0) s:zoomy(z)
		end
	}
end

local clearlamp=function(pn) --Clear lamp.
	return Def.Quad {
		InitCommand=cmd(visible,false), --TODO until I figure this out.
		OnCommand=function(s)
			--Setup
			s:zoomto(32,24)
			s:x(clearlampxoffset*(PlayerIndex[pn]*2-3))
			s:diffusealpha(.5)
			
			if pn==PLAYER_1 then
				s:faderight(1)
				s:horizalign("left")
			else
				s:fadeleft(1)
				s:horizalign("right")
			end
		end,
		aSetMessageCommand=function(s,p)
			if p.Song and GAMESTATE:IsPlayerEnabled(pn) then
				local song=p.Song
				local steps=GetNearestDifficulty(song,pn)

				s:visible(true)
			else
				s:visible(false)
			end
		end
	}
end

return Def.ActorFrame {
	Def.Sprite {
		Texture="MusicWheelItem _song",
		InitCommand=cmd(
			diffusecolor,unpack(UIColors["MusicWheelItemSong"]);
			diffusealpha,CommonPaneDiffuseAlpha)
	},

	clearlamp(PLAYER_1),
	clearlamp(PLAYER_2),

	meter(PLAYER_1),
	meter(PLAYER_2)

	--[[
		#		Message msg( "Set" );
#		msg.SetParam( "Song", pWID->m_pSong );
#		msg.SetParam( "Course", pWID->m_pCourse );
#		msg.SetParam( "Index", iIndex );
#		msg.SetParam( "HasFocus", bHasFocus );
#		msg.SetParam( "Text", pWID->m_sText );
#		msg.SetParam( "DrawIndex", iDrawIndex );
#		msg.SetParam( "Type", MusicWheelItemTypeToString(type) );
#		msg.SetParam( "Color", pWID->m_color );
#		msg.SetParam( "Label", pWID->m_sLabel );

#Grade refresh:
#		Message msg( "SetGrade" );
#		msg.SetParam( "PlayerNumber", p );
#		if( pHSL )
#		{
#			msg.SetParam( "Grade", pHSL->HighGrade );
#			msg.SetParam( "NumTimesPlayed", pHSL->GetNumTimesPlayed() );
#		}

#Steps/trail/preferred difficulty change:
#		Message msg( "Set" );
#		msg.SetParam( "Song", pWID->m_pSong );
#		msg.SetParam( "Course", pWID->m_pCourse );
#		msg.SetParam( "Text", pWID->m_sText );
#		msg.SetParam( "Type", MusicWheelItemTypeToString(type) );
#		msg.SetParam( "Color", pWID->m_color );
#		msg.SetParam( "Label", pWID->m_sLabel );


--]]
}
