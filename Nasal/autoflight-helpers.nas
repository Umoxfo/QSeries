#This connects the aircraft to it-autoflight so that hasn't to be changed and the ability to update persists
setlistener("/it-autoflight/settings/nav-source", func{
	var nav_source=getprop("/it-autoflight/settings/nav-source") or "";
	if(nav_source=="NAV2"){
		setprop("/it-autoflight/settings/use-nav2-radio", 1);
	}else{
		setprop("/it-autoflight/settings/use-nav2-radio", 0);
	}
});