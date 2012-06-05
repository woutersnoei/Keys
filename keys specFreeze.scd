(
~keys = ~keys ? EM();

~keys.specFreeze = ~keys.specFreeze ? EM();

~keys.specFreeze.amp = 0.1;
~keys.specFreeze.active = 1;
~keys.specFreeze.noiseLevel = 0.75;
~keys.specFreeze.active = 1;
~keys.specFreeze.lowcut = 300;
~keys.specFreeze.hicut = 20000;
~keys.specFreeze.shift1 = 1;
~keys.specFreeze.shift2 = 1;
~keys.specFreeze.pitch = #[3,-4];
~keys.specFreeze.modlowcut = 100;
~keys.specFreeze.pitchtime = 1;

#[ amp, noiseLevel, active, lowcut, hicut, shift1, shift2, pitch, modlowcut, pitchtime ].do({ |item|
	~keys.specFreeze[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.sn.set( item, value );
		};
	};
});

~keys.specFreeze.filter_ = { |evt, value = 0|
	evt[ \filter ] = value;
	evt.filterTask.stop;
	if( value == 1 ) {
		evt.hicut = 50;
		evt.modlowcut = 20000;
		evt.filterTask = Task({
			25.wait;
			evt.end;
		}).start;
	} {
		evt.hicut = 20000;
		evt.modlowcut = 100;
	};
};

~keys.specFreeze.start = { |evt, clear = false|
	if( clear ) { evt.end };
	if( evt.sn.isNil or: { evt.sn.isRunning.not }) {
		evt.sn = Synth( "keys_specFreeze", evt.getPairs(
			#[ amp, noiseLevel, active, lowcut, hicut, shift1, shift2, pitch, modlowcut, pitchtime ]
		) ++ [ \bufnum, ~keys.fastBuffer ] ).register;
	};
};

~keys.specFreeze.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
};

~keys.fastBuffer = Buffer.read(s,"/Users/woutersnoei/Dropbox/Work/pow/goska_fast.aif");

(
SynthDef( "keys_specFreeze", { |t_trig = 0, noiseLevel = 0.75, active = 1, lowcut = 300, hicut = 20000, 
		shift1 = 0, shift2 = 0, 
		pitch = #[6,-7], 
		pitchtime = 1, gran = 0, 
		modlowcut = 100, amp = 0.1, gate = 1,
		bufnum = 0|
	var sig, fft, fft2, chain2;
	var n = 2, lag = 1, index, nsig, modsig, modnoise;
	var fftsize = 2048;
	var outsig;
	var nx = 6;
	var modlow, modhi;
	//sig = PlayBuf.ar(1, ~bufHigh, loop:1);
	sig = PrivateIn.ar(2) * Env([1,1,1],[0.1,0.1]).kr;
	fft = FFT( LocalBuf(fftsize).clear, sig );
	t_trig = Onsets.kr(fft, 0.7, \wphase) + t_trig;
	t_trig = DelayN.kr( t_trig, 0.1, 0.1 );
	t_trig = t_trig * (FFTFlux.kr(fft) < 0.125) * active;
	index = Stepper.kr( t_trig, 0, 0, n-1 );	
	nsig = Normalizer.ar(sig);
	
	modsig = (PlayBuf.ar( 1, bufnum, LFDNoise3.kr(0.3.dup(nx)).exprange(0.25, 4),
		1, Rand( 0.dup(nx), BufFrames.kr( bufnum ) ),
		loop: true) * 1.5);
	//modsig = modsig * LFDNoise3.kr(0.2).max(0);
	modlow = VarLag.kr( modlowcut.explin(20,20000,0,1), 30 ).linexp(0,1,20,20000, \minmax);
	modhi = VarLag.kr(  hicut.explin(20,20000,0,1), 21 ).linexp(0,1,20,20000, \minmax);
	
	modsig = BLowCut.ar( modsig, LFDNoise3.kr(0.4.dup(nx)).exprange( modlow, 20000 ), 4);
	modsig = BHiCut.ar( modsig, LFDNoise3.kr(0.4.dup(nx)).exprange( modlow, 20000), 4);
	modsig = Splay.ar(modsig);
	modnoise = PinkNoise.ar(0.4.dup * noiseLevel.lag(1));
	modnoise = BHiShelf.ar( modnoise, 1000, 3 );
	modnoise = BLowCut.ar( modnoise, lowcut.lag(1), 3 );

	modnoise = BHiCut.ar( modnoise, modhi, 3 );
	modsig = modsig + modnoise;
	
	outsig = n.collect({ |i|
		var on;
		var a,b,c;
		on = InRange.kr(index,i-0.5,i+0.5);
		a = FFT( LocalBuf(fftsize).clear, nsig);
		b = FFT( LocalBuf(fftsize).clear, modsig[0] );
		c = FFT( LocalBuf(fftsize).clear, modsig[1] );
		a = PV_MagFreeze( a, 1-Trig.kr( on, fftsize / SampleRate.ir));
		b = PV_MagMul( b, a );
		c = PV_MagMul( c, a );
		[IFFT(b),IFFT(c)] * 0.05 * Slew.kr(on,1/lag,1/lag);
	}).sum;
	
	outsig = outsig * Line.kr(-0.5,1,0.5).max(0);
	pitch = VarLag.kr( pitch, pitchtime ).midiratio;
	outsig = outsig 
		+ PitchShift.ar( outsig, 0.2, pitch[0], 0, 0.2, shift1.lag(0.2) * 0.5)
		+ PitchShift.ar( outsig, 0.17, pitch[1], 0, 0.17, shift2.lag(0.2) * 0.5);
	
	Out.ar(0, outsig * Env.cutoff(0.2).kr(2,gate+Impulse.kr(0)) * amp );
	
}).load(s);
);

)

/*

~keys.specFreeze.start;
~keys.specFreeze.end;

~keys.specFreeze.shift1 = 1;
~keys.specFreeze.shift2 = 1;

~keys.specFreeze.pitch = [12, -11];

~keys.specFreeze.pitch = [-12, 11];

~keys.specFreeze.filter = 0;
~keys.specFreeze.filter = 1;

~keys.specFreeze.hicut = 20000;
~keys.specFreeze.modlowcut = 100;
~keys.specFreeze.start(true);

(
~keys.specFreeze.hicut = 50;
~keys.specFreeze.modlowcut = 20000;
{
	25.do({|i|
		i.postln;
		1.wait;
	});
	~keys.specFreeze.end;
}.fork;
)

x.set( \noiseLevel, 1 );
x.set( \lowcut, 300 );
x.set( \lowcut, 100 );

x.set( \hicut, 50); x.set( \lowcut, 100 );
x.set( \hicut, 20000); x.set( \lowcut, 300 ); 
x.set( \modlowcut, 20000);
 
x.set( \shift1, 0.33 );
x.set( \shift2, 0.33 );


	fft2 = FFT( LocalBuf(2048).clear, Normalizer.ar(sig ));
	//t_trig = FFTCrest.kr(fft, 400, 2000 ) > 20;
	//t_trig = FFTFlux.kr( fft ) < 0.01;

	t_trig = DelayN.kr( t_trig, 0.1, 0.1 );
	chain2 = FFT( LocalBuf(2048).clear, WhiteNoise.ar(0.1) );
	fft2 = PV_MagFreeze( fft2, freeze * (1-Trig.kr( t_trig, 2048 / 44100)) );
	fft2 = PV_BrickWall( fft2, wipe );
	fft2 = PV_MagMul( chain2, fft2 );

x.set( \wipe, 63/2048 );
x.set( \freeze, 1, \t_trig, 1 );

100/2048

SpectralC

Cepstrum
*/