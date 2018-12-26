Screens={
	Common={
		Init=function(s)
			Env().TempLuaEffectList={}
			s:effectclock("music")
			System.MemoryCardState={}
		end,
		On=function(s)
		end,
		FirstUpdate=function(s)
		
		end,
		Off=function(s)
		end,
	},

	GlobalOverlay={
		--Todo
	
	},

	SharedBGAParticles={
		--background
		Init=function(s)

		end,
		On=function(r)
			TempBGVels={}
			local root=Capture.ActorFrame.GetChildren(r)
			--I'm using this instead of using the particle layer type to do everything for me, because in SM5 it only works with compatibility mode on.
			r:effectclock("music") --'music' wraps
			LuaEffect(r,"Update")
			for i,c in next,root.children,nil do
				--3.95 puts each BGAnimation Layer into its own ActorScroller (for whatever reason).

				local container=SM_VERSION>3.95 and c or c.self
				local sprite=SM_VERSION>3.95 and c or c.children[1]
				--local container=SM_VERSION>3.95 and c.self or c.children[1].self
				--local model=SM_VERSION>3.95 and c.children[1] or c.children[1].children[1].children[1]
				--local sprite=SM_VERSION>3.95 and c.children[2] or c.children[1].children[2].children[1]

				local zoom=randomrange(0.5,2)

				local basew=sprite:GetWidth() --64
				local baseh=sprite:GetWidth() --64
				local w=basew*zoom
				local h=baseh*zoom

				sprite:zoomto(basew,baseh) sprite:blend("add")
				sprite:horizalign("center")
				sprite:vertalign("middle")

				local colorval=function(color) return math.mod(math.floor(i/4),3)==color and 0.1 or 0.05 end
				sprite:diffuse(colorval(0),colorval(1),colorval(2),1)

				local x=randomrange(-w/2,SCREEN_WIDTH+w/2)
				local y=randomrange(-h/2,SCREEN_HEIGHT+h/2)

				container:rotationz(90*math.mod(i,4))
				container:zoom(zoom)
				container:finishtweening()

				TempBGVels[i]={
					self=container,
					x=x, y=y,
					xv=randomrange(-100,100), yv=randomrange(-20,-100),
					w=w/2, h=h/2,
				}
			end
		end,
		Update=function(r) --manual particle layer update (this runs on every frame so be efficient!)
			local sw=SCREEN_WIDTH
			local sh=SCREEN_HEIGHT
			local w=wrap
			local d=clamp(r:GetEffectDelta(),0,1/30) --(effectclock music needs the delta clamped)
			--local d=r:GetEffectDelta()
			for _,o in next,TempBGVels,nil do
				local s=o.self
				o.x=w(o.x+(d*o.xv),-o.w,sw+o.w)
				o.y=w(o.y+(d*o.yv),-o.h,sh+o.h)
				s:x(o.x) s:y(o.y)
			end
		end,
		Coin=function(r) --Coin insert animation
			for _,obj in next,TempBGVels,nil do local s=obj.self s:finishtweening() local z=s:GetZoom() s:zoom(z*1.75) s:decelerate(0.2) s:zoom(z) end
		end,
		Off=function(r) end,
	},
	Start=function() --Game boot:
		IgnoreWindow("FRAME_DIMENSIONS_WARNING") --Suppress "sprite dimensions are not even, herp a derp derp" on a theme with assets sized for 1920x1080
		--IgnoreWindow("MissingThemeElement") --don't want this in stable/final

		--The game rounds this down. Fix it
		SCREEN_WIDTH=(math.round(GetPref("DisplayAspectRatio")*900)/900)*SCREEN_HEIGHT
		SCREEN_CENTER_X=SCREEN_WIDTH/2
		SCREEN_RIGHT=SCREEN_WIDTH
		
		for p,v in next,SysProfileTemplate,nil do GetSysProfile()[p]=GetSysProfile()[p]~=nil and GetSysProfile()[p] or GetSysProfile()[p]==nil and v end

		if not GetSysConfig() then GetSysProfile().Options={} end
		for p,v in next,DefaultSettings,nil do GetSysConfig()[p]=GetSysConfig()[p]~=nil and GetSysConfig()[p] or GetSysConfig()[p]==nil and v end

		if not GetSysProfile().UUID then GetSysProfile().UUID=uuid() PROFILEMAN:SaveMachineProfile() end --generate a machine UUID

		CacheSongPtrs()
		
		CacheCourseData()

		--[[
		if Steps.GetSMNoteData then
		UpdateStreamCache()
		else]]if GetPath("../Scripts/StreamCache.lua",EC_GRAPHICS,true) then
			GetSysProfile().StreamCache=StreamCache or GetSysProfile().StreamCache or {}
		end

		--if Steps.GetRadarValues then CacheRadarValues() end
		if Steps.GetFilename and RageFileUtil.CreateRageFile then CacheStreams() end

--		Screens.PlayStats.GetMostPlayedPacks()
--		Screens.PlayStats.GetLeastPlayedPacks()


	end
}
