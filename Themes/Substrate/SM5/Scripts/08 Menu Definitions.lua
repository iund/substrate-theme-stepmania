-- ITG title menu is in 02mg

TitleMenuEntries = function() return
	{
		{ Name="Start", PlayMode="PlayMode_Regular", Screen=Branch.TitleNext() },
--		{ Name="Profiles", Screen="Profiles" },
		{ Name="Test Inputs", Screen="TestInput" },
		{ Name="Map Inputs", Screen="Remap" },
--		{ Name="Edit", Screen="EditMenu" },
		{ Name="Options", Screen="ServiceMenu" },
	}
end

ModsMenuEntries=function() return
	{
		ModsMenu.speedmodtype,
		ModsMenu.speedmod,
		ModsMenu.modpercent("Mini",0,100,5),
		ModsMenu.noteskin,

		ModsMenu.modchoices("Persp",{"Distant","Overhead","Hallway"},false),
		ModsMenu.modpercent("Cover",0,100),
		ModsMenu.rate(1,2), --min, max rate
		ModsMenu.tempoinfo,
		ModsMenu.lengthinfo,

		ModsMenu.stepchart,
		ModsMenu.modbool("Reverse"),
		ModsMenu.modchoices("Hide",{"Hidden","Sudden","Stealth"},true),
		ModsMenu.exit
	}
end
