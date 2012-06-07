(
~keys = ~keys ? EM();

~keys.looprec = ~keys.looprec ? EM();

~keys.looprec.buf = 0;
~keys.looprec.delay = 0;
~keys.looprec.in = 1;

#[ buf, delay, in ].do({ |item|
	~keys.looprec[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.sn.set( item, value );
		};
	};
});

~keys.looprec.start = { |evt|
	if( evt.sn.isNil or: { evt.sn.isRunning.not }) {
		evt.sn = Synth( "keys_looprec", evt.getPairs( #[ buf, delay, in ] ) ).register;
	};
};

~keys.looprec.active = { |evt|
	 evt.sn.notNil and: { evt.sn.isRunning }
};

~keys.looprec.end = { |evt|
	evt.sn.free; evt.sn = nil;
};

~keys.looprec.recbuffer = { |evt, buf|
	if( evt.active == true ) {
		if( buf.notNil ) {
			evt.buf = buf;
			evt.sn.set( \t_trig, 1 );
		};
	} {
		"~keys.looprec.recbuffer : synth not running!!".postln;
	};
};

(
SynthDef( "keys_looprec", { |buf = 0, t_trig = 0, delay = 0.1, in = 1|
	var sig, run;
	sig = PrivateIn.ar( in );
	run = Trig.kr( t_trig, BufDur.kr( buf ));
	RecordBuf.ar( sig, buf, 0, 1, 0, run, 0, t_trig );
}).load(s);
);

)