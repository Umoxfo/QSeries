# A3XX ND Canvas
# Joshua Davidson (it0uchpods)
# Based on work by artix

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var ALWAYS = func 1;
var NOTHING = func nil;

canvas.NDStyles["Airbus"] = {
	font_mapper: func(family, weight) {
		if( family == "Liberation Sans" and weight == "normal" )
			return "LiberationFonts/LiberationSans-Regular.ttf";
	},

	# where all the symbols are stored
	# TODO: SVG elements should be renamed to use boeing/airbus prefix
	# aircraft developers should all be editing the same ND.svg image
	# the code can deal with the differences now
	svg_filename: get_local_path("res/airbusND.svg"),
	##
	## this loads and configures existing layers (currently, *.layer files in Nasal/canvas/map)
	##
	options: {
		position_callback: func(nd, pos){
			if(nd.get_switch("toggle_centered") or 
			   nd.get_switch("toggle_display_mode") == "PLAN")
				pos.range = (nd.rangeNm() * 1.6156087432822295);
		},
		translation_callback: func(nd){
			var t = {x: 512, y: 824};
			if(nd.get_switch("toggle_centered") or 
			   nd.get_switch("toggle_display_mode") == "PLAN")
				t.y = 512;
			return t;
		},
		defaults: {
			# Configurable Global Options:
			#	- fplan_active: the boolean property used to determine if the flight plan is active
			#	- lat_ctrl: the property used to determine if lateral flight mode is managed 
			#		Lateral managed mode is similar to Boeing LNAV and indicates that the 
			#		aircraft should follow the current active flight plan. By default 
			#		the lat_ctrl property is checked against "fmgc" (managed) value.
			#		You can use a custom value instead on "fmgc" by overriding "managed_val"
			#	- managed_val: the value that the property defined by "lat_ctrl" should have in case 
			#			that the lateral flight mode is managed.
			# You can easily override these options before creating the ND, example:
			#	canvas.NDStyles["Airbus"].options.defaults.fplan_active = "my/autpilot/f-plan/active"
			fplan_active: "autopilot/route-manager/active",
			lat_ctrl: "/it-autoflight/output/lat",
			managed_val: 1,
			ver_ctrl: "/it-autoflight/output/vert",
			spd_ctrl: "/flight-management/control/spd-ctrl",
			current_wp: "/autopilot/route-manager/current-wp",
			ap1: "/it-autoflight/output/ap1",
			ap2: "/it-autoflight/output/ap2",
			nav1_frq: "/instrumentation/nav[0]/frequencies/selected-mhz",
			nav2_frq: "/instrumentation/nav[1]/frequencies/selected-mhz",
			vor1_frq: "/instrumentation/nav[2]/frequencies/selected-mhz",
			vor2_frq: "/instrumentation/nav[3]/frequencies/selected-mhz",
			adf1_frq: "/instrumentation/adf[0]/frequencies/selected-khz",
			adf2_frq: "/instrumentation/adf[1]/frequencies/selected-khz",
			dep_rwy: "/autopilot/route-manager/departure/runway",
			dest_rwy: "/autopilot/route-manager/destination/runway",
			wp_count: "autopilot/route-manager/route/num",
			level_off_alt: "/autopilot/route-manager/vnav/level-off-alt",
			athr: "/it-autoflight/output/athr",
			app_mode: "/instrumentation/nd/app-mode",
			chrono_node: "/instrumentation/chrono",
			fpln_offset: "/autopilot/route-manager/offset",
			active_route_color: [0.0509,0.7529,0.2941],
			inactive_route_color: [0.95,0.95,0.21]
		},
		radio: {
			ils: [0, 1],
			vor: [2, 3],
			dme: [2, 3]
		}
	},
	layers: [
		{ 
			name:"WXR_live", 
			isMapStructure:1, 
			always_update: 1,
			update_on:[ "toggle_range","toggle_weather","toggle_display_mode","toggle_weather_live"],
			predicate: func(nd, layer) {
				var visible=nd.get_switch("toggle_weather") and 
					nd.get_switch("toggle_weather_live") and 
					nd.get_switch("toggle_display_mode") != "PLAN";
				layer.group.setVisible(visible);
				if (visible) {
					layer.update(); 
				}
			}, # end of layer update predicate
			options: {
				viewport_radius: 706
			},
			"z-index": -100,
		},
		{ 
			name:"WXR", 
			isMapStructure:1, 
			update_on:[ {rate_hz: 0.1}, "toggle_range","toggle_weather","toggle_display_mode", "toggle_weather_live"],
			predicate: func(nd, layer) {
				#print("Running storms predicate");
				var visible=nd.get_switch("toggle_weather") and 
					!nd.get_switch("toggle_weather_live") and 
					nd.get_switch("toggle_display_mode") != "PLAN";
				layer.group.setVisible(visible);
				if (visible) {
					#print("storms update requested! (timer issue when closing the dialog?)");
					layer.update(); 
				}
			}, # end of layer update predicate
			"z-index": -4,
		}, # end of storms/WXR layer
		{ 
			name:"FIX", 
			isMapStructure:1, 
			update_on:["toggle_range","toggle_waypoints",
					   "toggle_display_mode"],
			predicate: func(nd, layer) {
				var visible = nd.get_switch("toggle_waypoints") and 
					  nd.in_mode("toggle_display_mode", ["MAP"]) and 
					  (nd.rangeNm() <= 40);
				layer.group.setVisible( visible );
				if (visible)
					layer.update();
			}, # end of layer update predicate
			style: {
				color: [0.69, 0, 0.39],
				text_offset: [20,10],
				text_color: [1,1,1]
			},
			options: {
				draw_function: func(group){
					group.createChild("path")
					.moveTo(-10,0)
					.lineTo(0,-17)
					.lineTo(10,0)
					.lineTo(0,17)
					.close()
					.setStrokeLineWidth(3)
					.setColor(color)
					.setScale(1);
				}
			}
		}, # end of FIX layer
		{
			name: "ALT-profile",
			isMapStructure: 1,
			update_on: ["toggle_display_mode","toggle_range",{rate_hz: 2}],
			predicate: func(nd, layer) {
				var visible = nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]);# and nd.get_switch("toggle_fplan");
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			},
			style: {
				default_color: [1,1,1],
				armed_color: [0.06,0.55,1],
				managed_color: [0.68, 0, 0.38]
			},
			options: {
				# You can overwrite these with different nodes, before creating the ND	
				# Example: canvas.NDStyles["Airbus"].layers["ALT-profile"].options.vnav_node = "my/vnav/node";
				# In order to display ALT-profile on your ND you have to create the various
				# nodes corresponding to the different ALT pseudowaypoint in your aircraft code.
				# Every node must be set into the "vnav_node" configured here (you can override it).
				# Example: if you want to display the top-of-descent symbol you must create a "td" 
				# node into vnav_node. Something like this:
				#	/autopilot/route-manager/vnav/td/
				# Each node should have the latitude-deg and longitude-deg properties.
				# Available nodes are: 
				#	tc (top of climb)
				#	td (top of descent)
				#	ec (end of climb)
				#	ed (end of descent)
				#	sc (start of climb)
				#	sd (start of descent)
				# If ec and ed are altitude constraints, their node should have the 
				# boolean "alt-cstr" property set to 1.
				vnav_node: "/autopilot/route-manager/vnav/", 
				types: ["tc", "td", "ec", "ed","sc","sd"],
				svg_path: {
					tc: get_local_path("res/airbus_tc.svg"),
					td: get_local_path("res/airbus_td.svg"),
					ec: get_local_path("res/airbus_ec.svg"),
					ed: get_local_path("res/airbus_ed.svg"),
					sc: get_local_path("res/airbus_sc.svg"),
					sd: get_local_path("res/airbus_sd.svg")
				},
				listen: [
					"fplan_active",
					"ver_ctrl",
					"ap1",
					"ap2",
					"current_wp"
				],
				draw_callback: func(){
					var name = me.model.getName();
					var grp = me.element.getElementById(name~"_symbol");
					if(grp == nil) return;
					var dfcolor = me.getStyle("default_color");
					var armed_color = me.getStyle("armed_color");
					var managed_color = me.getStyle("managed_color");
					#print("Draw: -> " ~ name);
					if(name == "td" or name == "sd" or name == "sc"){
						var vnav_armed = me.model.getValue("vnav-armed");
						if(vnav_armed and name != "td")
							grp.setColor(armed_color);
						else
							grp.setColor(dfcolor);
					}
					elsif(name == "ed" or name == "ec"){
						var is_cstr = me.model.getValue("alt-cstr");
						if(is_cstr)
							grp.setColor(managed_color);
						else
							grp.setColor(armed_color);
					}
				},
				init_after_callback: func{
					var name = me.model.getName();
					var grp = me.element.getElementById(name~"_symbol");
					if(name != "td" and name != "sd" and name != "sc"){
						grp.setTranslation(-66,0);
					} 
				}
			}
		},
		{ 
			name:"APT", 
			isMapStructure:1, 
			update_on:["toggle_range","toggle_airports",
					"toggle_display_mode"],
			predicate: func(nd, layer) {
				var visible = nd.get_switch("toggle_airports") and 
					  nd.in_mode("toggle_display_mode", ["MAP"]);
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			}, # end of layer update predicate
			style: {
				svg_path: get_local_path("res/airbus_airport.svg"),
				text_offset: [45, 35],
				label_font_color: [1,1,1],
				label_font_size: 28
			}
		}, # end of APT layer
		{ 
			name:"VOR-airbus", 
			isMapStructure:1, 
			update_on:["toggle_range","toggle_vor","toggle_display_mode"],
			# FIXME: this is a really ugly place for controller code
			predicate: func(nd, layer) {
				# print("Running vor layer predicate");
				# toggle visibility here
				var visible = nd.get_switch("toggle_vor") and 
					  nd.in_mode("toggle_display_mode", ["MAP"]) and 
					  (nd.rangeNm() <= 40);
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			}, # end of layer update predicate
			# You can override default colors within the style
			# Default color: "color"
			# Tuned color: "tuned_color"
			# Example: 
			#  canvas.NDStyles["Airbus"].layers["VOR-airbus"].style.color = [1,1,1];
			#  canvas.NDStyles["Airbus"].layers["VOR-airbus"].style.tuned_color = [0,0,1];
			style: {},
			options:{
				listen: [
					"vor1_frq",
					"vor2_frq"
				]
			}
		}, # end of VOR layer
		{ 
			name:"DME", 
			disabled:1, 
			isMapStructure:1, 
			update_on:["toggle_display_mode","toggle_range","toggle_dme"],
			# FIXME: this is a really ugly place for controller code
			predicate: func(nd, layer) {
				var visible = nd.get_switch("toggle_dme") and 
					nd.in_mode("toggle_display_mode", ["MAP"]) and 
					(nd.rangeNm() <= 40);
				# toggle visibility here
				layer.group.setVisible( visible );
				if (visible) {
					#print("Updating MapStructure ND layer: DME");
					layer.update();
				}
			}, # end of layer update predicate
			options: {
				draw_dme: func(sym){
					return sym.createChild("path")
					.moveTo(-13, 0)
					.arcSmallCW(13,13,0,26,0)
					.arcSmallCW(13,13,0,-26,0)
					.setStrokeLineWidth(2)
					.close();
				},
				draw_text: 1
			},
			style: {
				color_default: [0.9,0,0.47],
				color_tuned: [0,0.62,0.84],
			},
			"z-index": -2,
		}, # end of DME layer
		{ 
			name:"NDB", 
			isMapStructure:1, 
			update_on:["toggle_range","toggle_ndb","toggle_display_mode"],
			# FIXME: this is a really ugly place for controller code
			predicate: func(nd, layer) {
				var visible = nd.get_switch("toggle_ndb") and 
					  nd.in_mode("toggle_display_mode", ["MAP"]) and 
					  (nd.rangeNm() <= 40);
				# print("Running vor layer predicate");
				# toggle visibility here
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			}, # end of layer update predicate
			# You can override default colors within the style
			# Default color: "color"
			# Tuned color: "tuned_color"
			# Example: 
			#  canvas.NDStyles["Airbus"].layers["VOR-airbus"].style.color = [1,1,1];
			#  canvas.NDStyles["Airbus"].layers["VOR-airbus"].style.tuned_color = [0,0,1];
			style: {
				#svg_path: get_local_path("res/airbus_ndb.svg")
				svg_path: ""
			},
			options: {
				listen: [
					"adf1_frq",
					"adf2_frq"
				],
				init_after_callback: func{
					#me.element.removeAllChildren();
					me.text_ndb = me.element.createChild("text")
					.setDrawMode( canvas.Text.TEXT )
					.setText(me.model.id)
					.setFont("LiberationFonts/LiberationSans-Regular.ttf")
					.setFontSize(28)
					.setTranslation(25,10);
					me.ndb_sym = me.element.createChild("path");
					me.ndb_sym.moveTo(-15,15)
					.lineTo(0,-15)
					.lineTo(15,15)
					.close()
					.setStrokeLineWidth(3)
					.setColor(0.69,0,0.39)
					.setScale(1,1);
				},
				draw_callback: func{
					var frq = me.model.frequency;
					if(frq != nil){
						var dfcolor = me.getStyle("color", [0.9,0,0.47]);
						var tuned_color = me.getStyle("tuned_color", [0,0.62,0.84]);
						frq = frq / 100;
						var adf1_frq = getprop(me.options.adf1_frq);
						var adf2_frq = getprop(me.options.adf2_frq);
						if(adf1_frq == frq or adf2_frq == frq){
							me.element.setColor(tuned_color, [Path]);
						} else {
							me.element.setColor(dfcolor, [Path]);
						}
					}
				},
			}
		}, # end of NDB layer
		{ 
			name:"TFC", 
			#disabled:1, 
			always_update: 1,
			isMapStructure:1, 
			update_on:["toggle_range","toggle_traffic"],
			predicate: func(nd, layer) {
				var visible = nd.get_switch("toggle_traffic");
				layer.group.setVisible( visible );
				if (visible) {
					#print("Updating MapStructure ND layer: TFC");
					layer.update();
				}
			}, # end of layer update predicate
		}, # end of traffic  layer
		{ 
			name:"RWY-profile", 
			isMapStructure:1, 
			update_on:["toggle_range","toggle_display_mode"],
			predicate: func(nd, layer) {
				var visible = (nd.rangeNm() <= 40) and 
						nd.in_mode("toggle_display_mode", ["MAP","PLAN"]) ;
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			}, # end of layer update predicate
			options: {
				listen: [
					"fplan_active",
					"dep_rwy",
					"dest_rwy"
				]
			}
		}, # end of runway layer
		{ 
			name:"HOLD", 
			isMapStructure: 1,
			always_update: 1,
			update_on:["toggle_range","toggle_display_mode","toggle_wpt_idx"],
			predicate: func(nd, layer) {
				var visible= nd.in_mode("toggle_display_mode", ["MAP","PLAN"]);
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			},
			options: {
				hold_node: "/flight-management/hold",
				hold_init: "flight-management/hold/init",
				points_node: "/flight-management/hold/points",
				first_point_node: "/flight-management/hold/points/point/lat",
				hold_wp: "/flight-management/hold/wp",
				hold_wp_idx: "/flight-management/hold/wp_id",
				range_dependant: 1,
				listen: [
					"first_point_node",
					"fplan_active",
					"lat_ctrl",
					"current_wp",
					"hold_wp",
					"hold_init",
					"hold_wp_idx"
				]
			}
			# end of layer update predicate
		}, # end of HOLD layer
		{ 
			name:"RTE", 
			isMapStructure: 1,
			update_on:["toggle_range","toggle_display_mode", "toggle_cstr",
				   "toggle_wpt_idx"],
			predicate: func(nd, layer) {
				var visible= (nd.in_mode("toggle_display_mode", ["MAP","PLAN"]));
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			}, # end of layer update predicate
			options: {
				display_inactive_rte: 1,
				listen: [
					"fplan_active",
					"lat_ctrl",
					"current_wp",
					"wp_count"
				],
				draw_after_callback: func{
					me.setRouteStyle();
				}
			},
			style: {
				line_width: 5,
				#inactive_color: [0.95,0.95,0.21],
				#active_color: [0.4,0.7,0.4],
				color: func{
					if(!contains(me, "inactive_color")){
						me.inactive_color = me.getStyle("inactive_color");
						if(me.inactive_color == nil)
							me.inactive_color = me.getOption("inactive_route_color");
					}
					if(!contains(me, "active_color")){
						me.active_color = me.getStyle("active_color"); 
						if(me.active_color == nil)
							me.active_color = me.getOption("active_route_color");
					}
					var is_active = getprop(me.options.fplan_active);
					(is_active ? me.active_color : me.inactive_color);
				},
				color_alternate_active: [0,0.62,0.84],
				color_missed: [0,0.62,0.84],
				color_temporary: func me.getStyle("inactive_color", me.getOption("inactive_route_color")),
				color_secondary: [1,1,1],
				color_alternate_secondary: [1,1,1],
				line_dash: func{
					var lat_ctrl = getprop(me.options.lat_ctrl);
					var is_managed = (lat_ctrl == me.options.managed_val);
					var is_active = getprop(me.options.fplan_active);
					(is_managed and is_active ? [] : [32, 16]);
				},
				line_dash_alternate_active: [32,16],
				line_dash_temporary: [32,16],
				line_dash_original: [32,16]
			}
		}, # end of route layer
		{ 
			name:"WPT-airbus", 
			isMapStructure: 1,
			update_on:["toggle_range","toggle_display_mode", "toggle_cstr",
				   "toggle_wpt_idx"],
			style: {
				wp_color: [0.4,0.7,0.4],
				current_wp_color: [1,1,1],
				constraint_color: [1,1,1],
				active_constraint_color: [0.69,0,0.39],
				missed_constraint_color: [1,0.57,0.14]
			},
			predicate: func(nd, layer) {
				var visible= (nd.in_mode("toggle_display_mode", ["MAP","PLAN"]));
				layer.group.setVisible( visible );
				if (visible) {
					layer.toggle_cstr = nd.get_switch("toggle_cstr");
					layer.update();
				}
			}, # end of layer update predicate
			options: {
				listen: [
					"fplan_active",
					"lat_ctrl",
					"ver_ctrl",
					"current_wp",
					"wp_count",
					"dep_rwy",
					"dest_rwy",
					"level_off_alt"
				],
			}
		}, # end of WPT layer
		{
			name: "SPD-profile",
			isMapStructure: 1,
			update_on: ["toggle_display_mode","toggle_range",{rate_hz: 2}],
			predicate: func(nd, layer) {
				var visible = nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]);
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			},
			style: {
				color: [0.69,0,0.39]
			},
			options: {
				spd_node: "/autopilot/route-manager/spd/",
				listen: [
					"fplan_active"
				]
			}
		},
		{
			name: "DECEL",
			isMapStructure: 1,
			update_on: ["toggle_display_mode","toggle_range"],
			predicate: func(nd, layer) {
				var visible = nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]);
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			},
			options: {
				# Overridable options:
				# decel_node: node containing latitude-deg and longitude-deg used to mark the deceleration point
				# managed_speed_node: boolean property indicating that the aircraft is flying in managed speed mode
				listen: [
					"fplan_active",
					"spd_ctrl",
					"ver_ctrl",
					"athr"
				]
			},
			style: {
				# managed_color: decelaration symbol color when the aircraft flies in managed speed mode
				# selected_color: decelaration symbol color when the aircraft flies in selected speed mode
				managed_color: [0.68, 0, 0.38],
				selected_color: [1,1,1]
			}
		},
		{ 
			name:"APS", 
			isMapStructure:1, 
			always_update: 1,
			update_on:["toggle_display_mode"], 
			predicate: func(nd, layer) {
				 var visible = nd.get_switch("toggle_display_mode") == "PLAN";
				 layer.group.setVisible( visible );
				 if (visible) {
					layer.update();
				 }
			},
			style: {
				svg_path: get_local_path("res/airbusAirplane.svg"),
				#translate: [-45,-52]
			},
			options: {
				model: {
					parents: [geo.Coord],
					id: 999999,
					pos: props.globals.getNode("position"),
					type: "position",
					latlon: func(){ 
						me.pos = props.globals.getNode("position");
						return [
							me.pos.getValue("latitude-deg"),
							me.pos.getValue("longitude-deg"),
							me.pos.getValue("altitude-ft")
						];
					},
					equals: func(o){me.id == o.id}
				},
				init_after_callback: func{
					var aplSymbol = me.element.getElementById("airplane");
					aplSymbol.setTranslation(-45,-52);
				}
			}
		},
		{
			name: "DEBUG",
			isMapStructure: 1,
			always_update: 1,
			update_on: ["toggle_display_mode"],
			predicate: func(nd, layer){
				var map_mode = nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]);
				var debug_actv = getprop("autopilot/route-manager/debug/active") or 0;
				var visible = (map_mode and debug_actv);
				layer.group.setVisible( visible );
				if (visible) {
					layer.update();
				}
			}
		}

		## add other layers here, layer names must match the registered names as used in *.layer files for now
		## this will all change once we"re using Philosopher"s MapStructure framework

	], # end of vector with configured layers

	# This is where SVG elements are configured by providing "behavior" hashes, i.e. for animations

	# to animate each SVG symbol, specify behavior via callbacks (predicate, and true/false implementation)
	# SVG identifier, callback	etc
	# TODO: update_on([]), update_mode (update() vs. timers/listeners)
	# TODO: support putting symbols on specific layers
	features: [
		{
			id: "compass_mask",
			impl: {
			init: func(nd, symbol),
				predicate: func(nd) !nd.get_switch("toggle_centered"),
				is_true: func(nd) nd.symbols.compass_mask.show(),
				is_false: func(nd) nd.symbols.compass_mask.hide(),
			}
		},
		{
			id: "compass_mask_ctr",
			impl: {
			init: func(nd, symbol),
				predicate: func(nd) nd.get_switch("toggle_centered") or nd.in_mode("toggle_display_mode",["PLAN"]),
				is_true: func(nd) nd.symbols.compass_mask_ctr.show(),
				is_false: func(nd) nd.symbols.compass_mask_ctr.hide(),
			}
		},
		#{
		#	# TODO: taOnly doesn"t need to use getprop polling in update(), use a listener instead!
		#	id: "taOnly", # the SVG ID
		#	impl: { # implementation hash
		#		init: func(nd, symbol), # for updateCenter stuff, called during initialization in the ctor
		#		predicate: func(nd) getprop("instrumentation/tcas/inputs/mode") == 2, # the condition
		#		is_true:   func(nd) nd.symbols.taOnly.show(),			# if true, run this
		#		is_false:  func(nd) nd.symbols.taOnly.hide(),			# if false, run this
		#	}, # end of taOnly	behavior/callbacks
		#}, # end of taOnly
		{
			id: "tas",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.aircraft_source.get_spd() > 100,
				is_true: func(nd) {
					nd.symbols.tas.setText(sprintf("%3.0f",getprop("/instrumentation/airspeed-indicator/true-speed-kt") ));
					nd.symbols.tas.show();
				},
				is_false: func(nd) nd.symbols.tas.hide(),
			},
		},
		{
			id: "tasLbl",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.aircraft_source.get_spd() > 100,
				is_true: func(nd) nd.symbols.tasLbl.show(),
				is_false: func(nd) nd.symbols.tasLbl.hide(),
			},
		},
		#{
		#	id: "wpActiveCrs",
		#	impl: {
		#		init: func(nd,symbol),
		#		predicate: func(nd) getprop("/autopilot/route-manager/wp/id") != nil and 
		#				getprop("autopilot/route-manager/active") and 
		#				nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]),
		#		is_true: func(nd) {
		#			#var cur_wp = getprop("autopilot/route-manager/current-wp");
		#			var deg = int(getprop("/autopilot/route-manager/wp/bearing-deg"));
		#			nd.symbols.wpActiveCrs.setText(""~deg~"°");
		#			nd.symbols.wpActiveCrs.show();
		#		},
		#		is_false: func(nd) nd.symbols.wpActiveCrs.hide(),
		#	}, # of wpActiveId.impl
		#}, # of wpActiveId
		#{
		#	id: "wpActiveDist",
		#	impl: {
		#		init: func(nd,symbol),
		#		predicate: func(nd) getprop("/autopilot/route-manager/wp/dist") != nil and 
		#				getprop("autopilot/route-manager/active") and 
		#				nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]),
		#		is_true: func(nd) {
		#			var dst = getprop("/autopilot/route-manager/wp/dist");
		#			nd.symbols.wpActiveDist.setText(sprintf("%3.01f",dst));
		#			nd.symbols.wpActiveDist.show();
		#		},
		#		is_false: func(nd) nd.symbols.wpActiveDist.hide(),
		#	},
		#},
		#{
		#	id: "wpActiveDistLbl",
		#	impl: {
		#		init: func(nd,symbol),
		#		predicate: func(nd) getprop("/autopilot/route-manager/wp/dist") != nil and getprop("autopilot/route-manager/active")  and nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]),
		#		is_true: func(nd) {
		#			nd.symbols.wpActiveDistLbl.show();
		#			if(getprop("/autopilot/route-manager/wp/dist") > 1000)
		#				nd.symbols.wpActiveDistLbl.setText("   NM");
		#		},
		#		is_false: func(nd) nd.symbols.wpActiveDistLbl.hide(),
		#	},
		#},
		{
			id: "eta",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) getprop("autopilot/route-manager/wp/eta") != nil and getprop("autopilot/route-manager/active")	and nd.in_mode("toggle_display_mode", ["MAP", "PLAN"]),
				is_true: func(nd) {
					var etaSec = getprop("/sim/time/utc/day-seconds")+
						getprop("autopilot/route-manager/wp/eta-seconds");
					var h = math.floor(etaSec/3600);
					etaSec = etaSec-3600*h;
					var m = math.floor(etaSec/60);
					etaSec = etaSec-60*m;
					var s = etaSec / 10;
					if (h > 24) h = h - 24;
					nd.symbols.eta.setText(sprintf("%02.0f:%02.0f",h,m));
					nd.symbols.eta.show();
				},
				is_false: func(nd) nd.symbols.eta.hide(),
			},	# of eta.impl
		}, # of eta
		{
			id: "gsGroup",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP"]),
				is_true: func(nd) {
					if(nd.get_switch("toggle_centered"))
						nd.symbols.gsGroup.setTranslation(0,0);
					else
						nd.symbols.gsGroup.setTranslation(0,150);
					nd.symbols.gsGroup.show();
				},
				is_false: func(nd) nd.symbols.gsGroup.hide(),
			},
		},
		{
			id:"hdg",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP","MAP","VOR"]),
				is_true: func(nd) {
					var hdgText = "";
					if(nd.in_mode("toggle_display_mode", ["MAP"])) {
						if(nd.get_switch("toggle_true_north"))
							hdgText = nd.aircraft_source.get_trk_tru();
						else
							hdgText = nd.aircraft_source.get_trk_mag();
					} else {
						if(nd.get_switch("toggle_true_north"))
							hdgText = nd.aircraft_source.get_hdg_tru();
						else
							hdgText = nd.aircraft_source.get_hdg_mag();
					}
					nd.symbols.hdg.setText(sprintf("%03.0f", hdgText+0.5));
				},
				is_false: NOTHING,
			},
		},
		{
			id:"hdgGroup",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) {return 0},#nd.in_mode("toggle_display_mode", ["APP","MAP","VOR"]),
				is_true: func(nd) {
					nd.symbols.hdgGroup.show();
					if(nd.get_switch("toggle_centered"))
						nd.symbols.hdgGroup.setTranslation(0,100);
					else
						nd.symbols.hdgGroup.setTranslation(0,0);
				},
				is_false: func(nd) nd.symbols.hdgGroup.hide(),
			},
		},
		#{
		#	id:"altArc",
		#	impl: {
		#		init: func(nd,symbol),
		#		predicate: func(nd) {return 0},#nd.in_mode("toggle_display_mode", ["APP","MAP","VOR"]),
		#		is_true: func(nd) {
		#			nd.symbols.altArc.show();
		#		},
		#		is_false: func(nd) nd.symbols.altArc.hide(),
		#	},
		#},
		{
			id:"gs",
			impl: {
				init: func(nd,symbol),
				common: func(nd) nd.symbols.gs.setText(sprintf("%3.0f",nd.aircraft_source.get_gnd_spd() )),
				predicate: func(nd) nd.aircraft_source.get_gnd_spd() >= 30,
				is_true: func(nd) {
					#nd.symbols.gs.show();
					nd.symbols.gs.setFontSize(36);
				},
				is_false: func(nd) {},#nd.symbols.gs.hide(),
			},
		},
		{
			id:"navsource",
			impl: {
				init: func(nd,symbol),
				common: func(nd) {
					nd.symbols.navsource.setText(getprop("/it-autoflight/settings/nav-source") or "");;
				},
			},
		},
		{
			id:"freqname",
			impl: {
				init:func(nd,symbol),
				common: func(nd) {
						var navsource=getprop("/it-autoflight/settings/nav-source") or "";
						if(navsource=="FMS"){
							nd.symbols.freqname.setText(getprop("/autopilot/route-manager/wp/id") or "XXX");
						}else if(navsource=="NAV1"){
							nd.symbols.freqname.setText(sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz") or 0));
						}else if(navsource=="NAV2"){
							nd.symbols.freqname.setText(sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz") or 0));
						}else{
							nd.symbols.freqname.hide();
						}
				},
			},
		},
		{
			id:"dist",
			impl: {
				init:func(nd,symbol),
				common: func(nd) {
						var navsource=getprop("/it-autoflight/settings/nav-source") or "";
						if(navsource=="FMS"){
							nd.symbols.dist.setText(getprop("/autopilot/route-manager/wp/dist") or "XXX");
						}else if(navsource=="NAV1"){
							var dist=getprop("/instrumentation/nav[0]/nav-distance");
							if(dist!=nil){
								dist=dist*M2NM;
								if(dist<100){
									nd.symbols.dist.setText(sprintf("%2.1f", dist));
								}else{
									nd.symbols.dist.setText(sprintf("%3d", dist));
								}
							}else{
								nd.symbols.dist.hide();
							}
						}else if(navsource=="NAV2"){
							var dist=getprop("/instrumentation/nav[1]/nav-distance");
							if(dist!=nil){
								dist=dist*M2NM;
								if(dist<100){
									nd.symbols.dist.setText(sprintf("%2.1f", dist));
								}else{
									nd.symbols.dist.setText(sprintf("%3d", dist));
								}
							}else{
								nd.symbols.dist.hide();
							}
						}else{
							nd.symbols.dist.hide();
						}
				},
			},
		},
		{
			id:"compass",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) (!nd.get_switch("toggle_centered") and	nd.get_switch("toggle_display_mode") != "PLAN"),
				is_true: func(nd) {
					nd.symbols.compass.setRotation(-nd.userHdgTrk*D2R);
					nd.symbols.compass.show()
				},
				is_false: func(nd) nd.symbols.compass.hide(),
			}, # of compass.impl
		}, # of compass
		{
			id:"compassApp",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) (nd.get_switch("toggle_centered") and  nd.get_switch("toggle_display_mode") != "PLAN"),
				is_true: func(nd) {
					nd.symbols.compassApp.setRotation(-nd.userHdgTrk*D2R);
					nd.symbols.compassApp.show()
				},
				is_false: func(nd) nd.symbols.compassApp.hide(),
			}, # of compassApp.impl
		}, # of compassApp
		{
			id:"northUp",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.get_switch("toggle_display_mode") == "PLAN",
				is_true: func(nd) nd.symbols.northUp.show(),
				is_false: func(nd) nd.symbols.northUp.hide(),
			}, # of northUp.impl
		}, # of northUp
		{
			id:"planArcs",
			impl: {
			init: func(nd,symbol),
				predicate: func(nd) ((nd.in_mode("toggle_display_mode", ["APP","VOR","PLAN"])) or ((nd.get_switch("toggle_display_mode") == "MAP") and (nd.get_switch("toggle_centered")))),
				is_true: func(nd) nd.symbols.planArcs.show(),
				is_false: func(nd) nd.symbols.planArcs.hide(),
			}, # of planArcs.impl
		}, # of planArcs
		{
			id:"rangeArcs",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) ((nd.get_switch("toggle_display_mode") == "MAP") and (!nd.get_switch("toggle_centered"))),
				is_true: func(nd) nd.symbols.rangeArcs.show(),
				is_false: func(nd) nd.symbols.rangeArcs.hide(),
			}, # of rangeArcs.impl
		}, # of rangeArcs
		{
			id:"rangePln1",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) {return 0},
				is_true: func(nd) {
					nd.symbols.rangePln1.show();
					nd.symbols.rangePln1.setText(sprintf("%3.0f",nd.rangeNm()));
				},
				is_false: func(nd) nd.symbols.rangePln1.hide(),
			},
		},
		{
			id:"rangePln3",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.get_switch("toggle_display_mode") == "PLAN" or nd.get_switch("toggle_centered"),
				is_true: func(nd) {
					nd.symbols.rangePln3.show();
					nd.symbols.rangePln3.setText(sprintf("%3.0f",nd.rangeNm()/2));
				},
				is_false: func(nd) nd.symbols.rangePln3.hide(),
			},
		},
		{
			id:"rangePln4",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.get_switch("toggle_display_mode") == "PLAN" or nd.get_switch("toggle_centered"),
				is_true: func(nd) {
					nd.symbols.rangePln4.show();
					nd.symbols.rangePln4.setText(sprintf("%3.0f",nd.rangeNm()));
				},
				is_false: func(nd) nd.symbols.rangePln4.hide(),
			},
		},
		{
			id:"range",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) !nd.get_switch("toggle_centered"),
				is_true: func(nd) {
					nd.symbols.range.show();
					nd.symbols.range.setText(sprintf("%3.0f",nd.rangeNm()/2));
				},
				is_false: func(nd) nd.symbols.range.hide(),
			},
		},
		{
			id:"aplSymMap",
			impl: {
			init: func(nd,symbol),
				predicate: func(nd) (nd.get_switch("toggle_display_mode") == "MAP" and !nd.get_switch("toggle_centered")),
				is_true: func(nd) {
					nd.symbols.aplSymMap.set("z-index", 10);
					nd.symbols.aplSymMap.show();

				},
				is_false: func(nd) nd.symbols.aplSymMap.hide(),
			},
		},
		{
			id:"aplSymMapCtr",
			impl: {
			init: func(nd,symbol),
				predicate: func(nd) ((nd.get_switch("toggle_display_mode") == "MAP" and nd.get_switch("toggle_centered")) or nd.in_mode("toggle_display_mode", ["APP","VOR"])),
				is_true: func(nd) {
					nd.symbols.aplSymMapCtr.set("z-index", 10);
					nd.symbols.aplSymMapCtr.show();

				},
				is_false: func(nd) nd.symbols.aplSymMapCtr.hide(),
			},
		},
		{
			id:"crsLbl",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP","VOR"]),
				is_true: func(nd) nd.symbols.crsLbl.show(),
				is_false: func(nd) nd.symbols.crsLbl.hide(),
			},
		},
		{
			id:"crs",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP","VOR"]),
				is_true: func(nd) {
					nd.symbols.crs.show();
					var is_ils = (nd.get_switch("toggle_display_mode") == "APP");
					var type = (is_ils ? "ils" : "vor");
					var path = nd.get_nav_path(type, 0);
					var crs = getprop(path~ "radials/selected-deg");
					if(crs != nil)
						nd.symbols.crs.setText(sprintf("%03.0f", crs~"°"));
				},
				is_false: func(nd) nd.symbols.crs.hide(),
			},
		},
		{
			id:"dmeLbl",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP","VOR"]),
				is_true: func(nd) nd.symbols.dmeLbl.show(),
				is_false: func(nd) nd.symbols.dmeLbl.hide(),
			},
		},
		#{
		#	id:"dme",
		#	impl: {
		#		init: func(nd,symbol),
		#		predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP","VOR"]),
		#		is_true: func(nd) {
		#			nd.symbols.dme.show();
		#			var is_ils = (nd.get_switch("toggle_display_mode") == "APP");
		#			var type = (is_ils ? "ils" : "vor");
		#			var path = nd.get_nav_path(type, 0);
		#			nd.symbols.dme.setText(getprop(path~ "nav-id"));
		#			if(is_ils)
		#				nd.symbols.dme.setColor(0.69,0,0.39);
		#			else
		#				nd.symbols.dme.setColor(1,1,1);
		#		},
		#		is_false: func(nd) nd.symbols.dme.hide(),
		#	},
		#},
		{
			id:"vorCrsPtr",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) (nd.in_mode("toggle_display_mode", ["APP","VOR"]) and !nd.get_switch("toggle_centered")),
				is_true: func(nd) {
					nd.symbols.vorCrsPtr.show();
					if (is_ils) {
						nd.symbols.vorCrsPtr.setRotation((getprop("instrumentation/nav[0]/radials/selected-deg")-nd.aircraft_source.get_hdg_mag())*D2R);
					} else {
						nd.symbols.vorCrsPtr.setRotation((getprop("instrumentation/nav[2]/radials/selected-deg")-nd.aircraft_source.get_hdg_mag())*D2R);
					}

				},
				is_false: func(nd) nd.symbols.vorCrsPtr.hide(),
			},
		},
		{
			id: "gsDiamond",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) nd.in_mode("toggle_display_mode", ["APP"]),
				is_true: func(nd) {
					if(getprop("instrumentation/nav/gs-needle-deflection-norm") != nil)
						nd.symbols.gsDiamond.setTranslation(getprop("/instrumentation/nav[0]/gs-needle-deflection-norm")*150,0);
				},
				is_false: func(nd) nd.symbols.gsGroup.hide(),
			},
		},
		{
			id:"wind",
			impl: {
				init: func(nd,symbol),
				predicate: ALWAYS,
				is_true: func(nd) {
					nd.symbols.wind.setText(sprintf("%02.0f",getprop("environment/wind-speed-kt")));
				},
				is_false: NOTHING,
			},
		},
		{
			id:"windArrow",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) (!(nd.in_mode("toggle_display_mode", ["PLAN"]) and (nd.get_switch("toggle_display_type") == "LCD"))),
				is_true: func(nd) {
					nd.symbols.windArrow.show();
					var windArrowRot = getprop("environment/wind-from-heading-deg");
					if(nd.in_mode("toggle_display_mode", ["MAP","PLAN"])) {
						if(nd.get_switch("toggle_true_north"))
							windArrowRot = windArrowRot - nd.aircraft_source.get_trk_tru();
						else
							windArrowRot = windArrowRot - nd.aircraft_source.get_trk_mag();
					} else {
						if(nd.get_switch("toggle_true_north"))
							windArrowRot = windArrowRot - nd.aircraft_source.get_hdg_tru();
						else
							windArrowRot = windArrowRot - nd.aircraft_source.get_hdg_mag();
					}
					nd.symbols.windArrow.setRotation(windArrowRot*D2R);
				},
				is_false: func(nd) nd.symbols.windArrow.hide(),
			},
		},
		{
			id:"appMode",
			impl: {
				init: func(nd,symbol),
				predicate: func(nd) {
					var mode = getprop(nd.options.defaults.app_mode);
					return (mode != "" and mode != nil);
				},
				is_true: func(nd) {
					var mode = getprop(nd.options.defaults.app_mode);
					nd.symbols.appMode.show();
					nd.symbols.appMode.setText(mode);
				},
				is_false: func(nd){
					nd.symbols.appMode.hide();
				}
			}  
		},
		#Bottom (System) Part
		{
			id: "Relev",
			impl: {
				init: func(nd,symbol),
				predicate: ALWAYS,
				is_true: func(nd) {
					var elevator=getprop("fdm/jsbsim/hydraulics/elevators/final") or 0;
					if(elevator>0){
						nd.symbols.Relev.setRotation(elevator*(0.01744)*30);
					}else if(elevator<0){
						nd.symbols.Relev.setRotation(elevator*(0.01744)*43);
					}
				},
				is_false: NOTHING,
			},
		},
		{
			id: "Lelev",
			impl: {
				init: func(nd,symbol),
				predicate: ALWAYS,
				is_true: func(nd) {
					var elevator=getprop("fdm/jsbsim/hydraulics/elevators/final") or 0;
					if(elevator>0){
						nd.symbols.Lelev.setRotation(elevator*(-0.01744)*30);
					}else if(elevator<0){
						nd.symbols.Lelev.setRotation(elevator*(-0.01744)*43);
					}
				},
				is_false: NOTHING,
			},
		},
		{
			id: "rudder",
			impl: {
				init: func(nd,symbol),
				predicate: ALWAYS,
				is_true: func(nd) {
					nd.symbols.rudder.setRotation((getprop("fdm/jsbsim/fcs/yaw-sum-lag") or 0)*(-0.01744)*41.4);
				},
				is_false: NOTHING,
			},
		},
	], # end of vector with features

};

