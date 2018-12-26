t=Def.ActorFrame {}
t[#t+1]=LoadActor("padding") .. {
	OnCommand=cmd(x,-320;horizalign,right;vertalign,top;zoomtowidth,SCREEN_CENTER_X-320),
}
t[#t+1]=LoadActor("frame") .. {
	OnCommand=cmd(horizalign,right;x,-192;vertalign,top;y,0;animate,0;setstate,0),
}
t[#t+1]=LoadActor("frame") .. {
	OnCommand=cmd(horizalign,right;x,-64;vertalign,top;y,0;animate,0;setstate,1),
}
t[#t+1]=LoadActor("frame") .. {
	OnCommand=cmd(horizalign,center;x,0;vertalign,top;y,0;animate,0;setstate,2),
}
t[#t+1]=LoadActor("frame") .. {
	OnCommand=cmd(texturewrapping,1;horizalign,left;x,64;vertalign,top;y,0;animate,0;setstate,3),
}
t[#t+1]=LoadActor("frame") .. {
	OnCommand=cmd(horizalign,left;x,192;vertalign,top;y,0;animate,0;setstate,4),
}
t[#t+1]=LoadActor("padding") .. {
	OnCommand=cmd(x,320;horizalign,left;vertalign,top;zoomtowidth,SCREEN_CENTER_X-320),
}
return t
