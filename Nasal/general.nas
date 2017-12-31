#Parking/emerg Brake interpolation
setlistener("/controls/gear/brake-parking", func(v) {
  if(v.getValue()){
    interpolate("/controls/gear/brake-parking-position", 1, 0.5);
  }else{
    interpolate("/controls/gear/brake-parking-position", 0, 0.5);
  }
});

#Throttle lock interpol
setlistener("/controls/engines/throttle-lock", func(v) {
  if(v.getValue()){
    interpolate("/controls/engines/throttle-lock-position", 1, 0.5);
  }else{
    interpolate("/controls/engines/throttle-lock-position", 0, 0.5);
  }
});

#Reverser interpol
setlistener("/controls/engines/engine[0]/reverser", func(v) {
  if(v.getValue()){
    interpolate("/controls/engines/engine[0]/reverser-position", 1, 0.5);
  }else{
    interpolate("/controls/engines/engine[0]/reverser-position", 0, 0.5);
  }
});
setlistener("/controls/engines/engine[1]/reverser", func(v) {
  if(v.getValue()){
    interpolate("/controls/engines/engine[1]/reverser-position", 1, 0.5);
  }else{
    interpolate("/controls/engines/engine[1]/reverser-position", 0, 0.5);
  }
});

setlistener("/sim/signals/fdm-initialized", func {
	var ttw = "";
    var min_et = 0;
    var hr_et = 0;
    settimer(update_loop, 5);
    print("General Systems loaded.");
});

#General loop
var update_loop = func{
    ttw = "--:--";
    min_et = 0;
    hr_et = 0;
    if (getprop("autopilot/route-manager/active") != 0) {
		min_et = getprop("autopilot/route-manager/ete");
		setprop("autopilot/internal/nav-type","FMS");
		setprop("autopilot/internal/nav-distance",getprop("instrumentation/gps/wp/wp[1]/distance-nm"));
		setprop("autopilot/internal/nav-id",getprop("instrumentation/gps/wp/wp[1]/ID"));
	} else {
		min_et = int(getprop("instrumentation/dme/indicated-time-min"));
		setprop("autopilot/internal/nav-type","VOR/LOC");
		setprop("autopilot/internal/nav-distance",getprop("instrumentation/dme/indicated-distance-nm"));
		if (getprop("instrumentation/nav[0]/nav-id") != nil) {
			setprop("autopilot/internal/nav-id",getprop("instrumentation/nav[0]/nav-id"));		
		} else {
			setprop("autopilot/internal/nav-id","NONE");
		}
	}
    if(min_et > 60){
		tmphr = (min_et*0.016666);
		hr_et = int(tmphr);
		tmpmin = (tmphr-hr_et)*100;
		min_et = int(tmpmin);
	}
	ttw=sprintf("ETE %i:%02i",hr_et,min_et);
	setprop("autopilot/internal/nav-ttw",ttw);


#EPU
if(getprop("/controls/electric/epu-switch")){
setprop("/controls/electric/power-source", -1);
}

var gear_selector = getprop("/controls/gear/gear-down");
var no_smoking_sw = getprop("/controls/cabin/no-smoking-sw");

if(no_smoking_sw or gear_selector)  {
    setprop("/controls/cabin/no-smoking", 1);
}else{
    setprop("/controls/cabin/no-smoking", 0);
}

var gear_pos_front = getprop("/gear/gear[0]/position-norm");
var taxi_light_sw = getprop("/controls/lighting/taxi-light-sw");

if(taxi_light_sw and gear_pos_front==1){
    setprop("/controls/lighting/taxi-light", 1);
 }else{
    setprop("/controls/lighting/taxi-light", 0);
 }


    #landing light for lightmap
    if(getprop("/controls/lighting/landing-light") == 1 and getprop("/controls/electric/battery-switch") == 1){
    setprop("/systems/electrical/outputs/lightmap/landing-light", 1);
    }else{
    setprop("/systems/electrical/outputs/lightmap/landing-light", 0);
    }
    if(getprop("/controls/lighting/landing-light[1]") == 1 and getprop("/controls/electric/battery-switch") == 1){
    setprop("/systems/electrical/outputs/lightmap/landing-light[1]", 1);
    }else{
    setprop("/systems/electrical/outputs/lightmap/landing-light[1]", 0);
    }
    #logo light for lightmap
    if(getprop("/controls/lighting/logo-lights") == 1 and getprop("/systems/electrical/volts") >=15 ){
    setprop("/systems/electrical/outputs/lightmap/logo-light", 1);
    }else{
    setprop("/systems/electrical/outputs/lightmap/logo-light", 0);
    }

    #EPU
    if(getprop("/controls/electric/epu-switch")){
    setprop("/controls/electric/power-source", -1);
    }

    var gear_selector = getprop("/controls/gear/gear-down");
    var no_smoking_sw = getprop("/controls/cabin/no-smoking-sw");

    if(no_smoking_sw or gear_selector)  {
        setprop("/controls/cabin/no-smoking", 1);
    }else{
        setprop("/controls/cabin/no-smoking", 0);
    }

    var gear_pos_front = getprop("/gear/gear[0]/position-norm");
    var taxi_light_sw = getprop("/controls/lighting/taxi-light-sw");

    if(taxi_light_sw and gear_pos_front==1){
        setprop("/controls/lighting/taxi-light", 1);
    }else{
        setprop("/controls/lighting/taxi-light", 0);
    }


settimer(update_loop, 0);
}
