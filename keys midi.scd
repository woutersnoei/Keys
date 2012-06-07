(
// midi support for Keys

MIDIWindow(true);

~keys.midiFunc.remove;
~keys.midiFunc = MIDIFunc.cc({ |val, cc, chan| 
	~keys.midiRespond( val, cc, chan ) 
}).permanent_( true );

(
~keys.midiMap = [
	[ \keyamp, 10, 0 ], // pan ch 1
	[ \keyTexture, 7, 0 ], // volume ch 1-8
	[ \noise1, 7, 1 ],
	[ \noise2, 7, 1 ],
	[ \noise3, 7, 1 ],
	[ \loop1, 7, 2 ],
	[ \loop2, 7, 2 ],
	[ \loop3, 7, 2 ],
	[ \specFreeze, 7, 3 ],
	[ \player, 7, 4 ],
	[ \binScramble, 7, 5 ],
	[ \fastFreeze, 7, 6 ],
	[ \keyLoop, 7, 7 ],
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
)

/*
~keys.midiFunc.remove
*/