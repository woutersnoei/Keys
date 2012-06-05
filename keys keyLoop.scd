(
~keys = ~keys ? EM();

~keys.keyLoop = ~keys.keyLoop ? EM();

~keys.keyLoop.amp = 0.5;
~keys.keyLoop.combamt = 0;
~keys.keyLoop.combdecay = 0.1;
~keys.keyLoop.speed = 1;



#[ amp, combamt, combdecay, speed ].do({ |item|
	~keys.keyLoop[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.synthdict.do(_.set( item, value ));
		};
	};
});

~keys.keyLoop.settings = [
	(speed: 1, combamt: 0, combdecay: 0.1, endSynths: true ),
	(speed: 1, combamt: 0.5, combdecay: 0.1, endSynths: true ),
	(speed: 1, combamt: 0.75, combdecay: 0.4,  endSynths: true ),
	(speed: 1, combamt: 1, combdecay: 1,  endSynths: true ),
	(speed: 5, combamt: 1, combdecay: 4 ),
	(speed: 0.1, combamt: 1, combdecay: 12 ),
	(speed: 0,  combamt: 1, combdecay: 12 )
];

~keys.keyLoop.setting = 0;

~keys.keyLoop.setting_ = { |evt, value = 0|
	var setting;
	setting = evt.settings[ value ];
	evt[ \setting ] = value;
	if( setting.notNil ) {
		setting.keysValuesDo({ |key, value|
			evt.perform( key.asSetter, value );
		});
	};
};

~keys.keyLoop.synthdict = ();

~keys.keyLoop.bufdict = ();

"abcdefghijklmnopqrstuvwxyz1234567890".do({ |char|
	~keys.keyLoop.bufdict.put( char, Buffer.alloc( s, 44100 * 0.2 ) );
});

~keys.keyLoop.keyDownAction = { |vw, char|
	var buf;
	buf = ~keys.keyLoop.bufdict[ char ];
	if( buf.notNil ) {
		{ 	
			0.16.wait; 
			if( ~keys.keyLoop.synthdict[ char ].notNil ) {
				~keys.fastFreeze.end;
				~keys.keyLoop.synthdict[ char ].release;
				~keys.keyLoop.synthdict[ char ] = nil;
				~keys.keyLoop.synthdict.keys.asArray.sort.postln;
			} {	
				~keys.recbuf.catch( buf, 0, 
					{ 
						~keys.keyLoop.synthdict[ char ] = 
							Synth( "keys_playkey_loop", [ 
								\bufnum, buf,
								\amp, ~keys.keyLoop.amp ? 0.1,
								\speed, ~keys.keyLoop.speed ? 1,
								\combamt, ~keys.keyLoop.combamt ? 0,
								\combdecay, ~keys.keyLoop.combdecay ? 0.4
							] );
						~keys.keyLoop.synthdict.keys.asArray.sort.postln;
					 }, 
				0 ); 
			};
		}.fork;
	} {
		if( char == $\r ) {
			~keys.endSynths_(true);
			[].postln;
		};
	};
	
};

~keys.keyLoop.start = { |evt|
	~keys.keyDownAction = evt[ \keyDownAction ];
};

~keys.keyLoop.endSynths_ = { |evt, bool = true|
	if( bool == true ) {
		evt.synthdict.do(_.release);
		evt.synthdict = ();
	};
};

~keys.keyLoop.end = { |evt|
	if( ~keys[ \keyDownAction ] == evt[ \keyDownAction ] ) {
		~keys[ \keyDownAction ] = nil;
	};
	evt.endSynths_(true);
};


(
SynthDef( "keys_playkey_loop", { |bufnum = 0, 
		amp = 0.5, rate = 1, gate = 1, combamt = 0, combdecay = 0.4, speed = 1|
	var sig, env;
	var filter, center, trigger, lowcut, hicut, range;
	var spec;
	
	spec = \freq.asSpec;
	
	speed = SinOsc.kr( Rand(1/20,1/10), Rand(0,2pi) ).exprange(1,7) * speed.lag(10);
	speed = speed * SinOsc.kr( Rand(1/80,1/40), Rand(0,2pi) ).range(0.8,1.2);
	trigger = Impulse.kr(speed, 0.9 ) * gate;
	
	filter = Line.kr(1,0,5);
	range = SinOsc.kr( Rand(1/40,1/20), Rand(0,2pi) ).exprange(0.05,0.5);
	
	center = SinOsc.kr( Rand(1/40,1/20), Rand(0,2pi) ).exprange(300,4000);
	center =  center * SinOsc.kr( Rand(1/80,1/40), Rand(0,2pi) ).range(0.8,1.2);
	center = spec.unmap( center );
	
	
	lowcut = spec.map( center.blend( 0, range.max(filter)) );
	hicut = spec.map( center.blend( 1, range.max(filter)) );
	
	//[lowcut,hicut,center,range].poll;
	
	rate = WhiteNoise.kr.exprange( rate / 1.05, rate * 1.05 );
	rate = Latch.kr( rate, trigger );
	
	 sig = PlayBuf.ar( 1, bufnum, rate, trigger) * 1;
	 sig = BLowCut.ar( sig, lowcut.clip(20,20000), 4 );
	 sig = BHiCut.ar( sig, hicut.clip(20,20000), 4 );
	 //combamt = combamt.blend(0,filter.linlin(0,1,0,0.75));
	 combamt = combamt.lag(5);
	 combdecay = combdecay.lag(5);
	 sig = Pan2.ar( sig, SinOsc.kr( Rand(1/40,1/20), Rand(0,2pi) ) * (1-filter) );
	 sig = (sig * (1-combamt).sqrt) 
	 	+ CombC.ar( sig, 0.1, 1/(IRand(40,100).midicps + LFDNoise3.kr(0.25.dup).range(-0.5,0.5) ),
	 	combdecay, combamt.sqrt*0.25);
	 env = Env.cutoff(combdecay).kr(2,gate.max( Impulse.kr(0) ));
	 Out.ar(0,sig * env * amp);
}).load(s);
);

)

/*

~keys.keyLoop.synthdict.do(_.free);

~keys.keyLoop.start


~synthdict = ();
~synthdict.do(_.free);

~bufdict = ();
"abcdefghijklmnopqrstuvwxyz1234567890".do({ |char|
	~bufdict.put( char, Buffer.alloc( s, 44100 * 0.2 ) );
});

~combamt = 0;
~combdecay = 0.4;
~speed = 1;

(
~keys.keyDownAction = { |vw, char|
	var buf;
	
	buf = ~bufdict[ char ];
	if( buf.notNil ) {
		{ 	
			0.16.wait; 
			if( ~synthdict[ char ].notNil ) {
				~synthdict[ char ].release;
				~synthdict[ char ] = nil;
				~synthdict.keys.asArray.sort.postln;
			} {	
				~keys.recbuf.catch( buf, 0, 
					{ 
						~synthdict[ char ] = 
							Synth( "keys_playkey_loop", [ 
								\bufnum, buf,
								\speed, ~speed ? 1,
								\combamt, ~combamt ? 0,
								\combdecay, ~combdecay ? 0.4
							] );
						~synthdict.keys.asArray.sort.postln;
					 }, 
				0 ); 
			};
		}.fork;
	} {
		if( char == $\r ) {
			~synthdict.do(_.release);
			~synthdict = ();
			[].postln;
		};
	};
	
};
)

~speed = 50; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 10; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 5; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 1; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 0.5; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 0.1; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 0.025; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 0.01; ~synthdict.do(_.set( \speed, ~speed ));
~speed = 0; ~synthdict.do(_.set( \speed, ~speed ));

~combamt = 1; ~synthdict.do(_.set( \combamt, ~combamt ));
~combamt = 0.75; ~synthdict.do(_.set( \combamt, ~combamt ));
~combamt = 0.5; ~synthdict.do(_.set( \combamt, ~combamt ));
~combamt = 0; ~synthdict.do(_.set( \combamt, ~combamt ));

~combdecay = 12; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 4; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 1; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 0.6; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 0.4; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 0.2; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 0.1; ~synthdict.do(_.set( \combdecay, ~combdecay ));
~combdecay = 0.01; ~synthdict.do(_.set( \combdecay, ~combdecay ));

(
{
	~speed = 1;
	~combamt = 0; 
	~combdecay = 0.1; 
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
	5.wait;
	~speed = 1;
	~combamt = 0.5; 
	~combdecay = 0.1; 
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
	5.wait;
	~speed = 1;
	~combamt = 0.75; 
	~combdecay = 0.4; 
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
	5.wait;
	~speed = 5;
	~combamt = 1; 
	~combdecay = 1; 
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
	5.wait;
	~speed = 0.1;
	~combamt = 1; 
	~combdecay = 12; 
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
	/*10.wait;
	~speed = 0.1;
	~combamt = 1; 
	~combdecay = 12; 
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
	*/
	50.wait;
	~speed = 0;
	~synthdict.do(_.set( \speed, ~speed, \combamt, ~combamt, \combdecay, ~combdecay ));
}.fork;
)

~speed

b[0].play

Synth( "keys_playkey_loop", [ \bufnum, b[0] ] );
Synth( "keys_playkey_loop", [ \bufnum, b[1] ] );
Synth( "keys_playkey_loop", [ \bufnum, b[2] ] );
Synth( "keys_playkey_loop", [ \bufnum, b[3] ] );
Synth( "keys_playkey_loop", [ \bufnum, b[4] ] );


1/0.025

*/