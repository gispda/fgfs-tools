var abs = func(n) { n < 0 ? -n : n }

var magicAI_start = func {
	magic_autostart();
	flaps_manager();
	settimer(func(){
		setprop('/controls/lighting/landing-lights[0]', 0);
		setprop('/controls/lighting/landing-lights[1]', 0);
		setprop('/controls/lighting/landing-lights[2]', 0);
		setprop('/controls/lighting/taxi-lights', 1);
		setprop('/controls/lighting/beacon', 1);
		setprop('/controls/lighting/nav-lights', 0);
		setprop('/controls/lighting/strobe', 1);
		setprop('/controls/lighting/instrument-lights', 1);
		setprop('/controls/lighting/instruments-norm', 1);
		setprop('/controls/lighting/panel-lights', 1);
		setprop('/controls/lighting/panel-norm', 0.5);
		setprop('/controls/lighting/cabin-lights', 0);
		setprop('/controls/lighting/logo-lights', 0);
		setprop('/controls/lighting/wing-lights', 0);

		if (getprop('/yasim/gross-weight-lbs') > 980000) {
			setprop('/controls/flight/flaps', 0.833);
		} else {
			setprop('/controls/flight/flaps', 0.666);
		}
		setprop('/autopilot/settings/target-speed-kt', 290);
		setprop('/instrumentation/afds/inputs/at-armed', 1);
		setprop('/instrumentation/afds/inputs/lateral-index', 3);
		setprop('/instrumentation/afds/inputs/vertical-index', 5);
		setprop('/instrumentation/efis/inputs/lh-vor-adf', 1);

		#Begin takeoff
		settimer(func(){
			#for (i = 0; i < 12; i += 1) {
			#	setprop('/controls/engines/engine['~i~']/throttle', 1);
			#}
			setprop('/controls/gear/brake-parking', 0);
			magicAI_takeoff();
		}, 20);
	}, 2);
}
var flaps_manager = func {
	if (!getprop('/gear/on-ground') and getprop('/position/altitude-agl-ft') > 100) {
		var speed = getprop('/velocities/airspeed-kt');
		var flaps = getprop('/controls/flight/flaps');
		if (260 < speed and flaps != 0) {
			setprop('/controls/flight/flaps', 0);
		} else if (230 < speed and speed < 260 and flaps != 0.033) {
			setprop('/controls/flight/flaps', 0.033);
		} else if (205 < speed and speed < 230 and flaps != 0.166) {
			setprop('/controls/flight/flaps', 0.166);
		} else if (180 < speed and speed < 205 and flaps != 0.500) {
			setprop('/controls/flight/flaps', 0.500);
		} else if (170 < speed and speed < 180 and flaps != 0.666) {
			setprop('/controls/flight/flaps', 0.666);
		} else if (speed < 170 and flaps != 1.000) {
			setprop('/controls/flight/flaps', 1.000);
		}
	}
	settimer(flaps_manager, 1);
}
var magicAI_takeoff = func {
	if (!getprop('/gear/on-ground') and getprop('/position/altitude-agl-ft') > 40) {
		setprop('/controls/gear/gear-down', 0);
		setprop('/controls/lighting/taxi-lights', 0);
		setprop('/controls/lighting/logo-lights', 0);
		setprop('/controls/lighting/wing-lights', 0);
		setprop('/instrumentation/afds/inputs/vertical-index', 2);
		magicAI_climb();return;
	}
	settimer(magicAI_takeoff, 1);
}
var magicAI_climb = func {
	if (!getprop('/gear/on-ground') and getprop('/position/altitude-agl-ft') > 210) {
		setprop('/instrumentation/afds/inputs/autothrottle-index', 5);
		setprop('/instrumentation/afds/inputs/AP', 1);
		setprop('/autopilot/settings/vertical-speed-fpm', 1000);
		setprop('/controls/flight/rudder', 0);
		magicAI_start_cruise();return;
	}
	settimer(magicAI_climb, 1);
}

var vs_prev = 0;
var magicAI_start_cruise = func {
	var vs = getprop('/velocities/vertical-speed-fps') * 60;
	if (getprop('/position/altitude-agl-ft') > 2000 and 800 < vs and vs < 1200 and abs(vs - vs_prev) < 100) {
		setprop('/instrumentation/afds/inputs/vertical-index', 5);
		setprop('/controls/flight/elevator', 0);
		magicAI_cruise();return;
	}
	vs_prev = vs;
	settimer(magicAI_start_cruise, 1);
}
var magicAI_cruise = func {
	var route_remaining = getprop('/autopilot/route-manager/distance-remaining-nm');
	if (route_remaining < 22) {
		setprop('/autopilot/settings/vertical-speed-fpm', -1000);
		setprop('/autopilot/settings/target-speed-kt', 200);
		setprop('/instrumentation/afds/inputs/vertical-index', 5);
		setprop('/autopilot/settings/target-altitude-ft', getprop('/autopilot/settings/target-altitude-ft') - 2000);
		settimer(func(){
			setprop('/autopilot/locks/altitude', 'gs1-hold');
			setprop('/autopilot/locks/heading', 'nav1-hold');
			magicAI_landing();
		}, 0.5);
		return;
	}
	settimer(magicAI_cruise, 1);
}
var magicAI_landing = func {
	if (getprop('/instrumentation/afds/inputs/vertical-index') == 2) {
		setprop('/autopilot/settings/target-speed-kt', 160);
		return;
	}
	settimer(magicAI_landing, 1);
}

if (getprop('/sim/magicAI') == 1) {
	settimer(func(){
		setprop('/autopilot/pausemgr-dist', 5);
		magicAI_start();
	}, 3);
}
