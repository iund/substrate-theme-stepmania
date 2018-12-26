		--[[ correct special characters that display literally
		for _,s in next,{
			{"&UP;",""},
			{"&DOWN;",""},
			{"&LEFT;",""},
			{"&RIGHT;",""},
			{"&MENUUP;",""},
			{"&MENUDOWN;",""},
			{"&MENULEFT;",""},
			{"&MENURIGHT;",""},
			{"&START;",""},
			{"&BACK;",""},
			{"&OK;",""},
			{"&NEXTROW;",""},
			{"&SELECT;",""},
			{"&AUX1;",""},
			{"&AUX2;",""},
			{"&AUX3;",""},
			{"&AUX4;",""},
			{"&AUX5;",""},
			{"&AUX6;",""},
			{"&AUX7;",""},
			{"&AUX8;",""},
			{"&AUX9;",""},
		},nil do table.gsub(Languages,s[1],s[2]) end
		--]]


--Most of these strings will go through sprintf

--Languages[CurLanguage()].ScreenPlayerEntry.JoinPrompt
--Languages[CurLanguage()].ScreenTitleJoin.PressStart

Languages={
	english={
		Common={
			MonthNames={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"},
		},
		SystemOverlay={
			CreditText={
				FreePlay="Free Play",
				EventMode="Event Mode",
				PressStart="Press ",
				CreditsCoins="Credits: %d (%d/%d)", --eg, Credits: 3 (1/4)
				Credits="Credits: %d",
			},
		},
		Attract={
			InsertCoins="Insert %d %s", --eg, Insert 1 coin, Insert 4 coins
			PressStart="Press ",
			Coin="coin",
			Coins="coins",
		},
		ScreenTitleJoin={
			PressStart="Press  to begin",
			EventMode="Event Mode",
			Timer="%s Timer", --eg, 10:00 Timer
			Stages="up to %d stages", --eg, up to 4 stages
		},
		ScreenTitleMenu={
			Start="Start",
			StartMarathons="Start Marathons",
			StartWorkout="Start Workout",
			StartSurvival="Start Survival",
			StartSuperMarathon="Start Super Marathons",
			OnlinePlay="Online Play",
			NetworkPlay="Network Play",
			Edit="Edit",
			Practice="Practice",
			EditCourses="Edit Courses",
			Jukebox="Jukebox",
			Options="Options",
			TestInput="Test Input",
			Exit="Exit",
		},
		ScreenCaution={
			Title="Caution",
			Text=
[[
Extreme motions
can be dangerous.

If you have a health
condition, please seek
medical advice before playing.
]],
		},
		ScreenPlayerEntry={
			Styles={
				single="Single",
				versus="Versus",
				double="Double",
				couple="Couple",
				solo="6 panel",
				halfdouble="Half double",
			},
			USB={
				InsertUSB="Insert USB",
				Ready="Ready",
				Removed="USB removed",
			},
			PlayMode="Play mode:",
			StartPlay="Press  to play\na %d player game", --eg, Press start to play a 1 player game
			CoinsDouble="Insert %d more %s to select Double", --eg, Insert 2 more credits to play Double
			StartJoin="Press  to join",
			CoinsJoin="Insert %d more %s\nto join", --eg, insert 1 more credit to join
			Coin="coin",
			Coins="coins",
		},
		ScreenSelectMusic={
			Player="Player %d",
			HelpTips={
				" or  Move      Play",
				" Easier      Harder",
				"+ Change sort",
				" or  More chart information",
--				" more options",
			},
			HelpTipsSimple={
				" or  Move      Play",
				" Easier      Harder",
				"+ Switch to full mode",
			},
			PaneSelectMenuHelp={
				" Easier      Harder",
				" Change sort"
			},
			SelectMenuHelp=" Easier      Change sort      Harder",
			OptionsMenuPrompt={
				PressStart=[[Press  again to
open options menu]],
				Entering="Opening options menu"
			},
			Pane={
				Steps="Steps",
				Jumps="Jumps",
				Hands="Hands",
				Mines="Mines",
				Holds="Holds",
				Rolls="Rolls",
				Top="Top",
				USB="USB",
			},
			Sort={
				Folder="Sort - Folder",
				Title="Sort - Title",
				Tempo="Sort - Tempo",
				Artist="Sort - Artist",
				Easy="Sort - Easy",
				Medium="Sort - Medium",
				Hard="Sort - Hard",
				Expert="Sort - Expert",
				Blender="Sort - Blender",

				DanceMode="Mode - Dance",
				MarathonMode="Mode - Marathon",
				SurvivalMode="Mode - Survival",

				--Course mode:

				AllCourses="List - All Course Types",
				Marathon="List - Marathon",
				Survival="List - Survival",
				Workout="List - Workout",

				SongCount="Sort - Song Count",
				AverageMeter="Sort - Average Meter",
				TotalMeter="Sort - Total Meter",
				Rank="Sort - Rank",
			},
			MusicWheel={
				Roulette="Roulette",
				Random="Random",
			
			},
			Customs={
				Loading=[[
Please wait - loading custom song.
Removing the USB will abort the selection.]],
				Cancel="Loading aborted."
			},
		},
		Difficulty={
			Beginner="Novice",
			Easy="Easy",
			Medium="Medium",
			Hard="Hard",
			Challenge="Expert",
			Edit="Edit",
		},
		CourseDifficultyNames = { "Light","Normal","Intense" },
		Menus={
			Mods="mods",
		},	
		Mods={
			Titles={
				Speed="Speed",
				SpeedChanges="Speed Changes",
				SpeedModType="SpeedType",
				Mini="Mini",
				Noteskins="NoteSkins",
				Persp="Perspective",
				JudgeFont="Judge Font",
				--MeasureType="Measure Type",
				JudgeAnimation="Judge Animation",
				ComboColour="Combo Colour",
				Cover="Cover",
				--RemoveMines="No Mines",
				--HideJudge="Hide Judge",
				HideHoldJudge="Hide Hold Judge",
				MusicRate="Rate",
				Colour="Color",
				LifebarMode="Lifebar Mode",
			},
			Bool={
				Off="Off",
				On="On",
			},
			Names={
				Persp={
					Hallway="Hallway",
					Overhead="Overhead",
					Distant="Distant",
					Incoming="incoming",
					Space="spaceman"
				},
				JudgeFonts={
					Default="Default",
				},
				SpeedModTypes={
					X="x",
					M="m",
					C="c",
				},
				SpeedChanges={
					Constant="fixed",
					Variable="variable",
				},
				Noteskins={
					metal="Metal",
					cel="Cel",
					flat="Flat",
					vivid="Vivid",
					robot="Robot"
				},
				ComboColour={
					Midpoint="Mid point",
					SongStart="Song start",
					ComboStart="Combo start",
					Off="Off",
				},
				JudgeAnimation={
					Small="small",
					Medium="medium",
					Big="big",
					Static="static",
				},
			},
		},
		JudgeNames={
				Marvelous="Fantastic",
				Perfect="Excellent",
				Great="Great",
				Good="Decent",
				--Boo="Way Off",
				Miss="Miss",
				OK="Yeah",
				NG="Bad",
				HitMine="Hit Mine",
		
		},
		ScreenOptions={
			Disqualify="Score will not be saved",
			Exit="exit", --TODO
			HelpTips={
				" or  Move",
				" Down      Up",
			},
		},
		ScreenGameplay={
			--background text:
			Danger="Danger",
			Failed="Failed",
			--give up text:
			GiveUp="Hold  to quit",
			GiveUpAborted="Continuing",
		},
		ScreenEvaluation={
			PlayerFrame={
				Jumps="Jumps",
				Holds="Holds",
				Mines="Mines",
				Hands="Hands",
				Rolls="Rolls",
				
				Fantastic="Fantastic",
				Excellent="Excellent",
				Great="Great",
				Decent="Decent",
				WayOff="way off", --unused
				Miss="Miss",
			},
			PercentFrame={
				Failed="Failed",
				Disqualified="Score not saved"
			},
			HelpTips={
				" Done",
			},
			HelpTipsUSB={
				" Done",
				" Screenshot" --TODO: L+R Screenshot
			},
			Award={
				Timing={
					FullComboGreats="Full Great Combo",
					FullComboPerfects="Full Excellent Combo",
					FullComboMarvelouses="Full Fantastic Combo",
					Greats90Percent="80% Greats",
					Greats90Percent="90% Greats",
					Greats100Percent="100% Greats",
					OneGreat="One Great",
					OnePerfect="One Excellent",
					SingleDigitGreats="Single Digit Greats",
					SingleDigitPerfects="Single Digit Excellents"
				},
				Combo={
					Peak10000Combo="Peak 10,000 Combo",
					Peak1000Combo="Peak 1,000 Combo",
					Peak2000Combo="Peak 2,000 Combo",
					Peak3000Combo="Peak 3,000 Combo",
					Peak4000Combo="Peak 4,000 Combo",
					Peak5000Combo="Peak 5,000 Combo",
					Peak6000Combo="Peak 6,000 Combo",
					Peak7000Combo="Peak 7,000 Combo",
					Peak8000Combo="Peak 8,000 Combo",
					Peak9000Combo="Peak 9,000 Combo",
				},
			},
		},
		ScreenNameEntryTraditional={
			OutOfRanking="Out of ranking",
			HelpTips={
				" or  Move",
				" Add / Done      Delete"
			},
		},
		ScreenEnding={
			GameOver="Game over",
			RemoveUSB="Remove USB",
		},
		ScreenRanking={
			--single song ranking
			--single course ranking
		},
	},
}

--sprintf(Languages[CurLanguage()].ScreenSelectMusic.Player,pn)