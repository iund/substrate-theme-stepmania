-- NOTE: SM5 doesn't let you enter name when backing out early from the game.
-- basically if GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer() > 0

local spacing=40
local numlettersshown=7

--3.95 hardcodes these entity names:
local backchar="&leftarrow;"
local okchar="&ok;"

local letters=explode("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789?!")
local lettersi=table.invert(letters)
table.insert(letters,backchar)
lettersi.BACK=#letters
table.insert(letters,okchar)
lettersi.ENTER=#letters

local maxlength=THEME:GetMetric("NameEntry","MaxRankingNameLength")

local sound=function(name) SOUND:PlayOnce(THEME:GetPathS("NameEntry",name)) end

local position={}
local kbletters={}

local move
local input

input=function(attr)
	local pn=attr.PlayerNumber
	
	local dobackspace=function()
		if string.len(GetScreen():GetSelection(pn))>0 then
			sound("key")
			GetScreen():Backspace(pn)
		else
			sound("invalid")
		end
	end
	if pn and attr.type~="InputEventType_Release" and GAMESTATE:IsPlayerEnabled(pn) then
		if attr.GameButton=="MenuLeft" and GetScreen():GetEnteringName(pn) then
			sound("change")
			move(pn,-1)
		elseif attr.GameButton=="MenuRight" and GetScreen():GetEnteringName(pn) then
			sound("change")
			move(pn,1)
		elseif attr.GameButton=="Start" and attr.type=="InputEventType_FirstPress" then
			if not GetScreen():GetEnteringName(pn) or letters[position[pn]]==okchar then
				GetScreen():Finish(pn)
			elseif letters[position[pn]]==backchar then
				dobackspace(pn)
			else
				if string.len(GetScreen():GetSelection(pn))>=maxlength then
					sound("invalid")
				else
					sound("key")
				end
				GetScreen():EnterKey(pn,letters[position[pn]]) --moves to backspace if already full; moves to enter if becoming full
			end
		elseif attr.GameButton=="MenuUp" then MESSAGEMAN:Broadcast("NudgeScrollerUp") 
		elseif attr.GameButton=="MenuDown" then	MESSAGEMAN:Broadcast("NudgeScrollerDown")
		elseif attr.GameButton=="Select" and attr.type=="InputEventType_FirstPress" and GetScreen():GetEnteringName(pn) then
			dobackspace()
		elseif attr.GameButton=="Back" then
			if GetScreen():GetAnyEntering() then
				if not GetScreen():GetFinalized(pn) then
				--since we can't go back from this screen, use Back (eg, escape key) to quickly clear the name
					while string.len(GetScreen():GetSelection(pn))>0 do
						GetScreen():Backspace(pn)
					end
				end
			else
				GetScreen():Finish(pn)
			end
		end
	end
end

local moveto=function(pn,pos)
	if GetScreen():GetFinalized(pn) then return end
	local left=#letters/-2+1
	local right=#letters/2
	local leftvis=-numlettersshown/2
	local rightvis=numlettersshown/2

	for i,l in next,kbletters[pn],nil do
		local offs=wrap((i-pos),left,right)
		local visible=within(offs,leftvis,rightvis)

		l:stoptweening()
		l:decelerate(0.12)
		l:diffusealpha(visible and 1 or 0)
		l:x(offs*spacing)
	end
end
local movetoletter=function(pn,letter)
	position[pn]=lettersi[letter]
	moveto(pn,position[pn])
end
move=function(pn,dir)
	position[pn]=wrap((position[pn] or 1)+dir,1,#letters)
	moveto(pn,position[pn])
end

local entrybox=function(pn)
	kbletters[pn]={}

	local kb=Def.ActorFrame{
		InitCommand=cmd(y,24),
		SelectKeyMessageCommand=function(s,p)
			if p.PlayerNumber==pn then
				movetoletter(pn,p.Key)
			end
		end
	}

	for i,letter in next,letters,nil do
		local l=Def.BitmapText{
			Font="_common semibold black",
			Text=letter,
			InitCommand=function(s) 
				s:ztestmode("writeonfail")
				s:zoom(2)
				kbletters[pn][i]=s
			end,
			OnCommand=cmd(finishtweening),
			PlayerFinishedMessageCommand=function(s,p)
				if p.PlayerNumber==pn then
					s:decelerate(0.12)
					s:diffusealpha(0)
				end
			end,
		}
		kb[#kb+1]=l
	end

	-----

	return Def.ActorFrame{
		InitCommand=cmd(xy,SCREEN_CENTER_X+256*(PlayerIndex[pn]*2-3),SCREEN_CENTER_Y+168),

	--out of ranking
		Def.ActorFrame{
			EntryChangedMessageCommand=function(s,p)
				if p.PlayerNumber==pn then
					s:visible(false)
				end
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("NameEntry","OutOfRankingP1/box")
			},
			Def.BitmapText{
				Font="_common white",
				InitCommand=cmd(zoom,1.5),
				Text="Out of Ranking" --TODO l10n text for this?
			},
		},
	--entry box
		Def.ActorFrame{
			InitCommand=cmd(visible,false),
			EntryChangedMessageCommand=function(s,p)
				if p.PlayerNumber==pn then
					s:visible(true)
				end
			end,
			Def.Sprite{
				Texture=THEME:GetPathG("NameEntry","name frame p"..tostring(PlayerIndex[pn])),
				InitCommand=cmd(clearzbuffer,1;zbias,1;zbuffer,true),
			},
			Def.BitmapText{
				Font="_common semibold white",
				InitCommand=cmd(y,-24;zoom,2),
				EntryChangedMessageCommand=function(s,p)
					if p.PlayerNumber==pn then
						s:settext(p.Text)

						if not position[pn] then
							movetoletter(pn,p.Text~="_" and "ENTER" or "A")
						end
					end
				end,
			},

			kb,
			Def.Sprite{
				Texture=THEME:GetPathG("NameEntry","cursor p"..tostring(PlayerIndex[pn])),
				InitCommand=cmd(y,24),
				PlayerFinishedMessageCommand=function(s,p)
					if p.PlayerNumber==pn then
						s:decelerate(0.12)
						s:diffusealpha(0)
					end
				end	
			}
		}
	}
end

local out=Def.ActorFrame{
	OnCommand=function(s) GetScreen():AddInputCallback(input) end,
	OffCommand=function(s) GetScreen():RemoveInputCallback(input) end,

	Def.Sprite {
		Condition=GAMESTATE:GetCurrentStyle() and not THEME:GetMetric("Common","AutoSetStyle"),
		Texture=GAMESTATE:GetCurrentStyle() and THEME:GetPathG("MenuElements icon",GAMESTATE:GetCurrentStyle():GetName()) or "",
		InitCommand=cmd(x,SCREEN_LEFT+28;y,SCREEN_TOP+12)
	}
}
ForeachEnabledPlayer(function(pn)
	out[#out+1]=entrybox(pn)
end)

return out
