(

~keys = ~keys ? EM();

~keys.fastFreeze = ~keys.fastFreeze ? EM();

~keys.fastFreeze.amp = 0.1;
~keys.fastFreeze.active = 1;
~keys.fastFreeze.spd = 5;
~keys.fastFreeze.modrange = 0;

~keys.fastFreeze.setting = 0;

#[ amp, active, spd, modrange ].do({ |item|
	~keys.fastFreeze[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.sn.set( item, value );
		};
	};
});

~keys.fastFreeze.setting_ = { |evt, value = 0|
	evt[ \setting ] = value;
	switch( value.asInt,
		0, {
			evt.spd = 5;
			evt.modrange = 0; 
			evt.active = 1;
		}, 1, {
			evt.spd = 15;
			evt.modrange = 1; 
			evt.active = 0;
		};
	);
};

~keys.fastFreeze.start = { |evt, clear = false|
	if( clear ) { evt.end };
	if( evt.sn.isNil or: { evt.sn.isRunning.not }) {
		evt.sn = Synth( "keys_fastFreeze", evt.getPairs( #[ amp, active, spd, modrange ] ) ).register;
	};
};

~keys.fastFreeze.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
};


(
SynthDef( "keys_fastFreeze", { |amp = 0.1, active = 1, spd = 5, modrange = 0, gate = 1|
	var fft, sig, buf1, buf2;
	var bufsig, lasbufsig, phasor;
	var modsig, msig, freqs;
	var env;
	modrange = modrange.lag(25).clip(0,1);
	spd = spd.lag(30);
	sig = PrivateIn.ar(2) * active;
		
	modsig = PinkNoise.ar(1.dup);
	modsig = (modsig * (1-(modrange.sqrt))) + ( Splay.ar( 
			SinOsc.ar( Rand(0.5.dup(6),1.5) * spd.lag(2), Rand(0.dup(6), 2pi )).max(0) ** 4 
		) * modsig * modrange * 2);
	modsig = BHiCut.ar( modsig, (1-modrange).linexp(0,1,5500,20000), 3 );
	modsig = BLowCut.ar( modsig, modrange.squared.linexp(0,1,250, 5500), 3 );
	
	buf1 = LocalBuf(1024).clear;
	buf2 = LocalBuf(1024).clear;
	fft = FFT( buf1, sig );
	phasor = Phasor.ar(0,2,0,1024, 512);
	bufsig = BufRd.ar( 1, buf1, phasor, 1, 1 );
	lasbufsig = (BufRd.ar( 1, buf2, phasor, 1, 1 ) * 1).max( bufsig  ).clip(-100,100);
	BufWr.ar( bufsig + lasbufsig, buf2, phasor, 1 ); 
	
	sig = modsig.collect({ |ms|
		var modfft;
		modfft = FFT( LocalBuf(1024), ms );
		modfft = PV_MagMul( modfft, buf2 );
		IFFT( modfft ) * 0.2;
	});
	Out.ar(0,sig * amp * Env.cutoff(0.1).kr(2,gate) );
}).load(s);
)

)

/*

~keys.fastFreeze.start( true );
~keys.fastFreeze.end;
~keys.fastFreeze.setting = 1;
~keys.fastFreeze.setting = 0;



*/