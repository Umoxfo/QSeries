setlistener("/controls/anti-ice/prop-threshold", func(i){
	if(i.getValue()==-2){
		setprop("/controls/anti-ice/prop-left-below", 1);
		setprop("/controls/anti-ice/prop-left-above", 0);
		setprop("/controls/anti-ice/prop-right-below", 0);
		setprop("/controls/anti-ice/prop-right-above", 0);
	}else if(i.getValue()==-1){
		setprop("/controls/anti-ice/prop-left-below", 0);
		setprop("/controls/anti-ice/prop-left-above", 1);
		setprop("/controls/anti-ice/prop-right-below", 0);
		setprop("/controls/anti-ice/prop-right-above", 0);
	}else if(i.getValue()==0){
		setprop("/controls/anti-ice/prop-left-below", 0);
		setprop("/controls/anti-ice/prop-left-above", 0);
		setprop("/controls/anti-ice/prop-right-below", 0);
		setprop("/controls/anti-ice/prop-right-above", 0);
	}else if(i.getValue()==1){
		setprop("/controls/anti-ice/prop-left-below", 0);
		setprop("/controls/anti-ice/prop-left-above", 0);
		setprop("/controls/anti-ice/prop-right-below", 0);
		setprop("/controls/anti-ice/prop-right-above", 1);
	}else if(i.getValue()==2){
		setprop("/controls/anti-ice/prop-left-below", 0);
		setprop("/controls/anti-ice/prop-left-above", 0);
		setprop("/controls/anti-ice/prop-right-below", 1);
		setprop("/controls/anti-ice/prop-right-above", 0);
	}
});

var prop_left_1 = aircraft.light.new( "/systems/anti-ice/prop-left", [10, 60,], "/controls/anti-ice/prop-left-above" );
var prop_left_2 = aircraft.light.new( "/systems/anti-ice/prop-left", [20, 60,], "/controls/anti-ice/prop-left-below" );

var prop_right_1 = aircraft.light.new( "/systems/anti-ice/prop-right", [10, 60,], "/controls/anti-ice/prop-right-above" );
var prop_right_2 = aircraft.light.new( "/systems/anti-ice/prop-right", [20, 60,], "/controls/anti-ice/prop-right-below" );


var elev_horn_loop = func {
	if(getprop("/controls/anti-ice/elev-horn")==1){
		var agl = getprop("/position/gear-agl-ft") or 0;
		var temp = getprop("/environment/temperature-degc") or 0;
		if(agl > 5 and temp < 15){
			setprop("/systems/anti-ice/elev-horn-heated", 1);
		}else{
			setprop("/systems/anti-ice/elev-horn-heated", 0);
		}
			
		settimer(elev_horn_loop, 5);
	}else{
		setprop("/systems/anti-ice/elev-horn-heated", 0);
	}
}

setlistener("/controls/anti-ice/elev-horn", func(i){
	if(i.getValue()==-1){
		setprop("/systems/anti-ice/elev-horn-heated", 1);
	}else if(i.getValue()==0){
		settimer(elev_horn_loop, 1);
	}else{
		setprop("/systems/anti-ice/elev-horn-heated", 0);
	}
});

