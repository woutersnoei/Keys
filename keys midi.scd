(
// midi support for Keys

MIDIWindow(true);

~keys.midiFunc.remove;
~keys.midiFunc = MIDIFunc.cc({ |val, cc, chan| 
	~keys.midiRespond( val, cc, chan ) 
}).permanent_( true );

(
~keys.midiMap = [
	[ \keyamp, 9, 1 ], // pan ch 1
	[ \keyTexture, 1, 1 ], // volume ch 1-8
	[ \noise1, 2, 1 ],
	[ \noise2, 2, 1 ],
	[ \noise3, 2, 1 ],
	[ \loop1, 3, 1 ],
	[ \loop2, 3, 1 ],
	[ \loop3, 3, 1 ],
	[ \specFreeze, 4, 1 ],
	[ \player, 5, 1 ],
	[ \binScramble, 6, 1 ],
	[ \fastFreeze, 7, 1 ],
	[ \keyLoop, 8, 1 ],
];
);
		
~keys.midiSpec = \amp.asSpec;

~keys.midiRespond = { |evt, val, cc, chan|
	evt.midiMap.select({ |item|
		(item[1] == cc) && { item[2] == chan }
	}).do({ |item|
		evt[ item[0] ].amp = evt.midiSpec.map( val/127 );
	});
};

~keys.ccRange = [inf,0];
~keys.midiMap.do({ |item|
	~keys.ccRange =[ ~keys.ccRange[0].min(item[1]), ~keys.ccRange[1].max(item[1]) ];
});

~keys.midiMap.do({ |item|
	~keys.views.amps[ item[0] ].sliderView.string = "ch %,   cc %".format( item[2], item[1] );
	~keys.views.amps[ item[0] ].sliderView.hiliteColor = Gradient( Color.gray(0.9).alpha_(0.5), Color.gray(0.5).alpha_(0.5), \h ) ;
	~keys.views.amps[ item[0] ].sliderView.background = Color.hsv( item[1].linlin(  *(~keys.ccRange ++ [0,1]) ), 0.7, 0.9).alpha_(0.6);
});


)

/*
~keys.midiFunc.remove
*/