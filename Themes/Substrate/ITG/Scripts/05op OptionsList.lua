--Is there any point trying to make a horse dance

OptionsListMenu=function(pn) return {
	Name="test",Contents={
		{Name="test a", SetStateCommand=function(state) end},
		{Name="test b"},
		{Name="test c"},
		{Name="test d"},
	
	
	
	},
} end

OptionsList={
	--[[
	Content={
					local state=env.StepsListPage
			DiffList[pn].infotext:settext(
				state==1 and "Difficulty"
				or state==2 and "Chart Description"
				or state==3 and (env.MeasureType and ordinal(env.MeasureType) or "").." Streams"
				or (state==6 or state==4 and not UsingUSB(pn)) and "Machine Top Score"
				or state==4 and UsingUSB(pn) and (CurRival[pn] and CurRival[pn].Name or "Rival").."'s Best"
				or state==5 and UsingUSB(pn) and "My Best"
				or ""
			)
		},
	--]]
	
	MenuDefinition={
		TopMenu=function(pn)
			Trace("OptionsList.TopMenu("..pn..")")

			local curmenu=Env()._OptionsListState[pn].MenuStack
			stack.push(curmenu,OptionsListMenu(pn).Contents)
			
			local numchoices=table.getn(curmenu)
			local choices={}
			local states={}
			for i=1,numchoices do choices[i]=curmenu[i].Name states[i]=false end
			return
			{
				Name="", --ignored
				OneChoiceForAllPlayers=false,
				ExportOnChange=true,
				LayoutType="ShowAllInRow", --ignored
				SelectType="SelectNone", --ignored, apparently
	
				Choices=choices,

				LoadSelections=function(r,l,p) local pn=pText[p]
					Trace("OptionsList.TopMenu.LoadSelections("..pn..")")
					return states
				end,

				--ExportOption is meant to run this but it doesn't
				SaveSelections=function(r,l,p) local pn=pText[p]
					Trace("OptionsList.TopMenu.SaveSelections("..pn..")")
				end,
			}
		end,

		Options=function() return "4,selectnone" end,
		Base=function() end,
		Row=function(line) end,

	},
	
--[[

	GetScreen - for submenu name
	ImportOption
	ExportOption
	GetGameCommand
		- for Name
		
		name,ResetOptions - resets player state.
		
	GetIconText - gets assigned to a string and never gets used


RowType.Base=function(name,layout,sel,shared) return {
	Name=Languages[CurLanguage()].Mods.Titles[name] or name,
	OneChoiceForAllPlayers=shared,
	ExportOnChange=true, --ignored
	LayoutType="ShowAllInRow", --ignored
	SelectType="SelectOne" , sel, --SelectOne, SelectMultiple, SelectNone
	Choices={} --strings
	ReloadRowMessages={"message","anothermessage"},

	--ImportOption runs this
	LoadSelections=function(r,l,p) local pn=pText[p]

	end,
 	
 	--ExportOption runs this
 	SaveSelections=function(r,l,p) local pn=pText[p]
 		Trace(sprintf("SaveSelections(%s,{%s},%u","",table.dump(l),p))
 	
 	end,

	Line=ModsMenu.CurLine(),
} end
--]]
	
	State={
		Reset=function(s,pn)
			Trace("OptionsList.Reset("..s:getaux()..")")

			s:aux(pn)
			assert(pn>0)
		
			Env()._OptionsListState=Env()._OptionsListState or {}
			Env()._OptionsListState[pn]={
				CurRow=1,
				MenuStack={}
			}
		
			SetEnv("CurOptionsListPane",pn)
			s:visible(Bool[false])
		end,
		Open=function(s)
			Trace("OptionsList.Tween.On("..s:getaux()..")")
			local pn=s:getaux()

			local dl=DiffList[pn].self
--[[
			dl:stoptweening() dl:linear(0.5) dl:diffusealpha(0)
			s:stoptweening() s:linear(0.5) s:diffusealpha(1)
--]]
			dl:visible(Bool[false])
			s:visible(Bool[true])

			Capture.ActorFrame.ApplyPNToChildren(s,pn)

			Broadcast("OptionsListTweenOnP"..pn)
		end,
		Close=function(s)
			Trace("OptionsList.Tween.Off("..s:getaux()..")")
			local pn=s:getaux()
			local dl=DiffList[pn].self
--[[
			dl:stoptweening() dl:linear(0.5) dl:diffusealpha(1)
			s:stoptweening() s:linear(0.5) s:diffusealpha(0)
--]]
			Env()._OptionsListState[pn]=nil
			
			s:visible(Bool[false])
			dl:visible(Bool[true])
		end,

		AfterPush=function(s)
			Trace("OptionsList.State.AfterPush("..s:getaux()..")")
		end,
	
		AfterPop=function(s)
			Trace("OptionsList.State.AfterPop("..s:getaux()..")")
		end,
		
		AfterSet=function(rowctr) --at end, when menu updated and cursor moved to bottom
--			OptionsList.RowUtil.UpdateAllText(rowctr:getaux())
		end,
	},
	
	RowUtil={
		GetText=function(pn,row)
			return "TEST" --return Env()._OptionsListState[pn].MenuStack[row].Name
		end,

		GetUnderline=function(pn,row)
			--todo
			--return Env()._OptionsListState[pn].Underlines[row]
		end,
		
		SetState=function(pn,row,state)
--			local curitem=Env()._OptionsListState[pn].MenuStack[row]
--			if curitem and curitem.SetStateCommand then curitem.SetStateCommand(state) end
		end,
		
		UpdateAllText=function(pn)
			DumpTable(Env()._OptionsListState[pn])
			Trace("OptionsList.RowUtil.UpdateAllText("..pn..")")
			for row,text in next,Env()._OptionsListState[pn].Texts,nil do
				text:settext(OptionsList.RowUtil.GetText(pn,row))
			end
		end
	},

	Input={
		Left=function(s)
			Trace("OptionsList.State.Left("..s:getaux()..")")
		end,
		Right=function(s)
			Trace("OptionsList.State.Right("..s:getaux()..")")
		end,
		QuickLeft=function(s)
			Trace("OptionsList.State.QuickLeft("..s:getaux()..")")
		end,
		QuickRight=function(s)
			Trace("OptionsList.State.QuickRight("..s:getaux()..")")
		end,
		Start=function(s)
			Trace("OptionsList.State.Start("..s:getaux()..")")
			OptionsList.State.AfterSet(s)
		end,
	},
	
	Actors={
		Row={
			Load=function(s) --need to run this every time due to RemoveAllChildren being used
				local pn=s:getaux()
				assert(pn>0)

				Trace("OptionsList.Actors.Row.Load("..s:getaux()..")")

				local c=Capture.ActorFrame.GetChildren(s).children

				local underlines={}
				local texts={}

				if table.getn(c)>0 then
					for i=1,math.floor(table.getn(c)/2) do
						assert(not IsTable(c[i*2-1])) --just checking
						underlines[i]=c[i*2-1]
						texts[i]=c[i*2]
					end

					local exittext=c[table.getn(c)]
				
					for i,text in next,texts,nil do
						text:zoom(.75) text:shadowlength(0)
						text:aux((pn*2-3)*i)
					end
					
					for i,underline in next,underlines,nil do
						underline:aux((pn*2-3)*i)
					end

					exittext:zoom(.75) exittext:shadowlength(0)

					Env()._OptionsListState[pn]={
						Underlines=underlines,
						Texts=texts,
						ExitText=exittext,
						CurRow=Env()._OptionsListState[pn].CurRow --hacky but whatever
					}

					OptionsList.RowUtil.UpdateAllText(pn)
				end
			end,

			Tween={
				-- Runs after Pop() and Push() - runs last after stuff gets loaded
			
				-- Forward = entering row submenu, Backward = exiting row submenu
				-- Out = prev menu, In = new menu (ie. menus to be tweened Out or In)

				OutForward=function(s)
					Trace("OptionsList.Actors.Row.TweenOutForward("..s:getaux()..")")
				end,
				OutBackward=function(s)
					Trace("OptionsList.Actors.Row.TweenOutBackward("..s:getaux()..")")
				end,
				InForward=function(s)
					Trace("OptionsList.Actors.Row.TweenInForward("..s:getaux()..")")
				end,
				InBackward=function(s)
					Trace("OptionsList.Actors.Row.TweenInBackward("..s:getaux()..")")
				end,
			}
		},
		Underline={ --AutoActor
			Show=function(s)
				s:visible(Bool[false])
				local aux=s:getaux()
				local pn=aux>0 and 2 or 1
				OptionsList.RowUtil.SetState(pn,math.abs(aux),true)
			 end,
			Hide=function(s)
				s:visible(Bool[false])
				local aux=s:getaux()
				local pn=aux>0 and 2 or 1
				OptionsList.RowUtil.SetState(pn,math.abs(aux),false)
			 end,
			SetOneRow=function(s)
				local pn=GetEnv("CurOptionsListPane")
				--[[
				table.insert(Env()._OptionsListState[pn].Underlines,s)
				local line=table.getn(Env()._OptionsListState[pn].Underlines)
				s:aux((pn*2-3)*line)
				--]]
				Trace("OptionsList.Actors.Underline.SetOneRow("..s:getaux()..")")
			 end,
			SetTwoRows=function(s)
				Trace("OptionsList.Actors.Underline.SetTwoRows("..s:getaux()..")")
			 end,
		
		},
		Cursor={
		
			--Run immediately before setting XY.
			--After XY is set, OptionsList(Left/Right)Pn message is broadcasted.
			PositionOneRow=function(s)
				s:stoptweening() s:decelerate(0.15)
				
				Trace("OptionsList.Actors.Cursor.PositionOneRow("..s:getaux()..")")
			 end,
			PositionTwoRows=function(s)
				Trace("OptionsList.Actors.Cursor.PositionTwoRows("..s:getaux()..")")
			 end,
		
		},
	},
}
