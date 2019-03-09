# Q100/200/300 VSI by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Dash8-200-300-Flight_Instruments.pdf



var VSI_main = nil;
var VSI_display = nil;
var page = "only";

#All properties used...
var VS_needle = props.globals.getNode("/instrumentation/vertical-speed-indicator/vsi-needle",1);
var VS_needle = props.globals.initNode("/instrumentation/vertical-speed-indicator/vsi-needle", 0.0, "DOUBLE");

var Volts = props.globals.initNode("/systems/electrical/outputs/vertical-speed-indicator", 0.0,  "DOUBLE");


var canvas_VSI_base = {
	init: func(canvas_group, file, screen) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Bold.ttf";
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
		if (Volts.getValue() >= 10) {
			VSI_main.page.show();
		} else {
			VSI_main.page.hide();
		}
		
		settimer(func me.update(), 0.1);
	},
};

var canvas_VSI_main = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_VSI_main,canvas_VSI_base] };
		m.init(canvas_group, file, "main");

		return m;
	},
	getKeys: func() {
		return ["vsi.needle"];
	},
	fast_update: func() {
		
		#Attitude Indicator
		var vsi_needle=VS_needle.getValue();
		me["vsi.needle"].setRotation(vsi_needle*D2R);
		
		settimer(func me.fast_update(), 0.05);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	VSI_display = canvas.new({
		"name": "VSI",
		"size": [512, 512],
		"view": [512, 512],
		"mipmapping": 1
	});
	VSI_display.addPlacement({"node": "VSI.screen"});
	var groupVSImain = VSI_display.createGroup();

	VSI_main = canvas_VSI_main.new(groupVSImain, "Aircraft/QSeries/Models/Cockpit/Instruments/VSI/VSI.svg");

	VSI_main.fast_update();
	canvas_VSI_base.update();
});

var showVSI = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(VSI_display);
}
