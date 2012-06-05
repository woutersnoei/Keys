(
~keys = ~keys ? EM();

~keys.keyTexture = ~keys.keyTexture ? EM();

~keys.keyTexture.buffer = Buffer.alloc( s, 44100 * 1 );

~keys.keyTexture.amp = 0.1;

#[ amp ].do({ |item|
	~keys.keyTexture[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.sn.set( item, value );
		};
	};
});

~keys.keyTexture.start = { |evt|
	evt.end;
	evt.active = true;
	~keys.recbuf.catch( evt.buffer, 0, { 
		if( evt.active ) {
			evt.sn = Synth( "keys_keyTexture", [ \amp, evt.amp, \bufnum, evt.buffer ] ).register;
		};
	}, 0.02, 0.125);
};

~keys.keyTexture.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};

~keys.keyTexture.toggle = { |evt|
	if( evt.active == true ) { evt.end } { evt.start };
};

(
SynthDef( "keys_keyTexture", { |amp = 0.1, bufnum = 0, gate = 1|
	var sig, n = 6, rate;
	var env;
	rate = Rand(-5.dup(n),2).midiratio;
	sig = n.collect({ 
		var sig;
		sig = PlayBufCF.ar( 1, bufnum, 
			LFDNoise3.kr(1).range(0.5,1) * Rand(-5,2).midiratio, 
			Dwhite(0.1,0.2),
			Dwhite( 0, BufFrames.kr(bufnum)), 
			loop: 1 
		) * 15.dbamp;
		sig = BLowCut.ar( sig, ExpRand(150, 500), 3 );
		sig = BHiCut.ar( sig, ExpRand(5000, 20000), 3 );
	});
	env = Env.cutoff(0.1).kr(2,gate);
	sig = Splay.ar( sig, levelComp: false) * amp * env;
	Out.ar( 0, sig );
}).load(s);	
);

)

/*
~keys.recbuf.start;

~keys.player.window.view.keyDownAction = { |doc, char, mod, ascii|
	if( char == $ ) { 
		~keys.keyTexture.toggle 
	};
};

*/