-- Set default values in here

	SysProfileTemplate={
		StreamCache={}, --crashes on first run on builds w/o stream cache support (ie, all so far)
		HighScores={},
		GhostData={},
	}

	DefaultSettings={
		--Goes into stats.xml lua table for defaults:

		ModesInSort=true, --if this is false, then you can't get to marathon mode unless there's an efficient way to do it in ScreenTitleJoin
		Language="english", --comment this out to ask for language on first boot TODO
		AutoConnectNetwork=false,
		
		--credit timer
		Timer=false,
		TimerSeconds=600,

		--workout menu defaults		
		WorkoutSongsToPlay=10,
		WorkoutDifficultyMin=9,
		WorkoutDifficultyMax=12,
		BreakFrequency=5,
		BreakLength=10,

		UseXMods=true, --crashes on cancel-all code (LRLRLR) in mods menu if this is off ("Speed Type 0/2")
		
		DefaultFolder="In The Groove 2",
		DefaultSong="/Songs/In The Groove 2/Birdie/",
		DefaultDifficulty="Beginner",

		ShowGrooveRadar=true, --Disable this if it's broken
		VerboseTitleMenu=true,
		PadLightsOnTitle=true,
		
		SelectMusicExtraInfo=false, --NOTE:because theres lots of things there that don't work right (eg, radar, ghost data, no ranking table)
		EnableRivals=false,
		EnableJudgeGraph=false, --true, --evaluation is VERY slow loading when this is on
		StartOnFullMode=true, --false, --simplemode is a dumbed-down mode that restricts you to 1 song folder and no mods menu
		MenuMusic=true,
	}

	DefaultPrefs = {

		--coin
		MenuTimer=IsArcade(),
		SongsPerPlay=4,
		CoinMode=IsArcade() and COIN_MODE_PAY or COIN_MODE_HOME,
		EventMode=not IsArcade(),

		--attract
		SoundVolumeAttract=0.2,
		AttractSoundFrequency=IsArcade() and 1 or 0,

		--game options
		GiveUpTime=1.5,
		BGBrightness=0.4,
		LongVerSongSeconds=220,
		MarathonVerSongSeconds=600,
		SongEdits=IsArcade(),

		--hw
		MemoryCards=IsArcade(),
		BackgroundMode=2,
		BannerCache=1, --1 - load on boot, 2 - load on select music open
		OnlyDedicatedMenuButtons=IsArcade(),

		--misc
		Disqualification=true,

		IgnoredMessageWindows="FRAME_DIMENSIONS_WARNING,COMMAND_DEFINED_TWICE",
		Vsync=false,

		FailOffInBeginner=true,
		FailOffForFirstStageEasy=true,
		DelayedBack=false,

		ShowSelectGroup=false, --inapplicable
		CourseSelectUsesSections=true, --new

		MusicWheelSwitchSpeed=45,

		ShowSongOptions=-1,
		ShowLyrics=false,
		ShowDancingCharacters=0, --CO_OFF. Off because dancing characters draw over 3d parts of notes. Use 1 if you want random characters, or 2 for a character selection screen (not implemented)

		PadStickSeconds=0.05,

		CourseSortOrder=1, --whichever one that is?
		LogToDisk=false,
		ShowLoadingWindow=not IsArcade(),
	
		CustomMaxSeconds=480,
		CustomMaxSizeMB=15,
		CustomsLoadMax=80,
		CustomsLoadTimeout=30,

		VideoRenderers="opengl",
	}

	aDefaultPrefs = {
		--INI Prefs
		--These DO NOT get overwritten except when applying defaults
		--don't bother changing stuff in here!
		--Go to StepMania.ini or the in-game service menu instead

		MachineName=' ', --let the user pick it

		GlobalOffsetSeconds=-0.033, --Most home PCs I've used, tend to work with this offset

		MusicWheelSwitchSpeed=45,
		DefaultModifiers="FailEndOfSong", --fail 30 misses depends on this to work, the other default mods are defined in "Metrics Profile Defaults"
		PadStickSeconds=0.05,
		InputDebounceTime=0, --Padstick does a better job of this
		SoundVolume=0.7,
		SoundVolumeAttract=0.2,
		AttractSoundFrequency=IsArcade(),
		BackgroundMode=2,
		BGBrightness=0.3,
		Disqualification=true,
		MercifulBeginner=false,
		LongVerSongSeconds=220,
		MarathonVerSongSeconds=600,
		ShowInstructions=true,
		ArcadeOptionsNavigation=true,
		OnlyDedicatedMenuButtons=IsArcade(),
		DelayedBack=false,
		SongEdits=IsArcade(),
		CoinMode=IsArcade(), --pay mode or title menu
		SongsPerPlay=4,
		GiveUpTime=0.5,
		EventMode=not IsArcade(),
		MenuTimer=IsArcade(),
		ShowCaution=IsArcade(),
		
		MemoryCards=true,

		--beta 4 removes a few settings for USB songs:
		CustomMaxSeconds=480,
		CustomMaxSizeMB=15,
		CustomsLoadMax=80,
		CustomsLoadTimeout=30,

		SoloSingle=not IsArcade(),
		AutoMapOnJoyChange=true,
		FastLoad=true,
		ShowLyrics=false,
		BlinkGameplayButtonLightsOnNote=false,
		BannerCache=1,
		UseUnlockSystem=false, -- for "Random by difficulty number" folder
		LogFPS=false,

		FailOffInBeginner=true,
		FailOffForFirstStageEasy=true,

		-- [[
		--,
		-- BUG: Stepmania forces 640x480 fullscreen before it gets the chance to apply (only aspect gets set)
		DisplayWidth=1280,
		DisplayHeight=720,
		DisplayAspectRatio=16/9,
		--]]

		Windowed=not IsArcade(),
		IgnoredMessageWindows="FRAME_DIMENSIONS_WARNING",
		
		-- Use a slightly different default order for driver search. Provide Windows drivers first, then Linux, then Mac.
		-- All the drivers oITG b2 uses are listed here:
--[[
		InputDrivers='DirectInput,Joystick,X11,SDL',
		MovieDrivers='DShow,FFMpeg,Null',
		LightsDriver='Ext,PacDrive,G15,LinuxParallel,WeedTech,Parallel',
		-- Put Waveout first, hopefully this fixes Windows mixer lag (at the expense of hogging the sound chip)
		SoundDrivers='WaveOut,DirectSound,DirectSound-sw,ALSA,ALSA-sw,OSS,CoreAudio,Null',
--]]
		SoundDevice='hw:0', --only used by Alsa

		--D3D z masks only works right in Beta 3 and notITG. Force OpenGL instead.
		VideoRenderers='opengl', --'opengl,d3d',
		LastSeenVideoDriver='OpenGL'
	}

	ArchDefaults = { -- works slightly differently to DefaultPrefs
		InputDrivers = { windows = 'DirectInput,Para,Pump,MIDI', unix = 'X11,IOW,PIUIO,SDL', arcade="X11,PIUIO,IOW" },
		MovieDrivers = { windows = 'DShow', unix = 'FFMpeg,Null', arcade="FFMpeg" },
		LightsDriver = { windows = 'PacDrive,G15', unix = 'Ext,PacDrive,G15,LinuxParallel,WeedTech', arcade="Ext" },
		SoundDrivers = { windows = 'WaveOut,DirectSound,DirectSound-sw', unix = 'ALSA-sw,CoreAudio', arcade="ALSA-sw" },
	}
