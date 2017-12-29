# Q400 MFD/EFIS by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Power_Plant.pdf https://quizlet.com/2663067/q400-limitations-flash-cards/ http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var TEAM_first = nil;
var TEAM_display = nil;
var page = "first";

setprop("/engines/engine[0]/thruster/torque", 0);
setprop("/engines/engine[1]/thruster/torque", 0);
setprop("/engines/engine[0]/thruster/rpm", 0);
setprop("/engines/engine[1]/thruster/rpm", 0);
setprop("/engines/engine[0]/itt_degc", 0);
setprop("/engines/engine[1]/itt_degc", 0);
setprop("/engines/engine[0]/oil-pressure-psi", 0);
setprop("/MFD/oil-pressure-needle[0]", 0);
setprop("/engines/engine[1]/oil-pressure-psi", 0);
setprop("/MFD/oil-pressure-needle[1]", 0);
setprop("/engines/engine[0]/oil-temperature-degc", 0);
setprop("/MFD/oil-temperature-needle[0]", 0);
setprop("/engines/engine[1]/oil-temperature-degc", 0);
setprop("/MFD/oil-temperature-needle[1]", 0);
setprop("/engines/engine[0]/fuel-flow-pph", 0);
setprop("/engines/engine[1]/fuel-flow-pph", 0);
setprop("/consumables/fuel/tank[0]/temperature-degc", 0);
setprop("/consumables/fuel/tank[1]/temperature-degc", 0);
setprop("/controls/engines/engine[0]/condition-lever-state", 0);
setprop("/controls/engines/engine[1]/condition-lever-state", 0);
setprop("/controls/engines/engine[0]/throttle-int", 0);
setprop("/controls/engines/engine[1]/throttle-int", 0);
setprop("/countdown-value", 0);

var canvas_TEAM_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {'font-mapper': font_mapper});
		
		var svg_keys = me.getKeys();
				
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();
			foreach (var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var clip_el = canvas_group.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tran_rect = clip_el.getTransformedBounds();
				var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
				tran_rect[1], # 0 ys
				tran_rect[2], # 1 xe
				tran_rect[3], # 2 ye
				tran_rect[0]); #3 xs
				#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
				me[key].set("clip", clip_rect);
				me[key].set("clip-frame", canvas.Element.PARENT);
			}
			}
		}
		
		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		if (getprop("/systems/electrical/volts") >= 10) {
				TEAM_first.page.show();
		} else {
			TEAM_first.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_TEAM_first = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_TEAM_first,canvas_TEAM_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["vhf1.act","vhf1.prst","vhf1.box","vhf1.vol.bar","vhf2.vol.bar","atc1.act","atc1.text","atc1.box","atc1.prst","vhf2.vol.bar","vor1.flag","vor1.act","vor1.prst","vor1.box","vor2.flag","vor2.act","vor2.prst","vor1.vol.bar","vor2.vol.bar","vhf2.prst","vhf2.act","vhf2.box","vor2.box","ils1.flag","ils2.flag","adf1.act","adf1.prst","adf2.act","adf2.prst","adf1.vol.bar","adf2.vol.bar"];
	},
	update: func() {		
		var selected_field=getprop("/instrumentation/TEAM/lh-selected") or 0;
		if(selected_field==1){
			me["vhf1.box"].show();
			me["vhf1.prst"].setColor(0,0,0);
			me["vhf2.box"].hide();
			me["vhf2.prst"].setColor(0,1,0);
			me["vor1.box"].hide();
			me["vor1.prst"].setColor(0,1,0);
			me["vor2.box"].hide();
			me["vor2.prst"].setColor(0,1,0);
			me["atc1.box"].hide();
			me["atc1.prst"].setColor(0,1,1);
		}else if(selected_field==2){
			me["vhf1.box"].hide();
			me["vhf1.prst"].setColor(0,1,0);
			me["vhf2.box"].show();
			me["vhf2.prst"].setColor(0,0,0);
			me["vor1.box"].hide();
			me["vor1.prst"].setColor(0,1,0);
			me["vor2.box"].hide();
			me["vor2.prst"].setColor(0,1,0);
			me["atc1.box"].hide();
			me["atc1.prst"].setColor(0,1,1);
		}else if(selected_field==3){
			me["vhf1.box"].hide();
			me["vhf1.prst"].setColor(0,1,0);
			me["vhf2.box"].hide();
			me["vhf2.prst"].setColor(0,1,0);
			me["vor1.box"].show();
			me["vor1.prst"].setColor(0,0,0);
			me["vor2.box"].hide();
			me["vor2.prst"].setColor(0,1,0);
			me["atc1.box"].hide();
			me["atc1.prst"].setColor(0,1,1);
		}else if(selected_field==4){
			me["vhf1.box"].hide();
			me["vhf1.prst"].setColor(0,1,0);
			me["vhf2.box"].hide();
			me["vhf2.prst"].setColor(0,1,0);
			me["vor1.box"].hide();
			me["vor1.prst"].setColor(0,1,0);
			me["vor2.box"].show();
			me["vor2.prst"].setColor(0,0,0);
			me["atc1.box"].hide();
			me["atc1.prst"].setColor(0,1,1);
		}else if(selected_field==8){
			me["vhf1.box"].hide();
			me["vhf1.prst"].setColor(0,1,0);
			me["vhf2.box"].hide();
			me["vhf2.prst"].setColor(0,1,0);
			me["vor1.box"].hide();
			me["vor1.prst"].setColor(0,1,0);
			me["vor2.box"].hide();
			me["vor2.prst"].setColor(0,1,0);
			me["atc1.box"].show();
			me["atc1.prst"].setColor(0,0,0);
		}else{
			me["vhf1.box"].hide();
			me["vhf1.prst"].setColor(0,1,0);
			me["vhf2.box"].hide();
			me["vhf2.prst"].setColor(0,1,0);
			me["vor1.box"].hide();
			me["vor1.prst"].setColor(0,1,0);
			me["vor2.box"].hide();
			me["vor2.prst"].setColor(0,1,0);
			me["atc1.box"].hide();
			me["atc1.prst"].setColor(0,1,1);
		}
			
		#me["thrustdtR"].setText(thrustmode1 or "");
		
		#VHF1
		var vhf1_act_freq=getprop("/instrumentation/comm[0]/frequencies/selected-mhz-fmt") or 0;
		var vhf1_prst_freq=getprop("/instrumentation/comm[0]/frequencies/standby-mhz-fmt") or 0;
		var vhf1_volume=getprop("/instrumentation/comm[0]/volume") or 0;
		me["vhf1.act"].setText(sprintf("%3.3f",vhf1_act_freq));
		me["vhf1.prst"].setText(sprintf("%3.3f",vhf1_prst_freq));
		me["vhf1.vol.bar"].setTranslation(0,vhf1_volume*(-133));
		#VHF2
		var vhf2_act_freq=getprop("/instrumentation/comm[1]/frequencies/selected-mhz-fmt") or 0;
		var vhf2_prst_freq=getprop("/instrumentation/comm[1]/frequencies/standby-mhz-fmt") or 0;
		var vhf2_volume=getprop("/instrumentation/comm[1]/volume") or 0;
		me["vhf2.act"].setText(sprintf("%3.3f",vhf2_act_freq));
		me["vhf2.prst"].setText(sprintf("%3.3f",vhf2_prst_freq));
		me["vhf2.vol.bar"].setTranslation(0,vhf2_volume*(-133));
		
		#VOR/ILS 1
		var vor1_act_freq=getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt") or 0;
		var vor1_prst_freq=getprop("/instrumentation/nav[0]/frequencies/standby-mhz-fmt") or 0;
		var vor1_volume=getprop("/instrumentation/nav[0]/volume") or 0;
		var vor1_localizer=getprop("/instrumentation/nav[0]/nav-loc") or 0;
		me["vor1.act"].setText(sprintf("%3.3f",vor1_act_freq));
		me["vor1.prst"].setText(sprintf("%3.3f",vor1_prst_freq));
		me["vor1.vol.bar"].setTranslation(0,vor1_volume*(-133));
		if(vor1_localizer==1){
			me["vor1.flag"].hide();
			me["ils1.flag"].show();
		}else{	
			me["vor1.flag"].show();
			me["ils1.flag"].hide();
		}
		#VOR/ILS 2
		var vor2_act_freq=getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt") or 0;
		var vor2_prst_freq=getprop("/instrumentation/nav[1]/frequencies/standby-mhz-fmt") or 0;
		var vor2_volume=getprop("/instrumentation/nav[1]/volume") or 0;
		var vor2_localizer=getprop("/instrumentation/nav[1]/nav-loc") or 0;
		me["vor2.act"].setText(sprintf("%3.3f",vor2_act_freq));
		me["vor2.prst"].setText(sprintf("%3.3f",vor2_prst_freq));
		me["vor2.vol.bar"].setTranslation(0,vor2_volume*(-133));
		if(vor2_localizer==1){
			me["vor2.flag"].hide();
			me["ils2.flag"].show();
		}else{	
			me["vor2.flag"].show();
			me["ils2.flag"].hide();
		}
		
		#ADF 1
		var adf1_act_freq=getprop("/instrumentation/adf[0]/frequencies/selected-khz") or 0;
		var adf1_prst_freq=getprop("/instrumentation/adf[0]/frequencies/standby-khz") or 0;
		var adf1_volume=getprop("/instrumentation/adf[0]/volume-norm") or 0;
		me["adf1.act"].setText(sprintf("%3d",adf1_act_freq));
		me["adf1.prst"].setText(sprintf("%3d",adf1_prst_freq));
		me["adf1.vol.bar"].setTranslation(0,adf1_volume*(-133));
		#ADF 2
		var adf2_act_freq=getprop("/instrumentation/adf[1]/frequencies/selected-khz") or 0;
		var adf2_prst_freq=getprop("/instrumentation/adf[1]/frequencies/standby-khz") or 0;
		var adf2_volume=getprop("/instrumentation/adf[1]/volume-norm") or 0;
		me["adf2.act"].setText(sprintf("%3d",adf2_act_freq));
		me["adf2.prst"].setText(sprintf("%3d",adf2_prst_freq));
		me["adf2.vol.bar"].setTranslation(0,adf2_volume*(-133));
		
		#ATC1 (TRANSPONDER)
		me["atc1.act"].setText(sprintf("%04d", getprop("/instrumentation/transponder/id-code") or 0));
		var transponder_mode=getprop("/instrumentation/transponder/inputs/knob-mode");
		if(transponder_mode==0){
			me["atc1.text"].setText("OFF");
		}else if(transponder_mode==1){
			me["atc1.text"].setText("STBY");
		}else if(transponder_mode==2){
			me["atc1.text"].setText("TEST");
		}else if(transponder_mode==3){
			me["atc1.text"].setText("GND");
		}else if(transponder_mode==4){
			me["atc1.text"].setText("ON");
		}else if(transponder_mode==5){
			me["atc1.text"].setText("ON ALT");
		}else{
			me["atc1.text"].setText("XXXX");
		}
		me["atc1.prst"].setText(sprintf("%04d", getprop("/instrumentation/transponder/inputs/stby-code") or 0));
		
		
		
		settimer(func me.update(), 0.02);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	TEAM_display = canvas.new({
		"name": "TEAM",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	TEAM_display.addPlacement({"node": "team.display"});
	var groupTEAMfirst = TEAM_display.createGroup();

	TEAM_first = canvas_TEAM_first.new(groupTEAMfirst, "Aircraft/Q400/Models/Instruments/TEAM/TEAM.first.svg");

	TEAM_first.update();
	canvas_TEAM_base.update();
});

var showTEAM = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(TEAM_display);
}

	
