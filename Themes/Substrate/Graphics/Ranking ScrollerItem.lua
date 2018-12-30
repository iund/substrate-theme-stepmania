local screenname=lua.GetThreadVariable("LoadingScreen")

local numcols=THEME:GetMetric(screenname,"NumColumns")
local leftcol=THEME:GetMetric(screenname,"ScoreLeftOffsetX")
local rightcol=THEME:GetMetric(screenname,"ScoreRightOffsetX")
local songnamex=THEME:GetMetric(screenname,"ItemSongNameOffsetX")
local spacingx=(rightcol-leftcol)/(numcols-1)

local title
local afcols=Def.ActorFrame{}
local cols={}

for i=1,numcols do
	--score item
	afcols[i]=Def.BitmapText{
		InitCommand=function(s)
			cols[i]=s
			s:x(leftcol+spacingx*(i-1))
			s:diffusecolor(DifficultyColors[
				THEME:GetMetric(screenname,"ColumnDifficulty"..i)])
			s:zoom(0.75)
		end,

		Font=THEME:GetPathF(screenname,"steps score"),
	}
end

return Def.ActorFrame{
	InitCommand=cmd(ztestmode,"writeonfail"),
	Def.Sprite{
		Texture=THEME:GetPathG(screenname,"song frame"),
	},

	--song/course name
	Def.BitmapText{
		Font=THEME:GetPathF(screenname,"song title"),
		InitCommand=cmd(x,songnamex;diffusecolor,unpack(UIColors.RankingEntry)),
		SetMessageCommand=function(s,p)
			s:settext((p.Song or p.Course):GetDisplayFullTitle())
		end
	},

	afcols,

	SetMessageCommand=function(s,p)
		for i,e in next,p.Entries,nil do
			--each entry is either a Steps or a Trail.
			--Get the highscore for it.

			local scores=GetSortedScoresList(nil,(p.Song or p.Course),e)

			cols[tonumber(i)]:settext(
				scores and scores[1] and
					scores[1]:GetName().."\n"..
						FormatPercentScore(scores[1]:GetPercentDP())
				or
					"----\n"..FormatPercentScore(0)
			)

		end
	end
}
