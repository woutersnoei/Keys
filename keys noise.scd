(
~keys = ~keys ? EM();

~keys.noise1 = ~keys.noise1 ? EM();

~keys.noise1.amp = 0.1;
~keys.noise1.state = 0;
~keys.noise1.attack = 0;

#[ amp, attack ].do({ |item|
	~keys.noise1[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.sn.set( item, value );
		};
	};
});

~keys.noise1.start = { |evt, clear = false|
	if( (evt.state == 1) or: clear ) { evt.end };
	if( evt.sn.isNil or: { evt.sn.isRunning.not }) {
		evt.sn = Synth( "keys_noise", evt.getPairs( #[ amp, attack ] ) ).register;
	};
};

~keys.noise1.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
};

~keys.noise2 = ~keys.noise1.copy;
~keys.noise3 = ~keys.noise1.copy;


(
SynthDef( "keys_noise", { |amp = 0.1, gate = 1, attack = 0|
	var sig;
	var freqs;
	freqs = (IRand(0.dup(3),9) * 3 + [87,88,89]).midicps;
	sig = freqs.collect({ arg freq;
		2.collect({
			var sig;
			sig = BLowCut.ar( GrayNoise.ar(0.1 ), freq, 4);
			sig = Ringz.ar(sig, freq * [1,2,3], [0.1,0.05,0.025], [1,0.25,0.125] * 0.1).mean;
		});
	}).mean * 0.25;
	Out.ar( 0, sig * amp * Env.asr(attack, 1, 0.1, [0,-4]).kr(2,gate) );
	
}).load(s)
);

)

