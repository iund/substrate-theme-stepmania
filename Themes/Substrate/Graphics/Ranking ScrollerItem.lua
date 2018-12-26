--TODO: Deduplicate stuff from here and B/Ranking underlay

local screenname="Ranking" --TODO: GetScreen():GetName() doesn't work

local numcols=THEME:GetMetric(screenname,"NumColumns")

local leftcol,rightcol=8,308
local spacingx=(rightcol-leftcol)/(numcols-1)

local title
local afcols=Def.ActorFrame{}
local cols={}

for i=1,numcols do
	afcols[i]=Def.BitmapText{
		InitCommand=function(s)
			cols[i]=s
			s:x(leftcol+spacingx*(i-1))
			s:diffusecolor(DifficultyColors[
				THEME:GetMetric(screenname,
				"ColumnDifficulty"..i)])
		end,
		OnCommand=cmd(diffusecolor,
			DifficultyColors[
				THEME:GetMetric(GetScreen():GetName(),
					"ColumnDifficulty"..i)]),

		Font=THEME:GetPathF(screenname,"steps score"),
	}
end

return Def.ActorFrame{
	InitCommand=cmd(ztestmode,"writeonfail"),
	Def.Sprite{
		Texture=THEME:GetPathG("Ranking","song frame"),
		--InitCommand=cmd(diffusecolor,unpack(UIColors.RankingEntry))
	},

	--song/course name
	Def.BitmapText{
		--Font=THEME:GetPathF(screenname,"song title"),
		Font="Ranking song title",
		InitCommand=function(s)
			title=s
			s:x(-204)
		end,
		Text="derp"
	},

	afcols,

	SetMessageCommand=function(s,p)
		title:settext(
			(p.Song or p.Course):GetDisplayFullTitle()
		)
	
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
