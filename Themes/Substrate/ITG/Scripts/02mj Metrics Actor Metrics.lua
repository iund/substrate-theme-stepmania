	Metrics={
		System={
			TimerXY={SCREEN_LEFT+128,SCREEN_TOP+12},
			MenuTimerXY={SCREEN_RIGHT-16,SCREEN_TOP+12},
			StyleIconXY={SCREEN_LEFT+32,SCREEN_TOP+12},
			USBIconX={SCREEN_LEFT+16,SCREEN_RIGHT-16},
			USBIconY=SCREEN_BOTTOM-12,
			
			CreditsTextX={SCREEN_LEFT+32,SCREEN_RIGHT-32},
			CreditsTextY=SCREEN_BOTTOM-12,

			Message={
				FrameXY={SCREEN_CENTER_X,SCREEN_TOP},
				TextXY={SCREEN_CENTER_X,SCREEN_TOP+8}, --SCREEN_LEFT+8,SCREEN_TOP+8}
			},
			
			HelpTextXY={SCREEN_CENTER_X,SCREEN_BOTTOM-12},
			
			NetStatusXY={SCREEN_RIGHT-64,SCREEN_TOP+12}, --"LAN" / "ONLINE" status text. Top right
		},
		
		Title={
			IdleTimeout=30,
			LockInputTime=0.2,

			EntriesXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-128},
			EntriesSpacingY=24,

			--centered text version
			SongsXY={SCREEN_CENTER_X,SCREEN_TOP+16},
			
			--old corners version
			VersionXY={SCREEN_LEFT+16,SCREEN_TOP+16},
			--SongsXY={SCREEN_RIGHT-16,SCREEN_TOP+16},
			MaxStagesXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-64}, -- +64},
			LifeDiffXY={SCREEN_LEFT+16,SCREEN_TOP+40},

		},
		PlayerEntry={
			MenuTimer=30,
			
		},
		ModsMenu={
			MenuTimer=60,

			FrameXY={SCREEN_CENTER_X,SCREEN_CENTER_Y},

			PageXY={0,0},

			--decorations
			DisqualifyX={-256,256},
			DisqualifyY=156,
			DisqualifySize={288,24},

			ExplanationX={-256,256},
			ExplanationY=192,
			ExplanationSharedX=0,
			
			ExitY=192,

			--rows
			ItemsTopY=-156,
			ItemsHeight=296,

			NumItems=12,
			
			TweenSeconds=0.15,
			
			--each row:
			BulletX=0,
			TitleX=0, -- -128,
			
			ItemsX={-256,256},
			ItemsSharedX=128,

			--tab bar - {left,right}
			ItemsListX={-200,200},
			ItemsListGapX=32,
			
			--mod icons, reused for preview menus
			IconsX={-144,144},
			IconTextZoom=0.75,
			
		},
	
		ScorePlaceholderName = "----",
		Gameplay = {

			--top bar
			LifeFrameXY={SCREEN_CENTER_X,SCREEN_TOP+20}, --contains progress bar
			SongProgressWidth=728*(SCREEN_WIDTH/853), --728,
			SongProgressHeight=40,
			SongProgressXY={0,SCREEN_TOP+20},
			DifficultyMeterX={SCREEN_CENTER_X-(364*(SCREEN_CENTER_X/426.5)),SCREEN_CENTER_X+(364*(SCREEN_CENTER_X/426.5))},
			--DifficultyMeterX={SCREEN_CENTER_X-364,SCREEN_CENTER_X+364},
			DifficultyMeterY=SCREEN_TOP+20,
			DifficultyMeterXReverse={SCREEN_CENTER_X-364,SCREEN_CENTER_X+364},
			DifficultyMeterYReverse=SCREEN_TOP+20,

			--top
			BPMXY={SCREEN_CENTER_X,SCREEN_TOP+20}, --68},
			SongTimerXY={SCREEN_CENTER_X,SCREEN_TOP+50}, --96},
			ScoreY=SCREEN_TOP+20, --score X is PlayerX
			SongOptionsXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+192},
			
			--player
			LifeX={SCREEN_LEFT+16+math.ceil((SCREEN_WIDTH-640)*0.09),SCREEN_RIGHT-16-math.ceil((SCREEN_WIDTH-640)*0.09)}, --screen edge (20px in) on 4:3, 32px in on 16:9
			--LifeX={SCREEN_LEFT+32,SCREEN_RIGHT-32},
			LifeY=SCREEN_CENTER_Y,
			
			GhostXOffset=-96,
			GhostY=SCREEN_CENTER_Y,

			StreamXOffset=96,
			StreamY=SCREEN_CENTER_Y,
			StreamNextY=SCREEN_CENTER_Y+16,

			--bottom
			StageXY={SCREEN_CENTER_X,SCREEN_BOTTOM-32},
			SongNameXY={SCREEN_CENTER_X,SCREEN_BOTTOM-16},

			CourseStageSpriteXY={123,456},
			CourseStageTextX={SCREEN_WIDTH*0.25,SCREEN_WIDTH*0.75},
			CourseStageTextY=SCREEN_BOTTOM-32,
			
			LyricText={
				DimColour="0.5,0.5,0.5,1",
				NormalXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+SCREEN_HEIGHT/4},
				ReverseXY={SCREEN_CENTER_X,SCREEN_CENTER_Y},
				OneReverseXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-SCREEN_HEIGHT/4},
			},

			--unused frames
			ScoreFrameXY={123,456},
			StageFrameXY={123,456},

			--player unused
			StepsDescriptionX={123,456}, --unused, but could be used for something?
			StepsDescriptionY=789,
			ModsX={123,456}, --todo
			ModsY=SCREEN_CENTER_Y,
			ActiveAttackListX={SCREEN_CENTER_X-24,SCREEN_CENTER_X+24},
			ActiveAttackListY=SCREEN_CENTER_Y+SCREEN_HEIGHT/4,

			--Custom course progress list
			CourseProgressBoxXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+136},
			CourseProgressSongXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+56},
			CourseProgressMeterX={SCREEN_CENTER_X-176,SCREEN_CENTER_X+176},
			CourseProgressMeterY=SCREEN_CENTER_Y+56,
			CourseProgressNextSongXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+56},
			CourseProgressNextMeterX={SCREEN_CENTER_X-176,SCREEN_CENTER_X+176},
			CourseProgressNextMeterY=SCREEN_CENTER_Y+56,
			
			Scoreboard={
				NamesX={SCREEN_CENTER_X+40,SCREEN_CENTER_X-270},
				NamesY=SCREEN_CENTER_Y-160,
				ComboX={SCREEN_CENTER_X+160,SCREEN_CENTER_X-160},
				ComboY=SCREEN_CENTER_Y-160,
				GradeX={SCREEN_CENTER_X+270,SCREEN_CENTER_X-40},
				GradeY=SCREEN_CENTER_Y-160,
			},

		},
		NetBase={
			Players={
				Box={
					Size={384,72},
					XY={SCREEN_CENTER_X+176,SCREEN_CENTER_Y-180},
				},
				Text={
					StartX=SCREEN_CENTER_X+44,
					SpacingX=80,
					TopY=SCREEN_CENTER_Y-204,
					BottomY=24,
				},
			},
			Chat={
				Output={
					Box={
						Size={384,320},
						XY={SCREEN_CENTER_X+176,SCREEN_CENTER_Y+16},
					},
					Text={
						Lines=15,
						Width=352,
						XY={SCREEN_CENTER_X,SCREEN_CENTER_Y+160}, --bottom left aligned
					},
				},
				Input={
					Box={
						Size={384,40},
						XY={SCREEN_CENTER_X+176,SCREEN_CENTER_Y+196},
					},
					Text={
						Width=352,
						XY={SCREEN_CENTER_X,SCREEN_CENTER_Y+184}, --top left aligned
					},
				},
			},
		},
		NetRoom={
			TitleBG={
				Size={800,432},
				XY={SCREEN_CENTER_X,SCREEN_CENTER_Y},
			},
			Title={
				--Size={}, --TitleBG gets reused
				XY={SCREEN_CENTER_X+176,SCREEN_CENTER_Y-120},
			},
			RoomWheel={
				XY={SCREEN_CENTER_X-192,SCREEN_CENTER_Y}, --+84},
				SpacingY=48,
				NumItems=11, --must be odd
			},

			RoomWheelItem={
				Text={
					XY={-168,0},
					Width=336,
				},
				Desc={
					XY={168,0},
					Width=336,
				},
			},
		},
		NetSelectMusic={
			DiffBG={
				Size={800,432},
				XY={SCREEN_CENTER_X,SCREEN_CENTER_Y},
			},

			--[[
			DifficultyIconX={}
			DifficultyIconY=

			MeterX={},
			MeterY=
			--]]
			
			MusicWheelXY={SCREEN_CENTER_X-192,SCREEN_CENTER_Y+84},
			BPMDisplayXY={SCREEN_CENTER_X-336,SCREEN_CENTER_Y-60},

			--Overlay:
			BannerXY={SCREEN_CENTER_X-192,SCREEN_CENTER_Y-144},
			BannerSize={352,144},
			BannerFrameXY={SCREEN_CENTER_X-192,SCREEN_CENTER_Y-60},

		},
		SelectSuperMarathon={
			List={
				MaskXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+32},
				MaskSize={800,368},
				
				BannerXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-200},
				BannerSize={209,82},
			},
			PlayerPane={
				X={SCREEN_CENTER_X-252,SCREEN_CENTER_X+252},
				Y=SCREEN_CENTER_Y-200,
				PlayerNameXY={-108,0},
				Labels={
					NumStepsXY={-92,-24},
					JumpsXY={-92,0},
					HandsXY={-92,24},
					MinesXY={32,-24},
					HoldsXY={32,0},
					RollsXY={32,24},
				},
				Texts={
					NumStepsXY={-32,-24},
					JumpsXY={-32,0},
					HandsXY={-32,24},
					MinesXY={92,-24},
					HoldsXY={92,0},
					RollsXY={92,24},
				},
			},
			Column={
				PaneXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+32},
				--relative to col centre:
				PaneSpacingX=160,
				FolderXY={0,-168},
				LengthXY={0,-152},
				NumSongsXY={0,-136},
				--the below are vertalign,top :
				SongsXY={0,-128},
				DiffsX={-64,64},
				DiffsY=-128,
			}
		},
		SelectMusic = {
			SampleDelay=0.1,
			
			MenuTimer=120,

			OptionsMenuPromptTime=2.5,
			StageXY={SCREEN_CENTER_X,SCREEN_TOP+12},
			BannerXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-144},
			BannerSize={352,144},
			
			BannerFrameXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-60}, --reused to house bpm, etc
			BannerFrameSize={352,24},
			BPMDisplayXY={SCREEN_CENTER_X-168,SCREEN_CENTER_Y-60},
			ArtistXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-60},
			TotalTimeXY={SCREEN_CENTER_X+168,SCREEN_CENTER_Y-60},
			
			WheelXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+84},			--Y+72
			WheelMaskXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+84},			--Y+72
			CourseContentsXY={SCREEN_CENTER_X+96,SCREEN_CENTER_Y+72},
			SongOptionsXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-84},
			PlayerPaneX={SCREEN_CENTER_X-288,SCREEN_CENTER_X+288},
			PlayerPaneY=SCREEN_CENTER_Y+8,
			CourseContentsXY={123,456}, --unused
			
			PaneDisplay={
				Width=224,
				OverXY={0,-8},
				UnderXY={0,-8},
				EmptyScoreName="Top", --TODO: Move this to Languages.
---- New layout test:
--[[
				Labels={
					NumStepsXY={-72,148},
					JumpsXY={-72,169},
					HandsXY={-72,190},
					MinesXY={36,148},
					HoldsXY={36,169},
					RollsXY={36,190},
					--SM5: Where should these go? Might hide them.
					LiftsXY={36,186}, --
					FakesXY={36,186},
					Score={ MachineXY={-108,100}, PersonalXY={4,100} },
				},
				Texts={
					NumStepsXY={-16,148},
					JumpsXY={-16,169},
					HandsXY={-16,190},
					MinesXY={84,148},
					HoldsXY={84,169},
					RollsXY={84,190},
					--SM5: Where should these go? Might hide them because they're not something I'd likely use.
					LiftsXY={84,186},
					FakesXY={84,186},

					Score={ MachineXY={0,100}, PersonalXY={108,100} }, --scores are right aligned
				},
				PlayerNameXY={0,-196},
				ModsXY={0,-164},
				StepsDescriptionXY={0,132},

				DifficultyList={
					StartXY={0,-112}, --top row
					SpacingY=28,
					MeterX=-80,
					BarX=-56,
					BarBlockWidth=8, --an 18 will fill the bar 
					DescriptionX=-56,
					DescriptionMaxWidth=192,
					InfoText={0,-28}, --relative to StartXY
				},
				CourseList={
					StartXY={0,-124}, --top row
					SpacingY=24,
					MeterX=-80,
					DescriptionX=-56,
					DescriptionMaxWidth=192,
					InfoText={0,-28}, --not used?
				},

				ScoreList={
					StartXY={0,68}, --base
					ColX={
						Rank=-96,
						Name=-56,
						Score=8,
						Date=80,
					},
				},
				
				OptionsList={
					StartX={SCREEN_CENTER_X-288,SCREEN_CENTER_X+288},
					StartY=SCREEN_CENTER_Y-128,

					NumShownItems=8,
					SpacingY=24,
					SplitThreshold=13,
					SplitWidth=0,
				},


--]]
-- [[
				Labels={
					NumStepsXY={-72,144},
					JumpsXY={-72,165},
					HandsXY={-72,186},
					MinesXY={36,144},
					HoldsXY={36,165},
					RollsXY={36,186},
					--SM5: Where should these go? Might hide them.
					LiftsXY={36,186},
					FakesXY={36,186},
					Score={ MachineXY={56,-120}, PersonalXY={-56,-120} },
				},
				Texts={
					NumStepsXY={-16,144},
					JumpsXY={-16,165},
					HandsXY={-16,186},
					MinesXY={84,144},
					HoldsXY={84,165},
					RollsXY={84,186},
					--SM5: Where should these go? Might hide them because they're not something I'd likely use.
					LiftsXY={84,186},
					FakesXY={84,186},

					Score={ MachineXY={56,-96}, PersonalXY={-56,-96} },
				},
				PlayerNameXY={0,-188},
				StepsDescriptionXY={0,120},
				ModsXY={0,-144},
				DifficultyList={
					StartXY={0,-44}, --top row
					SpacingY=28,
					MeterX=-80,
					BarX=-56,
					BarBlockWidth=8, --an 18 will fill the bar 
					DescriptionX=-56,
					DescriptionMaxWidth=192,
					InfoText={0,136},
				},
				CourseList={
					StartXY={0,-56}, --top row
					SpacingY=24,
					MeterX=-80,
					DescriptionX=-56,
					DescriptionMaxWidth=192,
					InfoText={0,136},
				}
--]]	
			},
			GrooveRadarX={SCREEN_CENTER_X+288,SCREEN_CENTER_X-288},
			GrooveRadarY=SCREEN_CENTER_Y+112,
		},
		MusicWheel = {
			SwitchSpeed=0.10, --for a single switch; holding to scroll reads a value from prefsman
			ItemWidth=352,
			SpacingY=24,
			NumItems=13, --allow 2 either side to make it seamless
			TitleTextZoom=0.75,
			HighlightXY={0,0.5}, --its an odd num of pixels tall
			NumTopSongs=100, --popularity sort
		},
		MusicWheelItem = {
			MaxTextWidth=280,
			BannerSize={460,22}, --42
			MeterX={-158,158},
			GradeX={-148,148},
		},
		Evaluation = {
			MenuTimer=45,
		--middle box
			StageXY={SCREEN_CENTER_X,SCREEN_TOP+12},
			BannerSize={256,100},
			BannerXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-136}, --128},
			SongNameXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-200}, --192},
			SongOptionsXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-72}, --64},

			--test these:
			SongBPMXY={SCREEN_CENTER_X-120,SCREEN_CENTER_Y-72}, --64},
			SongRateXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-72}, --64},
			SongLengthXY={SCREEN_CENTER_X+120,SCREEN_CENTER_Y-72}, --64},

		
		--stats pane
		
		--12px down
			PlayerPaneX={SCREEN_CENTER_X-208,SCREEN_CENTER_X+208},
			PlayerPaneY=SCREEN_CENTER_Y+88,
			StepsDescriptionX={SCREEN_CENTER_X-192,SCREEN_CENTER_X+192},
			StepsDescriptionY=SCREEN_CENTER_Y-28,
			StatsLabelsX={SCREEN_CENTER_X-288,SCREEN_CENTER_X+288},
			StatsNumbersX={SCREEN_CENTER_X-232,SCREEN_CENTER_X+232},
			JudgeLabelsX={SCREEN_CENTER_X-168,SCREEN_CENTER_X+168},
			JudgeNumbersX={SCREEN_CENTER_X-40,SCREEN_CENTER_X+40},
			JudgeTopY=SCREEN_CENTER_Y+4,
			JudgeBottomY=SCREEN_CENTER_Y+100,
			NumJudgeRows=5,
			StatsTopY=SCREEN_CENTER_Y+4,
			StatsBottomY=SCREEN_CENTER_Y+100,
			NumStatsRows=5,
			MeterX={SCREEN_CENTER_X-376,SCREEN_CENTER_X+376},
			MeterY=SCREEN_CENTER_Y-8,
			ModsX={SCREEN_CENTER_X-208,SCREEN_CENTER_X+208},
			ModsY=SCREEN_CENTER_Y+132,
			LifeGraphX={SCREEN_CENTER_X-208,SCREEN_CENTER_X+208},
			LifeGraphY=SCREEN_CENTER_Y+180,
			ComboGraphY=SCREEN_CENTER_Y+180,
			ComboGraphNumbersY=24,
			TimeX={SCREEN_CENTER_X-404,SCREEN_CENTER_X+12},
			TimeY=SCREEN_CENTER_Y+188,

		--percent box
			PercentX={SCREEN_CENTER_X-276,SCREEN_CENTER_X+276},
			PercentY=SCREEN_CENTER_Y-152, --144
			PercentFrameX={SCREEN_CENTER_X-276,SCREEN_CENTER_X+276},
			PercentFrameY=SCREEN_CENTER_Y-136, --128,
			PlayerNameX={SCREEN_CENTER_X-276,SCREEN_CENTER_X+276},
			PlayerNameY=SCREEN_CENTER_Y-200, --192,
			DQX={SCREEN_CENTER_X-208,SCREEN_CENTER_X+208}, --DQX={SCREEN_CENTER_X-276,SCREEN_CENTER_X+276},
			DQY=SCREEN_CENTER_Y+180, --DQY=SCREEN_CENTER_Y-80, --72,
			Record={
				MachineX={SCREEN_CENTER_X-276,SCREEN_CENTER_X+276},
				MachineY=SCREEN_CENTER_Y-80, --72,
				PersonalX={SCREEN_CENTER_X-276,SCREEN_CENTER_X+276},
				PersonalY=SCREEN_CENTER_Y-80, --72,
			},
			ScoreListX={
				{ --p1
					--box center x is SCREEN_CENTER_X-276
					--box is 256px wide
					--TODO: tweak the values so it looks right
					rank=SCREEN_CENTER_X-276-112,
					name=SCREEN_CENTER_X-276-64,--
					score=SCREEN_CENTER_X-276+16,
					date=SCREEN_CENTER_X-276+92,
				},
				{ --p2
					rank=SCREEN_CENTER_X+276-112,
					name=SCREEN_CENTER_X+276-64,
					score=SCREEN_CENTER_X+276+16,
					date=SCREEN_CENTER_X+276+92,
				},
			},
			ScoreListY=SCREEN_CENTER_Y-88, --80,
			NumScoresDisplayed=3,
			
			--Net players list
			PlayerListBG={
				Size={264,572},
				Color="0,0,0,1",
				X={SCREEN_CENTER_X-280,SCREEN_CENTER_X+280},
				Y=SCREEN_CENTER_Y,
			},
			PlayerListLines={
				TopX={SCREEN_CENTER_X-280,SCREEN_CENTER_X+280},
				TopY=SCREEN_CENTER_Y-184,
				SpacingX=0,
				SpacingY=24,
			},

			--bonus bars (dummy values)
			BonusBarX={ --p1, p2
				SCREEN_CENTER_X-128,
				SCREEN_CENTER_X+128,
			},
			BonusBarY={
				SCREEN_CENTER_Y+128+32*1,
				SCREEN_CENTER_Y+128+32*2,
				SCREEN_CENTER_Y+128+32*3,
				SCREEN_CENTER_Y+128+32*4,
				SCREEN_CENTER_Y+128+32*5,
			} --bars 1-5
		},
		Summary={ -- Custom summary, uses values relative to center of object before it
			ScoreListX={
				self={-248,248},
				rank=-86,
				name=-54,
				score=4,
				date=68,
			},
			ScoreListY=-8, --it's top-aligned
			ScrollerY=16,
			
			SongNameY=-46,
			SongInfoY=46,
			BannerSize={192,75},
			
			JudgeX={-100,100},
			PercentX={-248,248},
			PercentY=-36,

			MeterX={-384,384},
			MeterY=0,

			ScoreHeight=112,
			NumScoresDisplayed=3,
			
			ScrollInterval=4,
			ScrollTweenTime=0.25, --seconds
			NumFeatsShown=3, --determines the mask height
		},
		NameEntry={ --Old nameentry scroller the game itself generates, which is now mostly redundant due to my custom one.
			MenuTimer=75,
			
			NameLength=4,
			Letters="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789?!",
			ScrollInterval=4,
			
			ScoreListX={
				{ --p1
					rank=SCREEN_CENTER_X-392,
					name=SCREEN_CENTER_X-324,
					score=SCREEN_CENTER_X-256,
					date=SCREEN_CENTER_X-208,
				},
				{ --p2
					rank=SCREEN_CENTER_X+208,
					name=SCREEN_CENTER_X+256,
					score=SCREEN_CENTER_X+324,
					date=SCREEN_CENTER_X+392,
				},
			},
			ScoreListY=-80,
			NumScoresDisplayed=3,

			--Name entry box
			EnterScoreTextXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+132},
			HelpBoxXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+192},
			
			OutOfRankingX={SCREEN_CENTER_X-256,SCREEN_CENTER_X+256},
			OutOfRankingY=SCREEN_CENTER_Y+168,
			EntryFrameX={SCREEN_CENTER_X-256,SCREEN_CENTER_X+256},
			EntryFrameY=SCREEN_CENTER_Y+168,

			KeyboardX={SCREEN_CENTER_X-256,SCREEN_CENTER_X+256},
			KeyboardY=SCREEN_CENTER_Y+192,
			NumLettersShown=7,
			LetterSpacing=40,
			SelectionX={SCREEN_CENTER_X-256,SCREEN_CENTER_X+256},
			SelectionY=SCREEN_CENTER_Y+144,

			--Feat list
			FeatHeight=80,
			NumFeatsShown=4,
			WheelX={SCREEN_CENTER_X-228,SCREEN_CENTER_X+228},
			WheelY=(SCREEN_CENTER_Y-136), --168
			WheelItem={RankX=-84, NameX=-72, ScoreX=48, DateX=96},
			GradeX={0,0}, --unused
			GradeY=0,
			BannerSizeXY={204,80},
			BannerX={SCREEN_CENTER_X,SCREEN_CENTER_X},
			BannerY=(SCREEN_CENTER_Y-184),
			BannerFrameX={SCREEN_CENTER_X-140,SCREEN_CENTER_X+140},
			BannerFrameY=(SCREEN_CENTER_Y-184),
			DifficultyIconX={SCREEN_CENTER_X-368,SCREEN_CENTER_X+368},
			DifficultyIconY=(SCREEN_CENTER_Y-184),
			DifficultyMeterX={SCREEN_CENTER_X-368,SCREEN_CENTER_X+368},
			DifficultyMeterY=(SCREEN_CENTER_Y-184),
			ScoreX={SCREEN_CENTER_X-228,SCREEN_CENTER_X+228},
			ScoreY=(SCREEN_CENTER_Y-212),
		},
		Ending={
			MenuTimer=45,
			RemoveUSBX={SCREEN_CENTER_X-240,SCREEN_CENTER_X+240},
			RemoveUSBY=SCREEN_CENTER_Y+176,
			GameOverBoxX={SCREEN_CENTER_X-256,SCREEN_CENTER_X+256},
			GameOverBoxY=SCREEN_CENTER_Y+168
		},
		Ranking={
			PageXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-8},
			HeadingY=SCREEN_CENTER_Y-184,
			StepsTypeX=SCREEN_CENTER_X-204,
			Rows={
				TitleX=-204,
				ColsLeft=8,
				ColsRight=308,
				RowHeight=64
			},
			NumEntriesMax=15,
			ScrollSpeed=32/60, --seconds per row
		},
		EditMenu={
			PaneXY={SCREEN_CENTER_X,SCREEN_CENTER_Y},
			HighlightX=SCREEN_CENTER_X+56,
			RowStartY=SCREEN_CENTER_Y-144,
			RowSpacingY=48,
			ArrowsX={SCREEN_CENTER_X-152,SCREEN_CENTER_X+264}, --left, right
			
			LabelsX=SCREEN_CENTER_X-228,
			ValuesX=SCREEN_CENTER_X+60,
			ValueMaxWidth=360,
			
			Steps={
				MeterX=SCREEN_CENTER_X-48,
				ValueX=SCREEN_CENTER_X+144,
			},
			
			EditsUsedXY={SCREEN_CENTER_X,SCREEN_CENTER_Y+192},
			
			Banners={
				Folder={
					Size={0,0},
					XY={SCREEN_CENTER_X,SCREEN_CENTER_Y},
				},
				Song={
					Size={0,0},
					XY={SCREEN_CENTER_X+54,SCREEN_CENTER_Y+24},
				}
			},
		},
		Edit={
			InputTipsXY={SCREEN_LEFT+4,SCREEN_CENTER_Y}, --left
			InfoXY={SCREEN_RIGHT-160,SCREEN_CENTER_Y}, --right
			PlayRecordHelpXY={SCREEN_CENTER_X,SCREEN_BOTTOM-64},
		},
		TextEntry={
			QuestionXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-160},
			AnswerBoxXY={0,SCREEN_CENTER_Y},
			AnswerXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-96},
		},
		Prompt={
			QuestionXY={SCREEN_CENTER_X,SCREEN_CENTER_Y-32},
			Button={
				X={
					 SCREEN_CENTER_X,
					{SCREEN_CENTER_X-96,SCREEN_CENTER_X+96},
					{SCREEN_CENTER_X-192,SCREEN_CENTER_X,SCREEN_CENTER_X+192}
				},
				Y=SCREEN_CENTER_Y+112
			}
		}
	}
