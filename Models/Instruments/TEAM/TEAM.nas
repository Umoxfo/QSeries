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
		return ["vhf1.act","vhf1.prst","vhf1.box"];
	},
	update: func() {
		me["vhf1.act"].setText(getprop("/instrumentation/comm[0]/frequencies/selected-mhz-fmt") or "");
		me["vhf1.prst"].setText(getprop("/instrumentation/comm[0]/frequencies/standby-mhz-fmt") or "");
		if(getprop("/instrumentation/comm[0]/selected")){
			me["vhf1.box"].show();
			me["vhf1.prst"].setColor(0,0,0);
		}else{
			me["vhf1.box"].hide();
			me["vhf1.prst"].setColor(0,1,0);
		}
			
		#me["thrustdtR"].setText(thrustmode1 or "");
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