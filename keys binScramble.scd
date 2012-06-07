(
~keys = ~keys ? EM();

~keys.binScramble = ~keys.binScramble ? EM();

~keys.binScramble.thresh = 5;
~keys.binScramble.amp = 0.1;

[ \thresh, \amp ].do({ |item|
	~keys.binScramble[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.sn.set( item, value );
		};
	};
});

~keys.binScramble.start = { |evt|
	evt.end;
	evt.sn = Synth( "keys_binScramble", evt.getPairs([\amp, \thresh]) );
};

~keys.binScramble.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
};

(
SynthDef("keys_binScramble", { arg t_trig = 0, thresh = 5, amp = 0.1, 
		gate = 1;
Ê Ê Ê Ê var in, chain, noiseChains, chain2;
	   var sig, noise, fftsize = 4096;
	   in = PrivateIn.ar(1);
	   in = DelayC.ar( in, 2.0, LFDNoise3.kr(0.125).range(0.5,2) );
	   chain = FFT(LocalBuf(fftsize), in);
	   noise = WhiteNoise.ar(0.1.dup);

        noiseChains = noise.collect({ |nse| FFT(LocalBuf(fftsize), nse )});
        
	   chain = PV_LocalMax(chain, thresh);
	   chain = PV_MagSmooth( chain, 0.9 );
	   chain = PV_BinScramble(chain, 1, 0.075, t_trig);
	   chain2 = PV_Copy(chain, LocalBuf(fftsize).clear);
	   
	   chain = PV_Mul( chain, noiseChains[0] );
	   chain2 = PV_Mul( chain2, noiseChains[1] );
	   sig = [IFFT(chain), IFFT(chain2)];
	   sig = sig * Line.ar(-1,1,0.1).max(0);
	   //sig = PitchShift.ar(sig, 0.1, 1, 0.01, 0.1);
	   sig = BLowCut.ar(sig, 200, 1);
	   sig = BHiCut.ar(sig,3000,2);
	   //sig = sig * Decay.kr( Pan2.kr( Dust.kr(4), WhiteNoise.kr(0.5)), 1 );
	   sig = Limiter.ar( sig, 0.3) / 0.3;
	   Out.ar(0, sig * amp * Env.asr(0.1,1,0.1).kr(2,gate.max(Impulse.kr(0) ) ) );
}).load(s)
);
)
