return Def.ActorFrame {

	Def.Sprite {
		Texture="MusicWheelItem _expanded",

		SetMessageCommand=function(s,p)
			--TODO: 
		end
		
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



}