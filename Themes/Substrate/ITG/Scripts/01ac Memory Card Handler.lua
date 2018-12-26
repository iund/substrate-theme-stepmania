--Poll memory card states, and tell Messageman when the state changes.


-- NOTE: All this effort and it doesn't bloody work

MemoryCardDisplay={
	Init=function(s)
	end,
	On=function(s,pn)
		local mcd=Capture.ActorFrame.GetChildren(s).children
		for i,icon in next,mcd,nil do
			icon:additiveblend(1) icon:animate(Bool[false]) icon:draworder(DRAW_ORDER_TRANSITIONS+1)
			icon:setstate((pn-1)*6+i-1)
			icon:aux((pn*2-3)*i)
--			icon:luaeffect("Update")
		end
	end,
	IconOn=function(s)
		s:additiveblend(1) s:animate(Bool[false]) s:draworder(DRAW_ORDER_TRANSITIONS+1)
	end,
	Poll=function(s)
		local rawid=s:getaux()
		local pn=rawid<0 and 1 or 2
		local state=math.abs(rawid)
		print("MCS.Poll() pn="..pn.." state="..state)
		if System.MemoryCardState[pn]~=state then --state changed
			System.MemoryCardState[pn]=state
			
			--Two messsages get broadcast, the first is for convenience sake;
			--example1: MemoryCardDisplayP1MemoryCardStateChangedP1MessageCommand=%function(s) local state=Env().MemoryCardState[1] end
			--example2: CardCheckingP1MessageCommand=%function(s) end
			Broadcast("MemoryCardStateChangedP"..pn)
			if state==5 then
				--3.95 and oITG already send CardRemoved messages, but only if card was present.
			elseif state==1 and not OPENITG then --oITG already sends this
				Broadcast("CardReadyP"..pn)
				
				--DEBUG:
				ScreenMessage("CardReadyP"..pn)
			else
				local names={"Ready","Checking","TooLate","Error","Removed","NotPresent"}
				Broadcast("Card"..names[state].."P"..pn)
				
				--DEBUG:
				ScreenMessage("Card"..names[state].."P"..pn)
			end
		end
	end,
	Off=function(s,pn) --do not unload this table
		--System.MemoryCardState={}
	end
}
