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
    settimer(update_loop, 5);
    print("General Systems loaded.");
});

#General loop
var update_loop = func{

#Throttle Lock
var reverseL=getprop("/controls/engines/engine[0]/reverser");
var reverseR=getprop("/controls/engines/engine[1]/reverser");
var thrLock=getprop("/controls/engines/throttle-lock");
var throttleL=getprop("/controls/engines/engine[0]/throttle");
var throttleR=getprop("/controls/engines/engine[1]/throttle");

if(thrLock == 0 or reverseL) {
    setprop("/controls/engines/engine/throttle-int", throttleL );
}else if(throttleL <= 0.3){
    setprop("/controls/engines/engine/throttle-int", throttleL );
}else{
    setprop("/controls/engines/engine/throttle-int", 0.3 );
}

if(thrLock == 0 or reverseR) {
    setprop("/controls/engines/engine[1]/throttle-int", throttleR );
}else if(throttleR <= 0.3){
    setprop("/controls/engines/engine[1]/throttle-int", throttleR );
}else{
    setprop("/controls/engines/engine[1]/throttle-int", 0.3 );
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
#hide ALS landing light from the outside
if(getprop("/sim/current-view/internal") == 1 and getprop("/systems/electrical/volts") >= 15 ){
setprop("/sim/rendering/als-secondary-lights/use-landing-light", getprop("/controls/lighting/landing-lights"));
}else{
setprop("/sim/rendering/als-secondary-lights/use-landing-light", 0);
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