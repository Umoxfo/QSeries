# Bombardier QSeries 400 Electrical System
# Benedikt Wolf (D-ECHO) 2019
# Reference(s): http://www.smartcockpit.com/docs/Q400-Electrical.pdf

#based on
####  turboprop engine electrical system    #### 
####    Syd Adams    ####

var ammeter_ave = 0.0;
var outPut = "systems/electrical/outputs/";
var breakers = "controls/electric/circuit-breakers/";
var auxbattery_volts = props.globals.getNode("systems/electrical/aux-batt-volts",1);
var mainbattery_volts = props.globals.getNode("systems/electrical/main-batt-volts",1);
var stbybattery_volts = props.globals.getNode("systems/electrical/stby-batt-volts",1);
var lmainbus_volts = props.globals.getNode("/systems/electrical/DC/lmain-bus/volts",1);
var rmainbus_volts = props.globals.getNode("/systems/electrical/DC/rmain-bus/volts",1);
var lessentialbus_volts = props.globals.getNode("/systems/electrical/DC/lessential-bus/volts",1);
var ressentialbus_volts = props.globals.getNode("/systems/electrical/DC/ressential-bus/volts",1);
var lsecondarybus_volts = props.globals.getNode("/systems/electrical/DC/lsecondary-bus/volts",1);
var rsecondarybus_volts = props.globals.getNode("/systems/electrical/DC/rsecondary-bus/volts",1);

var dc_ext_flag = props.globals.getNode("/systems/electrical/DC/external-power",1);
var dc_ext_flag = props.globals.initNode("/systems/electrical/DC/external-power",0,"BOOL");
var ac_ext_flag = props.globals.getNode("/systems/electrical/AC/external-power",1);
var ac_ext_flag = props.globals.initNode("/systems/electrical/AC/external-power",0,"BOOL");

var lvarfreqbus_volts = props.globals.getNode("/systems/electrical/AC/lvarfreq-bus/volts",1);
var rvarfreqbus_volts = props.globals.getNode("/systems/electrical/AC/rvarfreq-bus/volts",1);
var lff1bus_volts = props.globals.getNode("/systems/electrical/AC/lff1-bus/volts",1);
var lff2bus_volts = props.globals.getNode("/systems/electrical/AC/lff2-bus/volts",1);
var rff1bus_volts = props.globals.getNode("/systems/electrical/AC/rff1-bus/volts",1);
var rff2bus_volts = props.globals.getNode("/systems/electrical/AC/rff2-bus/volts",1);

var lessential_lmain = props.globals.getNode(breakers~"lessential-lmain",1);
var lessential_auxbatt = props.globals.getNode(breakers~"lessential-auxbatt",1);

var lmain_lessential = props.globals.getNode(breakers~"lmain-lessential",1);

var Amps = props.globals.getNode("/systems/electrical/amps",1);
var EXT  = props.globals.getNode("/controls/electric/dc-external-power",1);
var AC_EXT  = props.globals.getNode("/controls/electric/ac-external-power",1);
var APU  = props.globals.getNode("/engines/APU/plugged",1);
var battery_master = props.globals.getNode("/controls/electric/battery-master-switch",1);
var aux_battery_sw = props.globals.getNode("/controls/electric/aux-battery",1);
var main_battery_sw = props.globals.getNode("/controls/electric/main-battery",1);
var autostart = props.globals.getNode("/controls/electric/autostart", 1);

var dcindbv = props.globals.getNode("systems/electrical/DC/indicated-bus-volts", 1);
var dcindbv = props.globals.initNode("systems/electrical/DC/indicated-bus-volts", 0.0, "DOUBLE");

var lmain_serviceable = props.globals.getNode("/systems/electrical/DC/lmain-bus/serviceable", 1);
var rmain_serviceable = props.globals.getNode("/systems/electrical/DC/rmain-bus/serviceable", 1);
var lessential_serviceable = props.globals.getNode("/systems/electrical/DC/lessential-bus/serviceable", 1);
var ressential_serviceable = props.globals.getNode("/systems/electrical/DC/ressential-bus/serviceable", 1);
var lsecondary_serviceable = props.globals.getNode("/systems/electrical/DC/lsecondary-bus/serviceable", 1);
var rsecondary_serviceable = props.globals.getNode("/systems/electrical/DC/rsecondary-bus/serviceable", 1);

var lvarfreq_serviceable = props.globals.getNode("/systems/electrical/AC/lvarfreq-bus/serviceable", 1);
var rvarfreq_serviceable = props.globals.getNode("/systems/electrical/AC/rvarfreq-bus/serviceable", 1);
var lff1_serviceable = props.globals.getNode("/systems/electrical/AC/lff1-bus/serviceable", 1);
var lff2_serviceable = props.globals.getNode("/systems/electrical/AC/lff2-bus/serviceable", 1);
var rff1_serviceable = props.globals.getNode("/systems/electrical/AC/rff1-bus/serviceable", 1);
var rff2_serviceable = props.globals.getNode("/systems/electrical/AC/rff2-bus/serviceable", 1);


var second = props.globals.getNode("sim/time/delta-sec");


var lmain_cb_list=[];
var lmain_switch_list=[];
var lmain_output_list=[];
var rmain_cb_list=[];
var rmain_switch_list=[];
var rmain_output_list=[];
var lessential_cb_list=[];
var lessential_switch_list=[];
var lessential_output_list=[];
var ressential_cb_list=[];
var ressential_switch_list=[];
var ressential_output_list=[];
var lsecondary_cb_list=[];
var lsecondary_switch_list=[];
var lsecondary_output_list=[];
var rsecondary_cb_list=[];
var rsecondary_switch_list=[];
var rsecondary_output_list=[];

var lvarfreq_cb_list=[];
var lvarfreq_switch_list=[];
var lvarfreq_output_list=[];
var rvarfreq_cb_list=[];
var rvarfreq_switch_list=[];
var rvarfreq_output_list=[];
var lff1_cb_list=[];
var lff1_switch_list=[];
var lff1_output_list=[];
var lff2_cb_list=[];
var lff2_switch_list=[];
var lff2_output_list=[];
var rff1_cb_list=[];
var rff1_switch_list=[];
var rff1_output_list=[];
var rff2_cb_list=[];
var rff2_switch_list=[];
var rff2_output_list=[];

var lmain_serv_list=[];
var lmain_servout_list=[];
var rmain_serv_list=[];
var rmain_servout_list=[];
var lessential_serv_list=[];
var lessential_servout_list=[];
var ressential_serv_list=[];
var ressential_servout_list=[];
var lsecondary_serv_list=[];
var lsecondary_servout_list=[];
var rsecondary_serv_list=[];
var rsecondary_servout_list=[];

var lff1_serv_list=[];
var lff1_servout_list=[];
var lff2_serv_list=[];
var lff2_servout_list=[];
var rff1_serv_list=[];
var rff1_servout_list=[];
var rff2_serv_list=[];
var rff2_servout_list=[];

var increasing_counter0 = 0.0;
var increasing_counter1 = 0.0;
var fuel_rich0 = 0.0;
var fuel_rich1 = 0.0;

# Initial custom internal value #



#strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
#aircraft.light.new("controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);
#beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
#aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);

var navLight = aircraft.light.new("/sim/model/lights/nav-lights", [0], "/controls/lighting/nav-lights");
var landingLightFLR = aircraft.light.new("/sim/model/lights/landing-light-flr", [0], "/controls/lighting/landing-light-flr");
var landingLightAPP = aircraft.light.new("/sim/model/lights/landing-light-flr", [0], "/controls/lighting/landing-light-app");
var taxiLight = aircraft.light.new("/sim/model/lights/taxi-light", [0], "/controls/lighting/taxi-light");
var strobeLight = aircraft.light.new("/sim/model/lights/strobe", [0.08, 2.5], "/controls/lighting/strobe-lights");
var beaconLight = aircraft.light.new("/sim/model/lights/beacon", [0.08, 0.08, 0.08, 2.5], "/controls/lighting/beacon");

setprop("/systems/electrical/main_battery/serviceable", 1);
setprop("/systems/electrical/aux_battery/serviceable", 1);


#var battery = Battery.new(switch-prop,volts,amps,amp_hours,charge_percent,charge_amps);
Battery = {
    new : func(swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(1);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp; 
            m.charge_amps = cha;
    return m;
    },
    apply_load : func(load,dt) {
        if(me.switch.getValue()){
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else return 0;
    },

    get_output_volts : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_volts * factor;
            return output;
        }else return 0;
    },

    get_output_amps : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_amps * factor;
            return output;
        }else return 0;
    }
};

# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(0);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        return m;
    },

    apply_load : func(load) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load * factor);
            if(gout>1)gout=1;
        }else{
            gout=0;
        }
        if(cur_amp > gout)me.meter.setValue(cur_amp - 0.01);
        if(cur_amp < gout)me.meter.setValue(cur_amp + 0.01);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        if (out > 1) return out;
        return 0;
    },

    get_output_amps : func {
        var ampout =0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    }
};

var main_battery = Battery.new("/systems/electrical/main_battery/serviceable",24,30,40,1.0,7.0);
var aux_battery = Battery.new("/systems/electrical/aux_battery/serviceable",24,30,40,1.0,7.0);
var stby_battery = Battery.new("/systems/electrical/stby_battery/serviceable",24,30,40,1.0,7.0);
var dcgen1 = Alternator.new(0,"controls/electric/engine[0]/dc-generator","/engines/engine[0]/n2",30.0,28.0,60.0);
var dcgen2 = Alternator.new(1,"controls/electric/engine[1]/dc-generator","/engines/engine[1]/n2",30.0,28.0,60.0);
var acgen1 = Alternator.new(2,"controls/electric/engine[0]/ac-generator","/engines/engine[0]/n2",30.0,115.0,60.0);
var acgen2 = Alternator.new(3,"controls/electric/engine[1]/ac-generator","/engines/engine[1]/n2",30.0,115.0,60.0);
var apu_gen = Alternator.new(4,"controls/APU/generator","/engines/APU/rpm",50.0,28.0,60.0);

#####################################
setlistener("/sim/signals/fdm-initialized", func {
    mainbattery_volts.setDoubleValue(0);
    auxbattery_volts.setDoubleValue(0);
    init_switches();
    settimer(update_electrical, 5);
    settimer(general_loop, 5);
    print("Electrical System ... ok");

});

init_switches = func() {
	lmain_serviceable.setBoolValue(1);
	rmain_serviceable.setBoolValue(1);
	lessential_serviceable.setBoolValue(1);
	ressential_serviceable.setBoolValue(1);
	lsecondary_serviceable.setBoolValue(1);
	rsecondary_serviceable.setBoolValue(1);
	
	lvarfreq_serviceable.setBoolValue(1);
	rvarfreq_serviceable.setBoolValue(1);
	lff1_serviceable.setBoolValue(1);
	rff1_serviceable.setBoolValue(1);
	lff2_serviceable.setBoolValue(1);
	rff2_serviceable.setBoolValue(1);
	
	setprop("/controls/electric/dc-bus-select", 0);
	
	lessential_lmain.setBoolValue(1);
	lessential_auxbatt.setBoolValue(1);
	
	lmain_lessential.setBoolValue(1);
	
	
    var tprop=props.globals.getNode("controls/electric/ammeter-switch",1);
    tprop.setBoolValue(1);
    tprop=props.globals.getNode("controls/cabin/fan",1);
    tprop.setBoolValue(0);
    tprop=props.globals.getNode("controls/cabin/heat",1);
    tprop.setBoolValue(0);
    tprop=props.globals.getNode("controls/electric/dc-external-power",1);
    tprop.setBoolValue(0);

    setprop("controls/lighting/instruments-norm",0.8);
    setprop("controls/lighting/engines-norm",0.8);
    setprop("controls/lighting/efis-norm",0.8);
    setprop("controls/lighting/panel-norm",0.8);
    setprop("controls/lighting/panel/plt-flt", 0);
    setprop("controls/lighting/panel/cop-flt", 0);
    setprop("controls/lighting/panel/engine", 0);
    setprop("controls/lighting/panel/center", 0);
    setprop("controls/lighting/panel/overhead", 0);
    setprop("controls/lighting/panel/glareshield", 0);

    
    
    append(lessential_cb_list,"pitot-heat[0]");
    append(lessential_switch_list,"controls/anti-ice/pitot-heat[0]");
    append(lessential_output_list,"pitot-heat[0]");
    append(lessential_cb_list,"pass-warn");
    append(lessential_switch_list,"controls/cabin/seatbelts");
    append(lessential_output_list,"pass-warn");
    
    append(ressential_cb_list,"posn");
    append(ressential_switch_list,"controls/lighting/nav-lights");
    append(ressential_output_list,"nav-lights");
    
    append(lmain_cb_list,"landing-light-app");
    append(lmain_switch_list,"controls/lighting/landing-light-app");
    append(lmain_output_list,"landing-light-app");
    append(lmain_cb_list,"logo-lights");
    append(lmain_switch_list,"controls/lighting/logo-lights");
    append(lmain_output_list,"logo-lights");
    append(lmain_cb_list,"taxi-light");
    append(lmain_switch_list,"controls/lighting/taxi-light");
    append(lmain_output_list,"taxi-light");
    append(lmain_cb_list,"overhead");
    append(lmain_switch_list,"controls/lighting/panel/overhead");
    append(lmain_output_list,"overhead");
    append(lmain_cb_list,"glareshield");
    append(lmain_switch_list,"controls/lighting/panel/glareshield");
    append(lmain_output_list,"glareshield");
    append(lmain_cb_list,"plt-flt");
    append(lmain_switch_list,"controls/lighting/panel/plt-flt");
    append(lmain_output_list,"pltflt");
    
    append(rmain_cb_list,"anti-coll");
    append(rmain_switch_list,"controls/lighting/strobe-lights");
    append(rmain_output_list,"anti-coll");
    append(rmain_cb_list,"pitot-heat[1]");
    append(rmain_switch_list,"controls/anti-ice/pitot-heat[1]");
    append(rmain_output_list,"pitot-heat[1]");
    append(rmain_cb_list,"cabin-lights");
    append(rmain_switch_list,"controls/lighting/cabin-lights");
    append(rmain_output_list,"cabin-lights");
    append(rmain_cb_list,"engineinstr");
    append(rmain_switch_list,"controls/lighting/panel/engine");
    append(rmain_output_list,"engineinstr");
    append(rmain_cb_list,"cop-flt");
    append(rmain_switch_list,"controls/lighting/panel/cop-flt");
    append(rmain_output_list,"copflt");
    append(rmain_cb_list,"APU");
    append(rmain_switch_list,"controls/APU/master");
    append(rmain_output_list,"APU-master");
    
    
    append(lsecondary_cb_list,"dome-lights");
    append(lsecondary_switch_list,"controls/lighting/dome-lights");
    append(lsecondary_output_list,"dome-lights");
    
    append(rsecondary_cb_list,"landing-light-flr");
    append(rsecondary_switch_list,"controls/lighting/landing-light-flr");
    append(rsecondary_output_list,"landing-light-flr");
    
    append(lvarfreq_cb_list,"l-prop-deice[0]");
    append(lvarfreq_switch_list,"systems/anti-ice/prop-left");
    append(lvarfreq_output_list,"l-prop-deice[0]");
    append(lvarfreq_cb_list,"l-prop-deice[1]");
    append(lvarfreq_switch_list,"systems/anti-ice/prop-left");
    append(lvarfreq_output_list,"l-prop-deice[1]");
    append(lvarfreq_cb_list,"TRU[0]");
    append(lvarfreq_switch_list,"controls/electric/TRU-switch[0]");
    append(lvarfreq_output_list,"TRU[0]");
    
    append(rvarfreq_cb_list,"r-prop-deice[0]");
    append(rvarfreq_switch_list,"systems/anti-ice/prop-right");
    append(rvarfreq_output_list,"r-prop-deice[0]");
    append(rvarfreq_cb_list,"r-prop-deice[1]");
    append(rvarfreq_switch_list,"systems/anti-ice/prop-right");
    append(rvarfreq_output_list,"r-prop-deice[1]");
    append(rvarfreq_cb_list,"TRU[1]");
    append(rvarfreq_switch_list,"controls/electric/TRU-switch[1]");
    append(rvarfreq_output_list,"TRU[1]");
    
    
    #Set all CBs to in (1)
    for(var i=0; i<size(lmain_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~lmain_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(rmain_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~rmain_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(lessential_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~lessential_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(ressential_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~ressential_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(lsecondary_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~lsecondary_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(rsecondary_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~rsecondary_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(lvarfreq_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~lvarfreq_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(rvarfreq_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~rvarfreq_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(lff1_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~lff1_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(rff1_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~rff1_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(lff2_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~lff2_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(rff2_cb_list); i+=1) {
        var tmp = props.globals.getNode(breakers~rff2_cb_list[i],1);
        tmp.setBoolValue(1);
    } 
    
    #append(switch_list,"controls/lighting/wing-lights");
    #append(output_list,"wing-lights");
    #append(switch_list,"controls/electric/aft-boost-pump");
    #append(output_list,"aft-boost-pump");
    #append(switch_list,"controls/electric/fwd-boost-pump");
    #append(output_list,"fwd-boost-pump");


    #Instruments running on L ESSENTIAL DC Bus
    append(lessential_serv_list,"instrumentation/comm[2]/serviceable");
    append(lessential_servout_list,"stby-comm");
    append(lessential_serv_list,"instrumentation/mfd[0]/serviceable");
    append(lessential_servout_list,"mfd[0]");
    append(lmain_serv_list,"instrumentation/advsy[0]/serviceable");
    append(lmain_servout_list,"advsy[0]");

    #Instruments running on R ESSENTIAL DC Bus
    append(ressential_serv_list,breakers~"stby-att");
    append(ressential_servout_list,"stby-att");
    
    
    #Instruments running on L MAIN DC Bus
    append(lmain_serv_list,"instrumentation/adf[0]/serviceable");
    append(lmain_servout_list,"adf[0]");
    append(lmain_serv_list,"instrumentation/dme[0]/serviceable");
    append(lmain_servout_list,"dme[0]");
    append(lmain_serv_list,"instrumentation/comm[0]/serviceable");
    append(lmain_servout_list,"comm[0]");
    append(lmain_serv_list,"instrumentation/gps[0]/serviceable");
    append(lmain_servout_list,"gps[0]");
    append(lmain_serv_list,"instrumentation/elt/serviceable");
    append(lmain_servout_list,"elt");
    append(lmain_serv_list,"instrumentation/transponder[0]/inputs/serviceable");
    append(lmain_servout_list,"transponder[0]");
    append(lmain_serv_list,"instrumentation/tcas/serviceable");
    append(lmain_servout_list,"tcas");
    append(lmain_serv_list,"instrumentation/mk-viii/serviceable"); #GPWS
    append(lmain_servout_list,"mk-viii");
    append(lmain_serv_list,"instrumentation/gear-horn/serviceable");
    append(lmain_servout_list,"gear-horn");
    append(lmain_serv_list,"instrumentation/to-horn/serviceable");
    append(lmain_servout_list,"to-horn");
    append(lmain_serv_list,"instrumentation/ovspd-horn/serviceable");
    append(lmain_servout_list,"ovspd-horn");
    append(lmain_serv_list,"instrumentation/vertical-speed-indicator/serviceable");
    append(lmain_servout_list,"vertical-speed-indicator");
    append(lmain_serv_list,"instrumentation/pfd[0]/serviceable");
    append(lmain_servout_list,"pfd[0]");
    append(lmain_serv_list,"instrumentation/fms[0]/serviceable");
    append(lmain_servout_list,"fms[0]");
    
    #Instruments running on R MAIN DC Bus
    append(rmain_serv_list,"instrumentation/adf[1]/serviceable");
    append(rmain_servout_list,"adf[1]");
    append(rmain_serv_list,"instrumentation/dme[1]/serviceable");
    append(rmain_servout_list,"dme[1]");
    append(rmain_serv_list,"instrumentation/comm[1]/serviceable");
    append(rmain_servout_list,"comm[1]");
    append(rmain_serv_list,"instrumentation/gps[1]/serviceable");
    append(rmain_servout_list,"gps[1]");
    append(rmain_serv_list,"instrumentation/nav[1]/serviceable");
    append(rmain_servout_list,"nav[1]");
    append(rmain_serv_list,"instrumentation/eadi[1]/serviceable");
    append(rmain_servout_list,"eadi[1]");
    append(rmain_serv_list,"instrumentation/ehsi[1]/serviceable");
    append(rmain_servout_list,"ehsi[1]");
    append(rmain_serv_list,"instrumentation/transponder[1]/inputs/serviceable");
    append(rmain_servout_list,"transponder[1]");
    append(rmain_serv_list,"instrumentation/pfd[1]/serviceable");
    append(rmain_servout_list,"pfd[1]");
    append(rmain_serv_list,"instrumentation/mfd[1]/serviceable");
    append(rmain_servout_list,"mfd[1]");
    append(rmain_serv_list,"instrumentation/esid/serviceable");
    append(rmain_servout_list,"esid");
    append(rmain_serv_list,"instrumentation/fms[1]/serviceable");
    append(rmain_servout_list,"fms[1]");
    
    #running on L SECONDARY DC Bus
    append(lsecondary_serv_list,breakers~"stby-hyd-pump[0]");
    append(lsecondary_servout_list,"stby-hyd-pump[0]");
    append(lsecondary_serv_list,"instrumentation/hydraulic/stby-hyd-press[0]/serviceable");
    append(lsecondary_servout_list,"stby-hyd-press[0]");
    
    #running on R SECONDARY DC Bus
    append(rsecondary_serv_list,breakers~"stby-hyd-pump[1]");
    append(rsecondary_servout_list,"stby-hyd-pump[1]");
    append(rsecondary_serv_list,"instrumentation/hydraulic/stby-hyd-press[1]/serviceable");
    append(rsecondary_servout_list,"stby-hyd-press[1]");
    
    #running on L Fixed Frequency 26V Bus
    append(lff2_serv_list,"instrumentation/hydraulic/hyd-qty[0]/serviceable");
    append(lff2_servout_list,"hyd-qty[0]");
    
    #running on R Fixed Frequency 26V Bus
    append(rff2_serv_list,"instrumentation/hydraulic/hyd-qty[1]/serviceable");
    append(rff2_servout_list,"hyd-qty[1]");
    
    #append(serv_list,"instrumentation/heading-indicator/serviceable");
    #append(servout_list,"DG");
    #append(serv_list,"instrumentation/turn-indicator/serviceable");
    #append(servout_list,"turn-coordinator");

    for(var i=0; i<size(lmain_serv_list); i+=1) {
        var tmp = props.globals.getNode(lmain_serv_list[i],1);
        tmp.setBoolValue(1);
    } 
    for(var i=0; i<size(rmain_serv_list); i+=1) {
        var tmp = props.globals.getNode(rmain_serv_list[i],1);
        tmp.setBoolValue(1);
    } 
    
    for(var i=0; i<size(lessential_serv_list); i+=1) {
        var tmp = props.globals.getNode(lessential_serv_list[i],1);
        tmp.setBoolValue(1);
    }
    for(var i=0; i<size(ressential_serv_list); i+=1) {
        var tmp = props.globals.getNode(ressential_serv_list[i],1);
        tmp.setBoolValue(1);
    }
    
    for(var i=0; i<size(lsecondary_serv_list); i+=1) {
        var tmp = props.globals.getNode(lsecondary_serv_list[i],1);
        tmp.setBoolValue(1);
    }
    for(var i=0; i<size(rsecondary_serv_list); i+=1) {
        var tmp = props.globals.getNode(rsecondary_serv_list[i],1);
        tmp.setBoolValue(1);
    }
    
    for(var i=0; i<size(lff1_serv_list); i+=1) {
        var tmp = props.globals.getNode(lff1_serv_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rff1_serv_list); i+=1) {
        var tmp = props.globals.getNode(rff1_serv_list[i],1);
        tmp.setBoolValue(0);
    }
    
    for(var i=0; i<size(lff2_serv_list); i+=1) {
        var tmp = props.globals.getNode(lff2_serv_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rff2_serv_list); i+=1) {
        var tmp = props.globals.getNode(rff2_serv_list[i],1);
        tmp.setBoolValue(0);
    }
    
    
    
    

    for(var i=0; i<size(lmain_switch_list); i+=1) {
        var tmp = props.globals.getNode(lmain_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rmain_switch_list); i+=1) {
        var tmp = props.globals.getNode(rmain_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(lessential_switch_list); i+=1) {
        var tmp = props.globals.getNode(lessential_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(ressential_switch_list); i+=1) {
        var tmp = props.globals.getNode(ressential_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(lsecondary_switch_list); i+=1) {
        var tmp = props.globals.getNode(lsecondary_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rsecondary_switch_list); i+=1) {
        var tmp = props.globals.getNode(rsecondary_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(lvarfreq_switch_list); i+=1) {
        var tmp = props.globals.getNode(lvarfreq_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rvarfreq_switch_list); i+=1) {
        var tmp = props.globals.getNode(rvarfreq_switch_list[i],1);
        tmp.setBoolValue(0);
    }
    
    for(var i=0; i<size(lff1_switch_list); i+=1) {
        var tmp = props.globals.getNode(lff1_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rff1_switch_list); i+=1) {
        var tmp = props.globals.getNode(rff1_switch_list[i],1);
        tmp.setBoolValue(0);
    }
    
    for(var i=0; i<size(lff2_switch_list); i+=1) {
        var tmp = props.globals.getNode(lff2_switch_list[i],1);
        tmp.setBoolValue(0);
    }

    for(var i=0; i<size(rff2_switch_list); i+=1) {
        var tmp = props.globals.getNode(rff2_switch_list[i],1);
        tmp.setBoolValue(0);
    }
    
    
    setprop("/controls/electric/TRU-switch[0]", 1);
    setprop("/controls/electric/TRU-switch[1]", 1);
}

#Left Main Feeder Bus
update_lmain_bus = func ( dt ) {
	var aux_battery_volts = aux_battery.get_output_volts();
	auxbattery_volts.setValue(aux_battery_volts);
	var dcgen1_volts = dcgen1.get_output_volts();
	var EXT_plugged = getprop("/services/ext-pwr/enable") or 0;
	var external_volts = 28.0*EXT_plugged;
	var rmainbusvolts = rmainbus_volts.getValue() or 0;
	
	load = 0.0;
	bus_volts = 0.0;
	power_source = "none";
	
	if( aux_battery_sw.getValue() == 1){
		bus_volts = aux_battery_volts;
		power_source="aux_battery";
	}
	
	if(dcgen1_volts > bus_volts){
		bus_volts = dcgen1_volts;
		power_source = "dcgen1";
        }
	if ( EXT.getBoolValue() and ( external_volts > bus_volts) ) {
		power_source = "external";
		bus_volts = external_volts;
        }
	if(autostart.getValue()==1 and (bus_volts < 25 ) ){
		power_source="temporary_autostart";
		bus_volts = 28;
        }
        if ( rmainbusvolts > (bus_volts+1)){ #Main Bus Connector
		power_source="rmain_bus";
		bus_volts=rmainbusvolts;
	}
        
        bus_volts*=lmain_serviceable.getValue();
        
        #Add Left Main Feeder Bus Users here
        #Engine 1 Starter
	var internal_starter = getprop("controls/engines/internal-engine-starter");
        if(internal_starter == 1){
		if(bus_volts>15){
			setprop("/controls/engines/engine[0]/starter", 1);
			starter_volts = bus_volts * internal_starter;
		}else{
			setprop("/controls/engines/engine[0]/starter", 0);
		}
	}
	load += internal_starter * 5;
	#Cockpit Lights	
	INSTR_DIMMER = getprop("controls/lighting/instruments-norm");
	var instr_lights=(bus_volts * getprop("controls/lighting/instrument-lights") ) * INSTR_DIMMER;
	setprop(outPut~"instrument-lights",(instr_lights));
	setprop(outPut~"instrument-lights-norm",0.0357 * instr_lights);
	
	setprop(outPut~"pltflt-norm", (getprop(outPut~"pltflt") or 0)/28);
	setprop(outPut~"copflt-norm", (getprop(outPut~"copflt") or 0)/28);
	
	setprop(outPut~"engineinstr-norm", (getprop(outPut~"engineinstr") or 0)/28);
	setprop(outPut~"glareshield-norm", (getprop(outPut~"glareshield") or 0)/28);
	setprop(outPut~"overhead-norm", (getprop(outPut~"overhead") or 0)/28);

        

	for(var i=0; i<size(lmain_switch_list); i+=1) {
		var srvc = getprop(lmain_switch_list[i]) * getprop(breakers~lmain_cb_list[i]);
		load +=srvc;
		setprop(outPut~lmain_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(lmain_serv_list); i+=1) {
		var srvc = getprop(lmain_serv_list[i]);
		load +=srvc;
		setprop(outPut~lmain_servout_list[i],bus_volts * srvc);
	}
	
        load+=lessential_bus(bus_volts);
        load+=lsecondary_bus(bus_volts, power_source);
	
	ammeter = 0.0;
	#    if ( bus_volts > 1.0 )load += 15.0;


	if ( power_source == "aux_battery" ) {
		aux_battery.apply_load( load, dt );
		ammeter = -load;
	} elsif ( bus_volts > aux_battery_volts ) {
		aux_battery.apply_load( -aux_battery.charge_amps, dt );
		ammeter = aux_battery.charge_amps;
	}
	
	if ( power_source == "external"){
		dc_ext_flag.setValue(1);
	}else{
		dc_ext_flag.setValue(0);
	}
	

		
	ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

	Amps.setValue(ammeter_ave);
	lmainbus_volts.setValue(bus_volts);
	dcgen1.apply_load(load);

	return load;
}	

#Right Main Feeder Bus
update_rmain_bus = func ( dt ) {
	var main_battery_volts = main_battery.get_output_volts();
	mainbattery_volts.setValue(main_battery_volts);
	var dcgen2_volts = dcgen2.get_output_volts();
	var EXT_plugged = getprop("/services/ext-pwr/enable") or 0;
	var external_volts = 28.0*EXT_plugged;
	var lmainbusvolts = lmainbus_volts.getValue() or 0;
	
	load = 0.0;
	bus_volts = 0.0;
	power_source = "none";
	
	if( main_battery_sw.getValue() == 1){
		bus_volts = main_battery_volts;
		power_source="main_battery";
	}
	
	if(dcgen2_volts > bus_volts){
		bus_volts = dcgen2_volts;
		power_source = "dcgen2";
        }
        if ( lmainbusvolts > (bus_volts+1)){ #Main Bus Connector
		power_source="lmain_bus";
		bus_volts=lmainbusvolts;
	}
	if(autostart.getValue()==1 and (bus_volts < 25 ) ){
		power_source="temporary_autostart";
		bus_volts = 28;
        }
        if(apu_gen.get_output_volts()>bus_volts){
		power_source="APU";
		bus_volts = apu_gen.get_output_volts();
	}
        
        bus_volts*=rmain_serviceable.getValue();
        
        #Add Right Main Feeder Bus Users here
        #Engine 2 Starter
	var internal_starter = getprop("controls/engines/internal-engine-starter");
        if(internal_starter == -1){
		if(bus_volts>15){
			setprop("/controls/engines/engine[1]/starter", 1);
			starter_volts = bus_volts * internal_starter;
		}else{
			setprop("/controls/engines/engine[1]/starter", 0);
		}
	}
	load += -internal_starter * 5;
        #Cockpit Lights
	setprop(outPut~"centerpanel-lights", (( bus_volts * getprop("controls/lighting/panel-lights") ) * getprop("controls/lighting/panel/center") ) * 0.0357 );
        

	for(var i=0; i<size(rmain_switch_list); i+=1) {
		var srvc = getprop(rmain_switch_list[i]) * getprop(breakers~rmain_cb_list[i]);
		load +=srvc;
		setprop(outPut~rmain_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(rmain_serv_list); i+=1) {
		var srvc = getprop(rmain_serv_list[i]);
		load +=srvc;
		setprop(outPut~rmain_servout_list[i],bus_volts * srvc);
	}
	
        load+=ressential_bus(bus_volts);
        load+=rsecondary_bus(bus_volts, power_source);
	
	ammeter = 0.0;
	#    if ( bus_volts > 1.0 )load += 15.0;


	if ( power_source == "main_battery" ) {
		aux_battery.apply_load( load, dt );
		ammeter = -load;
	} elsif ( bus_volts > main_battery_volts ) {
		aux_battery.apply_load( -main_battery.charge_amps, dt );
		ammeter = main_battery.charge_amps;
	}
	
	if ( power_source == "APU"){
		apu_gen.apply_load( load, dt );
	}else if(power_source == "dcgen2"){
		dcgen1.apply_load(load);
	}
		

		
	ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

	Amps.setValue(ammeter_ave);
	rmainbus_volts.setValue(bus_volts);

	return load;
}	

lessential_bus = func(bv) {
	var bus_volts = 0.0;
	var load = 0.0;
	var srvc = 0.0;
	
	var power_source = "none";
	
	if(battery_master.getValue()==1){
		var stby_battery_volts = stby_battery.get_output_volts();
		var aux_battery_volts = aux_battery.get_output_volts();
		if(stby_battery_volts > bus_volts){
			if(aux_battery_volts>stby_battery_volts and lessential_auxbatt.getValue()){
				bus_volts=aux_battery_volts;
				power_source = "aux_battery";
			}else{
				bus_volts=stby_battery_volts;
				power_source = "stby_battery";
			}
		}
	}
	if(lessential_lmain.getValue() and lmain_lessential.getValue() and bv > bus_volts){
		power_source = "lmain_bus";
		bus_volts=bv;
	}
		
	
	bus_volts*=lessential_serviceable.getValue();
	
	#Add L Essential Bus Users here
	
	var ignition_switch0=getprop("/controls/engines/engine[0]/ignition-switch");
	if(ignition_switch0 and bus_volts>=20){
		setprop("/controls/engines/engine[0]/ignition", 1);
		load+=5;
	}else{
		setprop("/controls/engines/engine[0]/ignition", 0);
	}

	for(var i=0; i<size(lessential_switch_list); i+=1) {
		var srvc = getprop(lessential_switch_list[i]) * getprop(breakers~lessential_cb_list[i]);
		load +=srvc;
		setprop(outPut~lessential_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(lessential_serv_list); i+=1) {
		var srvc = getprop(lessential_serv_list[i]);
		load +=srvc;
		setprop(outPut~lessential_servout_list[i],bus_volts * srvc);
	}
	
	load+=lff1_bus(bus_volts);
	
	lessentialbus_volts.setValue(bus_volts);
	
	if(power_source == "aux_battery"){
		aux_battery.apply_load( load, second.getValue() );
		return 0;
	}else if(power_source == "main_battery"){
		main_battery.apply_load( load, second.getValue() );
		return 0;
	}else if(power_source == "lmain_bus"){
		return load;
	}else{
		return 0;
	}
		
}

ressential_bus = func(bv) {
	var bus_volts = bv;
	var load = 0.0;
	var srvc = 0.0;
	
	var power_source = "none";
	
	if(battery_master.getValue()==1){
		var main_battery_volts = main_battery.get_output_volts();
		var stby_battery_volts = stby_battery.get_output_volts();
		if(main_battery_volts > bus_volts){
			if(stby_battery_volts>main_battery_volts){
				bus_volts=stby_battery_volts;
				power_source = "stby_battery";
			}else{
				bus_volts=main_battery_volts;
				power_source = "main_battery";
			}
		}
	}else{
		power_source = "rmain_bus";
	}
	
	bus_volts*=ressential_serviceable.getValue();
	
	#Add R Essential Bus Users here
	
	var ignition_switch1=getprop("/controls/engines/engine[1]/ignition-switch");
	if(ignition_switch1 and bus_volts>=20){
		setprop("/controls/engines/engine[1]/ignition", 1);
		load+=5;
	}else{
		setprop("/controls/engines/engine[1]/ignition", 0);
	}

	for(var i=0; i<size(ressential_switch_list); i+=1) {
		var srvc = getprop(ressential_switch_list[i]) * getprop(breakers~ressential_cb_list[i]);
		load +=srvc;
		setprop(outPut~ressential_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(ressential_serv_list); i+=1) {
		var srvc = getprop(ressential_serv_list[i]);
		load +=srvc;
		setprop(outPut~ressential_servout_list[i],bus_volts * srvc);
	}
	
	load+=rff1_bus(bus_volts);
	
	ressentialbus_volts.setValue(bus_volts);
	
	if(power_source == "aux_battery"){
		aux_battery.apply_load( load, second.getValue() );
		return 0;
	}else if(power_source == "main_battery"){
		main_battery.apply_load( load, second.getValue() );
		return 0;
	}else if(power_source == "rmain_bus"){
		return load;
	}else{
		return 0;
	}
		
}


lsecondary_bus = func(bv,source) {
	var bus_volts = 0.0;
	var load = 0.0;
	var srvc = 0.0;
	var power_source="";
	
	var tru1_out = getprop(outPut~"TRU[0]") or 0;
	if(tru1_out > 72){
		bus_volts = tru1_out/4;
		power_source="LTRU";
	}else if(source != "main_battery" and source != "aux_battery" and source != "stby_battery"){
		bus_volts=bv;
		var power_source = "lmain_bus";
	}
	
	
	bus_volts*=lsecondary_serviceable.getValue();
	
	#Add L Secondary Bus Users here
	
	for(var i=0; i<size(lsecondary_switch_list); i+=1) {
		var srvc = getprop(lsecondary_switch_list[i]) * getprop(breakers~lsecondary_cb_list[i]);
		load +=srvc;
		setprop(outPut~lsecondary_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(lsecondary_serv_list); i+=1) {
		var srvc = getprop(lsecondary_serv_list[i]);
		load +=srvc;
		setprop(outPut~lsecondary_servout_list[i],bus_volts * srvc);
	}
	
	
	lsecondarybus_volts.setValue(bus_volts);
	
	if(power_source == "lmain_bus"){
		return load;
	}else{
		return 0;
	}
		
}

rsecondary_bus = func(bv, source) {
	var bus_volts = 0.0;
	var load = 0.0;
	var srvc = 0.0;
	var power_source="";
	
	
	var tru2_out = getprop(outPut~"TRU[1]") or 0;
	if(tru2_out > 72){
		bus_volts = tru2_out/4;
		power_source="RTRU";
	}else if(source != "main_battery" and source != "aux_battery" and source != "stby_battery"){
		bus_volts=bv;
		var power_source = "rmain_bus";
	}
	
	
	bus_volts*=rsecondary_serviceable.getValue();
	
	#Add R Secondary Bus Users here
	
	for(var i=0; i<size(rsecondary_switch_list); i+=1) {
		var srvc = getprop(rsecondary_switch_list[i]) * getprop(breakers~rsecondary_cb_list[i]);
		load +=srvc;
		setprop(outPut~rsecondary_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(rsecondary_serv_list); i+=1) {
		var srvc = getprop(rsecondary_serv_list[i]);
		load +=srvc;
		setprop(outPut~rsecondary_servout_list[i],bus_volts * srvc);
	}
	
	
	rsecondarybus_volts.setValue(bus_volts);
	
	if(power_source == "rmain_bus"){
		return load;
	}else{
		return 0;
	}
		
}

###########
#AC System#
###########

#Variable Frequency Busses

#Left Variable Frequency Bus
update_lvarfreq_bus = func ( dt ) {
	#Possible power sources: AC gens and AC EXT
	
	var acgen1_volts = acgen1.get_output_volts();
	var EXT_plugged = getprop("/services/ext-pwr/enable") or 0;
	var external_volts = 115.0*EXT_plugged;
	
	load = 0.0;
	bus_volts = 0.0;
	power_source = "none";
	
	if(acgen1_volts > bus_volts){
		bus_volts = acgen1_volts;
		power_source = "acgen1";
        }
	if ( AC_EXT.getBoolValue() and ( external_volts > bus_volts) ) {
		power_source = "external";
		bus_volts = external_volts;
        }
	if(autostart.getValue()==1 and (bus_volts < 25 ) ){
		power_source="temporary_autostart";
		bus_volts = 115;
        }
        
        bus_volts*=lvarfreq_serviceable.getValue();
        
        #Add Users here
	for(var i=0; i<size(lvarfreq_switch_list); i+=1) {
		var srvc = getprop(lvarfreq_switch_list[i]) * getprop(breakers~lvarfreq_cb_list[i]);
		load +=srvc;
		setprop(outPut~lvarfreq_output_list[i],bus_volts * srvc);
	}
	


	if ( power_source == "acgen1" ) {
		acgen1.apply_load(load);
	}

	lvarfreqbus_volts.setValue(bus_volts);

	return load;
}

#Right Variable Frequency Bus
update_rvarfreq_bus = func ( dt ) {
	#Possible power sources: AC gens and AC EXT
	
	var acgen2_volts = acgen2.get_output_volts();
	var EXT_plugged = getprop("/services/ext-pwr/enable") or 0;
	var external_volts = 115.0*EXT_plugged;
	
	load = 0.0;
	bus_volts = 0.0;
	power_source = "none";
	
	if(acgen2_volts > bus_volts){
		bus_volts = acgen2_volts;
		power_source = "acgen2";
        }
	if ( AC_EXT.getBoolValue() and ( external_volts > bus_volts) ) {
		power_source = "external";
		bus_volts = external_volts;
        }
	if(autostart.getValue()==1 and (bus_volts < 25 ) ){
		power_source="temporary_autostart";
		bus_volts = 115;
        }
        
        bus_volts*=rvarfreq_serviceable.getValue();
        
        #Add Users here
	for(var i=0; i<size(rvarfreq_switch_list); i+=1) {
		var srvc = getprop(rvarfreq_switch_list[i]) * getprop(breakers~rvarfreq_cb_list[i]);
		load +=srvc;
		setprop(outPut~rvarfreq_output_list[i],bus_volts * srvc);
	}
	


	if ( power_source == "acgen2" ) {
		acgen2.apply_load(load);
	}
	
	if ( power_source == "external" ) {
		ac_ext_flag.setValue(1);
	}else{
		ac_ext_flag.setValue(0);
	}

	rvarfreqbus_volts.setValue(bus_volts);

	return load;
}	

#Fixed Frequency Busses

#Left 115V Fixed Frequency AC Bus
lff1_bus = func(bv) {
	var bus_volts = bv*4.107;
	var load = 0.0;
	var power_source = "lessential_bus";
	
	
	bus_volts*=lff1_serviceable.getValue();
	
	#Add L Fixed Frequency 115V AC Bus Users here
	
	for(var i=0; i<size(lff1_switch_list); i+=1) {
		var srvc = getprop(lff1_switch_list[i]) * getprop(breakers~lff1_cb_list[i]);
		load +=srvc;
		setprop(outPut~lff1_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(lff1_serv_list); i+=1) {
		var srvc = getprop(lff1_serv_list[i]);
		load +=srvc;
		setprop(outPut~lff1_servout_list[i],bus_volts * srvc);
	}
	
	
	lff1bus_volts.setValue(bus_volts);
	
	load+=lff2_bus(bus_volts);
	
	return load;
		
}

#Left 26V Fixed Frequency AC Bus
lff2_bus = func(bv) {
	var bus_volts = bv/4.423;
	var load = 0.0;
	var power_source = "lff1_bus";
	
	
	bus_volts*=lff2_serviceable.getValue();
	
	#Add L Fixed Frequency 26V AC Bus Users here
	
	for(var i=0; i<size(lff2_switch_list); i+=1) {
		var srvc = getprop(lff2_switch_list[i]) * getprop(breakers~lff2_cb_list[i]);
		load +=srvc;
		setprop(outPut~lff2_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(lff2_serv_list); i+=1) {
		var srvc = getprop(lff2_serv_list[i]);
		load +=srvc;
		setprop(outPut~lff2_servout_list[i],bus_volts * srvc);
	}
	
	
	lff2bus_volts.setValue(bus_volts);
	
	return load;
		
}

#Right 115V Fixed Frequency AC Bus
rff1_bus = func(bv) {
	var bus_volts = bv*4.107;
	var load = 0.0;
	var power_source = "ressential_bus";
	
	
	bus_volts*=rff1_serviceable.getValue();
	
	#Add R Fixed Frequency 115V AC Bus Users here
	
	for(var i=0; i<size(rff1_switch_list); i+=1) {
		var srvc = getprop(rff1_switch_list[i]) * getprop(breakers~rff1_cb_list[i]);
		load +=srvc;
		setprop(outPut~rff1_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(rff1_serv_list); i+=1) {
		var srvc = getprop(rff1_serv_list[i]);
		load +=srvc;
		setprop(outPut~rff1_servout_list[i],bus_volts * srvc);
	}
	
	
	rff1bus_volts.setValue(bus_volts);
	
	load+=rff2_bus(bus_volts);
	
	return load;
		
}

#Right 26V Fixed Frequency AC Bus
rff2_bus = func(bv) {
	var bus_volts = bv/4.423;
	var load = 0.0;
	var power_source = "rff1_bus";
	
	
	bus_volts*=rff2_serviceable.getValue();
	
	#Add R Fixed Frequency 26V AC Bus Users here
	
	for(var i=0; i<size(rff2_switch_list); i+=1) {
		var srvc = getprop(rff2_switch_list[i]) * getprop(breakers~rff2_cb_list[i]);
		load +=srvc;
		setprop(outPut~lff2_output_list[i],bus_volts * srvc);
	}
	
	for(var i=0; i<size(rff2_serv_list); i+=1) {
		var srvc = getprop(rff2_serv_list[i]);
		load +=srvc;
		setprop(outPut~rff2_servout_list[i],bus_volts * srvc);
	}
	
	
	rff2bus_volts.setValue(bus_volts);
	
	return load;
		
}


general_loop = func{
	
	
	#Battery Amps
	setprop("systems/electrical/main-battery-load", main_battery.get_output_amps()/30);
	setprop("systems/electrical/aux-battery-load", aux_battery.get_output_amps()/30);
	setprop("systems/electrical/stby-battery-load", stby_battery.get_output_amps()/30);
	
	#AC Gen Volts
	setprop("systems/electrical/gen-volts[0]", dcgen1.get_output_volts());
	setprop("systems/electrical/gen-volts[1]", dcgen2.get_output_volts());
	setprop("systems/electrical/gen-volts[2]", acgen1.get_output_volts());
	setprop("systems/electrical/gen-volts[3]", acgen2.get_output_volts());
	setprop("systems/electrical/apu-volts[4]", apu_gen.get_output_volts());
	
	#Nasal engine start selector
	var internal_selector = getprop("/controls/engines/internal-engine-starter-selector");
	var starter_select = getprop("/controls/engines/start-select");
	var starter = getprop("/controls/engines/internal-engine-starter");
	
	if(internal_selector!=0 and starter==0){
		setprop("/controls/engines/start-select-btn", 1);
	}else if(starter!=0){
		setprop("/controls/engines/start-select-btn", 2);
	}else{
		setprop("/controls/engines/start-select-btn", 0);
	}
	
	var runningL=getprop("/engines/engine[0]/running");
	var runningR=getprop("/engines/engine[1]/running");
	
	if(runningL and starter==1){
		setprop("/controls/engines/internal-engine-starter-selector", 0);
	}
	
	if(runningR and starter==-1){
		setprop("/controls/engines/internal-engine-starter-selector", 0);
	}
	
	
	
	#a bit of nasal for the start ;)
	if(getprop("/controls/engines/internal-engine-starter-selector") == 0){
		setprop("/controls/engines/internal-engine-starter", 0);
	}
  
	#Lights   
    
	var navLV=getprop("/systems/electrical/outputs/nav-lights");
	if(navLV){
		setprop("/systems/electrical/outputs/nav-lights-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/nav-lights-norm", 0);
	}
	
	var taxiLV=getprop("/systems/electrical/outputs/taxi-light");
	if(taxiLV){
		setprop("/systems/electrical/outputs/taxi-light-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/taxi-light-norm", 0);
	}
	
	var landingLV0=getprop("/systems/electrical/outputs/landing-light-flr");
	if(landingLV0){
		setprop("/systems/electrical/outputs/landing-light-flr-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/landing-light-flr-norm", 0);
	}
	
	var landingLV1=getprop("/systems/electrical/outputs/landing-light-app");
	if(landingLV1){
		setprop("/systems/electrical/outputs/landing-light-app-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/landing-light-app-norm", 0);
	}
	
	var strobeLV=getprop("/systems/electrical/outputs/anti-coll");
	var strobeS=getprop("/sim/model/lights/strobe/state");
	if(strobeLV and strobeS){
		setprop("/systems/electrical/outputs/strobe-lights-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/strobe-lights-norm", 0);
	}
	
	var beaconLV=getprop("/systems/electrical/outputs/anti-coll");
	var beaconS=getprop("/sim/model/lights/beacon/state");
	if(beaconLV and beaconS){
		setprop("/systems/electrical/outputs/beacon-lights-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/beacon-lights-norm", 0);
	}
	
	var logoLV=getprop("/systems/electrical/outputs/logo-lights");
	if(logoLV){
		setprop("/systems/electrical/outputs/logo-lights-norm", 1);
	}else{
		setprop("/systems/electrical/outputs/logo-lights-norm", 0);
	}
        
	#Control ALS landing lights
	var landingLN1=getprop("/systems/electrical/outputs/landing-light-app-norm");
	var landingLN2=getprop("/systems/electrical/outputs/landing-light-flr-norm");
	#var taxiLN=getprop("/systems/electrical/outputs/taxi-light-norm");
	var viewint=getprop("/sim/current-view/internal");
	if(viewint and landingLN1 ){
		setprop("/sim/rendering/als-secondary-lights/use-landing-light", 1);
	}else{
		setprop("/sim/rendering/als-secondary-lights/use-landing-light", 0);
	}
	if(viewint and landingLN2 ){
		setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 1);
	}else{
		setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 0);
	}
	#if(viewint and taxiLN ){
	#setprop("/sim/rendering/als-secondary-lights/use-searchlight", 1);
	#}else{
	#setprop("/sim/rendering/als-secondary-lights/use-searchlight", 0);
	#}
  
	
	#DC SYSTEM panel indications
	
	var dc_bus_select = getprop("/controls/electric/dc-bus-select");
	if(dc_bus_select==0){
		dcindbv.setValue(lsecondarybus_volts.getValue() or 0);
	}else if(dc_bus_select==1){
		dcindbv.setValue(lmainbus_volts.getValue() or 0);
	}else if(dc_bus_select==2){
		dcindbv.setValue(lessentialbus_volts.getValue() or 0);
	}else if(dc_bus_select==3){
		dcindbv.setValue(ressentialbus_volts.getValue() or 0);
	}else if(dc_bus_select==4){
		dcindbv.setValue(rmainbus_volts.getValue() or 0);
	}else if(dc_bus_select==5){
		dcindbv.setValue(rsecondarybus_volts.getValue() or 0);
	}
    
    
    settimer(general_loop, 0);
}

update_electrical = func {
	var scnd = getprop("sim/time/delta-sec");
	update_lmain_bus( scnd );
	update_rmain_bus( scnd );
	update_lvarfreq_bus( scnd );
	update_rvarfreq_bus( scnd );
	settimer(update_electrical, 0);
}

setlistener("/controls/engines/start-select", func{
    if(getprop("/systems/electrical/DC/lmain-bus/volts")>20){
        setprop("/controls/engines/internal-engine-starter", getprop("/controls/engines/internal-engine-starter-selector"));
    }
});

#Thrust reverser
setlistener("/controls/engines/engine[0]/reverser", func{
    if(getprop("/controls/engines/engine[0]/throttle")<0.1) {
        setprop("/fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", getprop("/controls/engines/engine[0]/reverser")*180);
    }
});
setlistener("/controls/engines/engine[1]/reverser", func{
    if(getprop("/controls/engines/engine[1]/throttle")<0.1) {
        setprop("/fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", getprop("/controls/engines/engine[1]/reverser")*180);
    }
});


#Generator Control Unit (GCU)
#set generator property on for engine start
setlistener("/controls/engines/engine[0]/starter", func(i) {
	if(i.getValue()==1){
		setprop("controls/electric/engine[0]/generator", 1);
	}else{
		setprop("controls/electric/engine[0]/generator", 0);
	}
});
setlistener("/controls/engines/engine[1]/starter", func(i) {
	if(i.getValue()==1){
		setprop("controls/electric/engine[1]/generator", 1);
	}else{
		setprop("controls/electric/engine[1]/generator", 0);
	}
});
