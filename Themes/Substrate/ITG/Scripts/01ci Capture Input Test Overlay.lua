InputTest={
	Mappings={
		panels={
			--R, L, D, U
			{29,30,31,32},
			{13,14,15,16}
		},
--[[
		buttons={
			{25,26,27,28}, --MenuRightP1, MenuLeftP1, SelectP1, StartP1
			{9,10,11,12} --MenuRightP2, MenuLeftP2, SelectP2, StartP2
		},
--]]
		servicebuttons={
			18,22,23,	--Test, Service, Coin
		},
	},

	Init=function(tab)
		for pn=1,2 do
			tab[pn]={}
			for panel=1,4 do
				tab[pn][panel]={}
				for sensor=1,4 do
					tab[pn][panel][sensor]=false
				end
			end
		end
		tab[3]={} --for service inputs
	end,

	--[[
		MK6_GetSensors()
		returns table with inputs
			(32 inputs)

			input[sensor][input]
				range: sensor 1,4  input 1,32

			sensor order: R, L, D, U
			for panel buttons: each "sensor" will read the same
	--]]

	Poll=function(tab)
		local m=InputTest.Mappings

		local raw=MK6_GetSensors()
	
		for pn=1,2 do
			--panels
			for panel=1,4 do
				for sensor=1,4 do
					tab[pn][panel][sensor]=raw[sensor][m.panels[pn][panel]]
				end
			end

			--buttons
			--for button,input in next,m.buttons[pn],nil do tab[pn][button][1]=raw[4][input] end
		end

		--service inputs
		for button,input in next,m.servicebuttons,nil do tab[3][button]=raw[4][input] end
	end,
	
	Update={
		MK6Platform=function(pn,panels,tab)
			for panel,sensors in next,tab[pn],nil do
				for sensor,state in next,sensors,nil do
					panels[panel][sensor]:visible(Bool[state])
				end
			end
		end,
		MK6ServiceButtons=function(pn,buttons,tab)
			for b,state in next,tab[3],nil do
				buttons[b]:visible(Bool[state])
			end
		end,
	},
	
	Capture={
		MK6Platform=function(s)
			local r=Capture.ActorFrame.GetChildren(s)
			local pad=r.children[1].children[1]
			local panels={}
			for pi=1,4 do
				panels[pi]={}
				local sr=r.children[pi+1].children[1]
				for si=1,4 do
					panels[pi][si]=sr.children[si].children[1]
				end
			end
			return panels
		end,
		MK6ServiceButtons=function(s)
			local r=Capture.ActorFrame.GetChildren(s)
			highlights={}
			for hi=1,3 do
				highlights[hi]=r.children[hi*2-1].children[1]
			end	
			return highlights	
		end,
	}
}
