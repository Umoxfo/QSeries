setlistener("/sim/signals/fdm-initialized", func{
	settimer(update_transfer, 1);
	print("Fuel System initialized.");	
});

var update_transfer = func{
	var transfer=getprop("/controls/fuel/transfer"); #-1=transfer left 0=off 1=transfer right
	if(transfer==(-1)){
		setprop("/consumables/fuel/tank/level-lbs", getprop("/consumables/fuel/tank/level-lbs")+5);
		setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/consumables/fuel/tank[1]/level-lbs")-5);
	}else if(transfer==1){
		setprop("/consumables/fuel/tank/level-lbs", getprop("/consumables/fuel/tank/level-lbs")-5);
		setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/consumables/fuel/tank[1]/level-lbs")+5);
	}	
	settimer(update_transfer, 1);
}