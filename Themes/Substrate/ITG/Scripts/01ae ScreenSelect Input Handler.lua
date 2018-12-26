--[[

SM5:
	TODO: SM5 has Input Callback functionality. Find out how it works?


	Screen.AddInputCallback()
	Screen.RemoveInputCallback()

	eg:
	
	GetScreen():AddInputCallback(inputhandler)
	
	inputhandler=function(p)
		p structure: (guessing)
		
		{
			DeviceInput={
				device=
				button=
				level=
				z=
				down=
				ago=
				is_joystick=
				is_mouse=
			},
			controller=
			button=
			type=
			GameButton=
			PlayerNumber=
			MultiPlayer=
		}
		
		local pn=pText[p.PlayerNumber]
		local btn=p.button

		InputHandler.
	end
	
		// Construct the table once, and reuse it.
	lua_createtable(L, 0, 7);
	{ // This block is meant to improve clarity.  A subtable is created for
		// storing the DeviceInput member.
		lua_createtable(L, 0, 8);
		Enum::Push(L, input.DeviceI.device);
		lua_setfield(L, -2, "device");
		Enum::Push(L, input.DeviceI.button);
		lua_setfield(L, -2, "button");
		lua_pushnumber(L, input.DeviceI.level);
		lua_setfield(L, -2, "level");
		lua_pushinteger(L, input.DeviceI.z);
		lua_setfield(L, -2, "z");
		lua_pushboolean(L, input.DeviceI.bDown);
		lua_setfield(L, -2, "down");
		lua_pushnumber(L, input.DeviceI.ts.Ago());
		lua_setfield(L, -2, "ago");
		lua_pushboolean(L, input.DeviceI.IsJoystick());
		lua_setfield(L, -2, "is_joystick");
		lua_pushboolean(L, input.DeviceI.IsMouse());
		lua_setfield(L, -2, "is_mouse");
	}
	lua_setfield(L, -2, "DeviceInput");
	Enum::Push(L, input.GameI.controller);
	lua_setfield(L, -2, "controller");
	LuaHelpers::Push(L, GameButtonToString(INPUTMAPPER->GetInputScheme(), input.GameI.button));
	lua_setfield(L, -2, "button");
	Enum::Push(L, input.type);
	lua_setfield(L, -2, "type");
	LuaHelpers::Push(L, GameButtonToString(INPUTMAPPER->GetInputScheme(), input.MenuI));
	lua_setfield(L, -2, "GameButton");
	Enum::Push(L, input.pn);
	lua_setfield(L, -2, "PlayerNumber");
	Enum::Push(L, input.mp);
	lua_setfield(L, -2, "MultiPlayer");


oITG:
	Best we're going to get in oITG is inside ScreenSelect via CodeDetector, even then it only gives you pn for menu buttons,
	and only for down press events. Autorepeat events gets sent to Messageman 

--]]


InputHandler={}
InputHandler={
	Temp={},
	Init=function(list)
		InputHandler.Temp.Input={i=0,List=list}
		return string.rep("s,",table.getn(list))
	end,
	Code=function()
		local env=InputHandler.Temp.Input
		env.i=env.i+1
		return env.List[env.i].Code
	end,
	Action=function()
		local env=InputHandler.Temp.Input
		return "lua,InputHandler.Temp.Input.List["..env.i.."].Action"
	end,
	Register=function(callback)
		local out={}
		for i,input in next,{"Start","Select","Back","MenuLeft","MenuRight","MenuUp","MenuDown","MenuLeft+MenuRight"},nil do
			out[i]=(function(input) return {Code=input, Action=function(pn) callback(input,pn) end} end)(input)
			--out[i]={Code=input, Action=function(pn) callback(input,pn) end} --input doesn't get passed to callback this way
		end
		return out
	end,
	RegisterSM5=function(callback)
		if Screen.AddInputCallback then
			local cb=function(p) callback(p.button,p.PlayerNumber) end
			GetScreen():AddInputCallback(cb)
		end
	end,
	Off=function()
		InputHandler.Temp=nil
	end,
}


-- Comment these out? They're debugging input lists:
-- [[
InputCodeTable={
	--these fire regardless of player, and PLAYER_INVALID is passed to pn.
	{Code="Left", Action=function(pn) InputHandler.Input(PAD_LEFT,pn) end},
	{Code="Right", Action=function(pn) InputHandler.Input(PAD_RIGHT,pn) end},
	{Code="Up", Action=function(pn) InputHandler.Input(PAD_UP,pn) end},
	{Code="Down", Action=function(pn) InputHandler.Input(PAD_DOWN,pn) end},
	{Code="UpLeft", Action=function(pn) InputHandler.Input(PAD_UPLEFT,pn) end},
	{Code="UpRight", Action=function(pn) InputHandler.Input(PAD_UPRIGHT,pn) end},

	--Start also plays the selection sound, and joins the side if a style isn't set. Redir to _silent if you don't want the sound.
	{Code="Start", Action=function(pn) InputHandler.Input(MENU_BUTTON_START,pn) end},

	--these trigger if a player is enabled. also pn is sent
	{Code="Select", Action=function(pn) InputHandler.Input(MENU_BUTTON_SELECT,pn) end},
	{Code="Back", Action=function(pn) InputHandler.Input(MENU_BUTTON_BACK,pn) end},

	--these work as expected, without auto-repeat.
	{Code="MenuLeft", Action=function(pn) InputHandler.Input(MENU_BUTTON_LEFT,pn) end},
	{Code="MenuRight", Action=function(pn) InputHandler.Input(MENU_BUTTON_RIGHT,pn) end},
	{Code="MenuUp", Action=function(pn) InputHandler.Input(MENU_BUTTON_UP,pn) end},
	{Code="MenuDown", Action=function(pn) InputHandler.Input(MENU_BUTTON_DOWN,pn) end},
}

TestCodeTable={
	--these fire regardless of player, and PLAYER_INVALID is passed to pn.
	{Code="Left", Action=function(pn) ScreenMessage("left") end},
	{Code="Right", Action=function(pn) ScreenMessage("right") end},
	{Code="Up", Action=function(pn) ScreenMessage("up") end},
	{Code="Down", Action=function(pn) ScreenMessage("down") end},
	{Code="UpLeft", Action=function(pn) ScreenMessage("down") end},
	{Code="UpRight", Action=function(pn) ScreenMessage("down") end},

	--Start also plays the selection sound, and joins the side if a style isn't set. Redir to _silent if you don't want the sound.
	{Code="Start", Action=function(pn) ScreenMessage("start "..pText[pn]) end},

	--these trigger if a player is enabled. also pn is sent
	{Code="Select", Action=function(pn) ScreenMessage("select "..pText[pn]) end},
	{Code="Back", Action=function(pn) ScreenMessage("back "..pText[pn]) end},

	--these work as expected, without auto-repeat.
	{Code="MenuLeft", Action=function(pn) ScreenMessage("menuleft p"..pText[pn]) end},
	{Code="MenuRight", Action=function(pn) ScreenMessage("menuright p"..pText[pn]) end},
	{Code="MenuUp", Action=function(pn) ScreenMessage("menuup p"..pText[pn]) end},
	{Code="MenuDown", Action=function(pn) ScreenMessage("menudown p"..pText[pn]) end},

	--these don't trigger at all (why should they?)
	{Code="Insert Coin", Action=function(pn) ScreenMessage("coin p"..pText[pn]) end},
	{Code="Operator", Action=function(pn) ScreenMessage("operator p"..pText[pn]) end},
}
--]]