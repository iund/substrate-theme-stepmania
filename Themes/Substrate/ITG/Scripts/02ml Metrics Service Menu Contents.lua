--You can nest the submenus as deep as you like but that'll overcomplicate it for most users.

ServiceMenuScreens=function() return
{ Name="Service Menu", Contents=table.concati(
{
	{ Name='Insert Credit', Command='insertcredit' },
},
OPENITG and {
	{ Name='Clear Credits', Command='clearcredits' },
} or {{ Name="Clear Credits", Action=function()
			local cm=GetPref("CoinMode")
			local cpc=GetPref("CoinsPerCredit")
			SetPref("CoinMode",COIN_MODE_PAY)
			while GAMESTATE:GetCoins()/cpc>=1 do
				UnjoinPlayers()
				if GAMESTATE:GetCoins()/cpc<2 then
				GameCommand("style,single")
				else
				GameCommand("style,versus")
				end
			end
			SetPref("CoinMode",cm)
		end
	}},
{
	{ Name='Coin Options', Contents=table.concati(
		{
			{RowType.PrefNumber,'SongsPerPlay', 1,'%d stages', {slow=1, fast=1, snap=4}, { min=2, max=10 }},
			{RowType.PrefNumber,'CoinsPerCredit', 1,'%d coins', {slow=1, fast=1, snap=1}, { min=1, max=20 }},
			--{RowType.PrefNumber,"LifeDifficultyScale",1,"%.1fx",{slow=0.2,fast=0.2,snap=1},{min=0.400,max=1.600}},
			RowType.FreePlay,
			{RowType.PrefBool, 'EventMode'},
			{RowType.PrefBool, 'MenuTimer'},
			RowType.JointPremium,
		},
		OPENITG and {
			{RowType.PrefPercent,"SoundVolumeAttract",false,{min=0,max=GetPref("SoundVolume")}},
		} or {},
		{
			{RowType.PrefNumber,"AttractSoundFrequency",1,"%d cycles",false,{min=0,max=5}}, --0 = never, 1 = always, n = every n times.
		}
	)},
	{ Name='Game Options', Contents=table.concati(
		not IsArcade() and {
			{RowType.PrefNumber,"GlobalOffsetSeconds",1000,"%.1f ms",{slow=0.0002,fast=0.002,snap=0},{min=-0.100,max=0.100}},
		} or {},
		OPENITG and {
			{RowType.PrefNumber,"GiveUpTime",1,"%.1f s",{slow=0.5,fast=1,snap=1.5},{min=0,max=5}},
		} or {},
		{
			{RowType.PrefTime, 'LongVerSongSeconds', {slow=5, fast=15, snap=0}, { min=145, max=6000 }},
			{RowType.PrefTime, 'MarathonVerSongSeconds', {slow=5, fast=15, snap=0}, { min=180, max=6000 }},
		},
		{
			{RowType.LuaPrefBool,"MenuMusic"},
			{RowType.PrefBool,"ShowCaution"},
			{RowType.PrefBool,"BlinkGameplayButtonLightsOnNote"},
		},
		(IsArcade() or OPENITG) and {
			{RowType.PrefBool,"SongEdits"},
		} or {},
		OPENITG and {
			--{RowType.PrefBool,"CustomSongPreviews"},
			--{RowType.PrefBool,"CourseEdits"}
		} or {}
	)},
	OPENITG and { Name='Coin Data', Contents={
		{ Name='View', Screen='Bookkeeping' },
		{ Name='Clear', Command='clearbookkeepingdata' },
	}} or
		{ Name='View Coin Data', Screen='Bookkeeping' }
	,
	{ Name='Test Input', Screen='TestInput' },
	{ Name='Test Lights', Screen='TestLights' },
	{ Name='Test Screen', Screen='TestPattern' },

	{ Name='Hardware Status', Screen="HardwareStatus" }, --Branch.Diagnostics() },
	{ Name='Actions', Contents=
	table.concati(
		OPENITG and {
			{ Name='Add/Delete Packs', Screen='UserPacks' },
		} or {},
		{
			{ Name='Backup Machine Stats to USB', Command='transferstatsfrommachine' },
			{ Name='Restore Machine Stats from USB', Command='transferstatstomachine' },
		},
		(OPENITG or IsArcade()) and {
			{ Name='Install Update', Screen='Update' },
		} or {},
		IsArcade() and {
			{ Name='Reboot Machine', Screen='Reboot' },
		} or {},
		OPENITG and GetProductVer and { --Beta 3+ stuff:
			{ Name="Backup Crash Logs to USB", Command="transferlogsfrommachine" },
			{ Name="Clear Crash Logs", Command="clearmachinelogs" },
		} or {}
	)},
	{ Name='Set Time', Screen='SetTime' },
},
table.find(INPUTMAN:GetDescriptions(),"P3IO") and
{
	{ Name="Cabinet Setup", Contents={
		--RowType.CabinetType,
		{RowType.COMPort,"EXTIOComPort"},
		{RowType.COMPort,"SatelliteComPort"},
		{RowType.COMPort,"COM4PORT"},
	}},
} or {})} end

--[[new

extra prefs in git build, since oitg beta 3

	new InputTypes: "MiniMaid", "Home"

	new InputHandlers: "P3IO", "MiniMaid"

	possible InputTypes: "ITGIO" "PIUIO" "MiniMaid" "P3IO" (not sure on last one)
	possible InputHandlers (for ini):
		"P3IO" "MIDI" "Pump" "X11" "MonkeyKeyboard" "MK3" "MiniMaid"
		"SDL" "DirectInput" "tty" "PIUIO" "Joystick" "Iow" "Xbox"

	descriptions:
		"P3IO" "Win32_MIDI" "Pump USB" "Para USB"
		"Keyboard" "MonkeyKeyboard" 
		"MK3" "MiniMaid" "PIUIO" "ITGIO" 

	p3io:
	CabinetType= "SD" or "HD"
		--difference is:
		--InputHandler_P3IO: HD and SD update lights, HD also accounts for red/blue lights and neons? (what about satellite columns?)

	--LightsDriver_EXTIO: (defaults: Linux=ttyS0, Windows=COM1)
	EXTIOComPort=ttys0

	--LightsDriver_Satellite: (default: ttyS1 or COM2)
	SatelliteComPort=

	--io/P3IO.cpp: (default: COM2?)
	COM4PORT=

	--GameState:
	SongBroadcastURL=
	--ProfileManager:
	ScoreBroadcastURL=

	--MemoryCardDriverThreaded_Linux:
	--Pmount - seems to look in /media/${mountname} instead of sysfs?
	UsePmount=




	possible LightsDrivers

	Satellite
	PacDrive
	EXTIO

	LinuxParallel
	External
	Parallel (windows)
	LinuxWeedTech

	PacDrive
	G15
	Satellite

]]

DebugMenuScreens= --function() return
{ Name="Debug Menu", Contents={
	{ Name='Logging', Contents={
		{RowType.PrefBool,"ShowStats"},
		{RowType.PrefBool,"ShowLoadingWindow"},
		{RowType.PrefBool,"ShowLogOutput"},
		{RowType.PrefBool,"LogSkips"},
		{RowType.PrefBool,"LogFPS"},
		{RowType.PrefBool,"LogCheckpoints"},
		{RowType.PrefBool,"LogToDisk"},
		{RowType.PrefBool,"ForceLogFlush"},
		{RowType.PrefBool,"Timestamping"},
		{RowType.PrefBool,"DebugLights"},
	}},
--[[
	{ Name="Timing Windows",Contents={
			{RowType.PrefNumber,"JudgeWindowScale",1000,"%.1f ms",{slow=0.05,fast=0.10,snap=0},{min=0.200,max=2.000}},

			{RowType.PrefNumber,"JudgeWindowAdd",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsMarvelous",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsPerfect",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsGreat",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsGood",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsBoo",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsOK",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsRoll",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},
			{RowType.PrefNumber,"JudgeWindowSecondsMine",1000,"%.1f ms",{slow=0.0005,fast=0.005,snap=0},{min=0.000,max=1.000}},

	}},
--]]
	{ Name="Misc", Contents={
		{RowType.PrefBool,"Vsync"},
	}},
	{ Name='Boot', Contents={
		{RowType.LuaPrefBool,"ForceArcadeMode"}, --Debug and diag tool
		{RowType.LuaPrefBool,"SkipArcadeStart"}, --If mappings keep getting forced back, use this?
		{RowType.LuaPrefBool,"ArcadeStartNoRemap"},
		{RowType.LuaPrefBool,"IgnoreBootResolution"},
	}},
	{ Name='Attract', Contents={
		{RowType.LuaPrefBool,"VerboseTitleMenu"},
		{RowType.PrefBool,"ShowInstructions"},
		{RowType.LuaPrefBool,"PadLightsOnTitle"},
	}},
	{ Name="Gameflow", Contents={
		RowType.SaveEVNT,
--		{RowType.LuaPrefBool,"AfterCautionTestInput"},
		{RowType.LuaPrefBool,"StartOnFullMode"},
--		RowType.PlayMode,
--		{RowType.LuaPrefBool,"Timer"},
--		{RowType.LuaPrefTime,"TimerSeconds",{slow=15,fast=60,snap=600},{min=0,max=18000}}, --5 hours
--		{RowType.LuaPrefBool,"UseXMods"},
		RowType.DefaultCourseSort
	}},
	{ Name='SelectMusic', Contents={
		{RowType.LuaPrefBool,"UseOptionsList"},
		{RowType.LuaPrefBool,"SelectMusicExtraInfo"},
--		{RowType.LuaPrefBool,"ShowDDRScore"},
		{RowType.LuaPrefBool,"ShowCDTitle"},
		{RowType.LuaPrefBool,"ShowGrooveRadar"}, 
--		{RowType.LuaPrefBool,"ShowGrooveGraph"}, 
--		{RowType.LuaPrefBool,"ShowCharacterIcons"},
--		{RowType.LuaPrefBool,"ShowAutogenIcon"},
--		{RowType.LuaPrefBool,"ShowSortIcon"},
--		{RowType.LuaPrefBool,"ShowModsIcons"},
--		{RowType.LuaPrefBool,"ShowBalloons"},
--		{RowType.LuaPrefBool,"ShowCourseHasMods"},
--		{RowType.LuaPrefBool,"ShowDifficultyDisplay"},
		
		{RowType.PrefBool,"AutogenSteps"},
		{RowType.PrefBool,"AutogenGroupCourses"},
		{RowType.PrefBool,"ShowBanners"},
		RowType.BannerCache,
	}},
	{ Name='Gameplay', Contents={
		{RowType.LuaPrefBool,"EnableRivals"},
		{RowType.DancingCharacters,"ShowDancingCharacters"},
		{RowType.PrefPercent,"BGBrightness"},
		RowType.BGAMode,
		RowType.BGAVideos,
		{RowType.PrefBool,"SoloSingle"},
--		{RowType.PrefBool,"PercentageScoring"},
		{RowType.LuaPrefBool,"EnableJudgeGraph"},
	}},
--[[
	{ Name="Default Song", Contents={
		{RowType.DefaultFolder,"Default Folder",1},
		{RowType.DefaultSong,"Default Song"},
		{RowType.DefaultDifficulty,"Default Difficulty"}
	}},
--]]
	{ Name="Input", Contents={
		{RowType.LuaPrefBool,"SelectButtonPresent"}, --TODO. Use this to affect help text?
		{RowType.PrefBool,"OnlyDedicatedMenuButtons"},
		{RowType.PrefBool,"AutoMapOnJoyChange"},
	}},
	{ Name="Memory Cards", Contents={
		{RowType.PrefBool,"MemoryCards"},
		{RowType.PrefBool,"SignProfileData"},
		{RowType.PrefNumber,"MemoryCardUsbBusP1",false,false,false,{min=-1,max=15}},
		{RowType.PrefNumber,"MemoryCardUsbBusP2",false,false,false,{min=-1,max=15}},
		{RowType.PrefNumber,"MemoryCardUsbLevelP1",false,false,false,{min=-1,max=15}},
		{RowType.PrefNumber,"MemoryCardUsbLevelP2",false,false,false,{min=-1,max=15}},
		{RowType.PrefNumber,"MemoryCardUsbPortP1",false,false,false,{min=-1,max=15}},
		{RowType.PrefNumber,"MemoryCardUsbPortP2",false,false,false,{min=-1,max=15}},
		{RowType.DriveLetter,"MemoryCardOsMountPointP1"},
		{RowType.DriveLetter,"MemoryCardOsMountPointP2"},
		{RowType.LuaPrefBool,"ProfileDebugHotkey"},
	}},
	{ Name="Network", Contents={
		{ Name="Connect", Screen="NetworkOptions" },
		{ Name="Options", Contents={
			{RowType.LuaPrefBool,"AutoConnectNetwork"},
			{RowType.PrefNumber,"ServerWaitSeconds",1,"%.1f s",{slow=0.5,fast=1,snap=1.5},{min=1,max=15}},
			{ RowType.Info,"Server",{gettext=function() return GetPref("LastConnectedServer") end},true }
		}},
	}},
	{ Name='Packages', Screen='Packages' },
	{ Name='PlayLights', Screen='PlayLights' },
	{ Name='Graphics', Screen='OptionsGraphics' }, --BUG: this screen kicks back to the root menu instead of its parent. 
	{ Name='Game', Screen='Game' },
	{ Name="Actions", Contents={
		{ Name='Clear Rival Data', Action=function() GetSysProfile().Rival=nil PROFILEMAN:SaveMachineProfile() ScreenMessage("Rival data cleared") end },
		{ Name='Delete Machine Stats', Command='clearmachinestats' },
		{ Name='Reset To Defaults', Action=ResetToDefaults }, --Command='resettofactorydefaults', (resettofactorydefaults clears the settings and applies defaults.ini/static.ini, but doesn't reapply the overrides in [Preferences] afterward.)
		{ Name='Recache Stream Data', Screen='ReloadStreams' },
		{ Name='Recache Songs', Screen='Recache' },
	}},
	{ Name='Test Screens', Contents={
		{ Name='Test', Screen='ScreenTest' },
		{ Name='TestSound', Screen='ScreenTestSound' },
		{ Name='TestFonts', Screen='ScreenTestFonts' },
		{ Name='Sandbox', Screen='ScreenSandbox' },
	}},
	{ Name='Exit', Screen='Exit' }
}}

ServiceTestPatternInputs={
	{Code="MenuLeft", Action=function(pn) Broadcast("InputMenuLeftP"..pText[pn]) end},
	{Code="MenuRight", Action=function(pn) Broadcast("InputMenuRightP"..pText[pn]) end},
}
