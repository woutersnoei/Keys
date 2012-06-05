// [ \processName ] or [ [ \processName, setter: value, setter: value etc ] ]

~keys = ~keys ? EM();

~keys.states = Order();
~keys.stateDict = ();

(
~keys.stateDict = ();
([
	// A
	[1,  [ \keyTexture ] ],
	[3,  [ \keyTexture ] ],
	[5,  [ [ \noise1, state: 0, attack: 0 ] ] ],
	[6,  [ \noise1, [ \noise2, state: 0, attack: 0  ] ] ],
	[7,  [ \noise1, \noise2, [ \noise3, state: 0, attack: 0 ] ] ],
	[8,  [ [ \noise1, state: 1, attack: 6 ], [ \noise2, state: 1, attack: 6 ], [ \noise3, state: 1, attack: 6 ] ] ],
	[9,  [ \loop1 ] ],
	[10, [ \loop1, \loop2 ] ],
	[11, [ \loop1, \loop2, \loop3 ] ],
	
	// B
	[12, [ \recFast ] ],
	[13, [ [ \specFreeze, shift1: 0, shift2: 0, pitch: #[3,-4], pitchtime: 1,
		hpf: 300, up: 0, gran: 0, filter: 0
	  ] ] ],
	[14, [ [ \specFreeze, shift1: 1 ] ] ],
	[15, [ [ \specFreeze, shift2: 1 ] ] ],
	[16, [ [ \specFreeze, hpf: 100 ] ] ],
	[17, [ [ \specFreeze, pitch: #[14, -15], pitchtime: 10 ] ] ],
	[18, [ [ \specFreeze, hpf: 50, gran: 1, pitchtime: 1 ] ] ],
	
	// C
	[19, [ [ \specFreeze, filter: 1 ], \player, \binScramble ] ],
	
	// D
	[20, [ [ \specFreeze, filter: 0, hpf: 100, shift1: 0, shift2: 0 ] ] ],
	[21, [ [ \specFreeze, shift1: 1 ] ] ],
	[22, [ [ \specFreeze, shift2: 1 ] ] ],
	[23, [ [ \specFreeze, hpf: 300 ] ] ],
	[24, [ [ \specFreeze, pitch: #[-0.25,0.18], pitchtime: 10 ] ] ],
	
	// E
	[25, [ [ \fastFreeze, setting: 0 ] ] ],
	[26, [ [ \fastFreeze, setting: 1 ], [ \keyLoop, setting: 0 ] ] ],
	[27, [ [ \keyLoop, setting: 1 ] ] ],
	[28, [ [ \keyLoop, setting: 2 ] ] ],
	[29, [ [ \keyLoop, setting: 3 ] ] ],
	[30, [ [ \keyLoop, setting: 4 ] ] ],
	[31, [ [ \keyLoop, setting: 5 ], [ \timeToNext, time: 50 ] ] ],
	[32, [ [ \keyLoop, setting: 6 ] ] ],
]
).do({ |item|
	var index, state;
	#index, state = item;
	state = state.collect({ |sub|
		var name, args;
		if( sub.size == 0 ) { 
			name = sub;
		} { 
			name = sub[0];
			args = sub[1..]; 
		};

			if( ~keys.stateDict.keys.includes(name).not ) {
				~keys.stateDict[ name ] = [];
			};
			args.pairsDo({ |key, value|
				var index;
				index = ~keys.stateDict[ name ].indexOf( key );
				if( index.notNil ) {
					~keys.stateDict[ name ][ index + 1 ] = value;
				} {
					~keys.stateDict[ name ] = ~keys.stateDict[ name ] ++ [ key, value ];
				};
			});
			args = ~keys.stateDict[ name ].copy;
		[ name ] ++ args;
	});
	~keys.states.put( 
		index, 
		state
	);
});
);


~keys.getStartAndEndItems = { |evt, index = 0|
	// returns:
	// [ [ items to start/continue ], [ items to end ] ]
	var activeItems;
	activeItems = evt.states[index].collect(_[0]) ? [];
	[ activeItems, evt.stateDict.keys.select({ |item| activeItems.includes( item ).not }).asArray.sort ];
};

~keys.setState = { |evt, index = 0|
	var startItems, endItems, settings;
	index = index.clip(0,evt.states.lastIndex+1);
	settings = evt.states[index];
	#startItems, endItems = evt.getStartAndEndItems( index );
	
	settings.do({ |setting|
		var item;
		item = setting[0];
		setting[1..].pairsDo({ |key, value|
			if( evt[ item ].notNil ) {
				evt[ item ].perform( key.asSetter, value );
			} {
				"~keys['%'].%_(%); // item not found".format( item, key, value ).postln;
			};
		});
	});
	
	endItems.do({ |item|
		if( evt[ item ].notNil ) {
			evt[ item ].end;
		} {
			"~keys['%'].end; // item not found".format( item ).postln;
		};
	});
	
	startItems.do({ |item|
		if( evt[ item ].notNil ) {
			evt[ item ].start;
		} {
			"~keys['%'].start; // item not found".format( item ).postln;
		};
	});
	
	evt.currentState = index;
};

~keys.nextState = { |evt, amount = 1|
	evt.setState( (evt.currentState ? 0) + amount );
	evt.currentState;
};


~keys.timeToNext = ~keys.timeToNext ? EM();

~keys.timeToNext.time = 50;

~keys.timeToNext.start = { |evt|
	evt.end;
	evt.task = Task({
		var i = 0;
		while { i < evt.time } {
			i = i+1;
			"next cue in % of % seconds".format( evt.time - i, evt.time ).postln;
			1.wait;
		};
		~keys.nextState;
	}).start;
};

~keys.timeToNext.end = { |evt|
	evt.task.stop;
};

~keys.keyDownAction; // <- put actions in here

~keys.makeWindow = { |evt|
	var ctrl, views, nextFunc;
	
	~keys.window = Window("KEYS main window", Rect(300, 50, 400, 400)).front;
	
	nextFunc = ActionFunc( \wait, { |val = 1| ~keys.nextState(val); }, 0.15 );
	
	~keys.window.view.keyDownAction = { |doc, char, mod, ascii|
		if( char == $ ) { 
			nextFunc.value(1);
		};
		switch( ascii,
			63234, { nextFunc.value(-1); }, // arrow left
			63235, { nextFunc.value(1); }, // arrow right
			127, { ~keys.setState(0); } // backspace 
		);
		~keys.keyDownAction( char, mod, ascii );		
	};
	
	views = ();
	
	~keys.window.addFlowLayout;
	
	
	views[ \currentState ] = SmoothNumberBox(~keys.window, 100@40 )
		.autoScale_( true )
		.action_({ |nb|
			~keys.setState( nb.value );
			nb.focus( false );
		});
		
	views[ \status ] = StaticText(~keys.window, 400@40 );
	
	ctrl = SimpleController( ~keys )
		.put( \currentState, { 
			views[ \currentState ].value = ~keys.currentState ? 0;
			{ 	views[ \status ].string = "active: %".format( 
					(~keys.states[ ~keys.currentState ? 0 ].collect(_[0]) ? []).join( ", " )
				); 
			}.defer;
		});
		
	~keys.views = views;
	~keys.changed( \currentState );
	~keys.window.onClose_( { ctrl.remove; } );
};


~keys.makeWindow;

/*
~keys.nextState;

~keys.nextState(-1);
~keys.setState(19);
~keys.setState(24);

~keys.setState(0);

~keys.setState(5);

~keys.states;
~keys.stateDict;

~keys.player.window.view.keyDownAction = { |doc, char, mod, ascii|
	if( char == $ ) { 
		~keys.nextState;
		~keys.currentState.postln;
	};
	ascii.postln;
};
*/