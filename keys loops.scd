(
~keys = ~keys ? EM();

~keys.loop1 = ~keys.loop1 ? EM();

~keys.loop1.initBuf = { |evt|
	evt.buf = Buffer.alloc( s, 44100 * 0.66 );
};

~keys.loop1.readBuf = { |evt, path|
	evt.buf = Buffer.read(s, path.spath, numFrames: 44100 * 0.66);
};

~keys.loop1.amp = 0.1;
~keys.loop1.lowcut = 150;
~keys.loop1.vari = 0.001;
~keys.loop1.dur = 0.4;
~keys.loop1.trigspd = 50;

#[ amp, lowcut, vari, dur, trigspd, freq ].do({ |item|
	~keys.loop1[ item.asSetter ] = { |evt, value|
		if( value.notNil ) {
			evt[ item ] = value;
			evt.synths.do(_.set( item, value ));
		};
	};
});

~keys.loop1.start = { |evt, clear = false|
	if( clear ) { evt.end };
	if( evt.task.isPlaying.not and: { evt.synths.isNil }) {
		//~keys.looprec.recbuffer(evt.buf); 
		evt.task = Task({
			0.56.wait;
			~keys.recbuf.catch( evt.buf, 1, { "recorded buf".postln }, 0 );
			evt.settings.do({ |setting, i|
				var time, semitones, pan;
				#time, semitones, pan = setting;
				if( i == 0 ) { (time - 0.56).wait; } { time.wait };
				evt.synths = evt.synths.add( 
					Synth( "keys_loops", [ 
						\semitones, semitones,
						\pan, pan
					] ++ evt.getPairs( #[ amp, lowcut, vari, dur, trigspd, buf, freq ] ) )
				);
			});
		}).start;
	};
};

~keys.loop1.end = { |evt|
	evt.task.stop;
	evt.synths.do(_.release);
	evt.synths = nil;
};

~keys.loop2 = ~keys.loop1.copy;
~keys.loop3 = ~keys.loop1.copy;

/// settings: [ [ waittime, semitones, pan ], ... ]
~keys.loop1.freq = "F1".namecps;
~keys.loop1.settings = [ 2/3, [0,12,-12], [0, -0.75, 0.75] ].flop;
~keys.loop1.readBuf( thisProcess.nowExecutingPath.dirname +/+ "samples/goskachord.aif" );

~keys.loop2.freq = "Db2".namecps;
~keys.loop2.settings = [ 2/3, [0,-12,12], [0, 0.75, -0.75] ].flop;
~keys.loop2.readBuf( thisProcess.nowExecutingPath.dirname +/+ "samples/goskachord2.aif" );

~keys.loop3.freq = "E3".namecps;
~keys.loop3.settings = [ 2/3, [12,-12,0], [-0.75, -0.75, 0.75] ].flop;
~keys.loop3.readBuf( thisProcess.nowExecutingPath.dirname +/+ "samples/goskachord3.aif" );


(
SynthDef( "keys_loops", { |buf = 0, gate = 1, speed = 0.1, trigspd = 50, 
		semitones = 0, pan = 0, amp = 0.2,	dur = 0.4, vari = 0.001, freq = 300, 
		lowcut = 150, startDB = (-7)|
	var pos, sig, env, rate;
	var fftbuf, bufdur;
	var freqtime = 5;
	rate = semitones.midiratio;
	vari = vari.lag(0.5);
	bufdur = BufDur.kr( buf );
	env = Env.cutoff.kr(2,gate) * Env([0,0,1],[0.15,0.01]).kr;
	pos = Line.kr( 0, 1 - ((dur/bufdur * rate)+(0.05 / rate)), bufdur/ speed );
	sig = GrainBuf.ar( 2, TDuty.ar( Dwhite(0.5/trigspd,2/trigspd) ), dur, buf, 
		WhiteNoise.ar.range(1-vari,1+vari) * rate,
		pos + WhiteNoise.ar(0.05), 4, WhiteNoise.ar * 0.125 
	);
	
	sig = sig * Line.ar(startDB,0,freqtime).dbamp;
	
	freq = freq * LFDNoise3.kr(0.25).exprange(1, 8);
	
	sig = BHiCut.ar( sig, (Line.kr(1,0,freqtime).linexp(0,1,freq, 20000) * rate)
		.clip(20,20000), 2);
	sig = BLowCut.ar( sig, (Line.kr(0,1,freqtime).linexp(0,1,20,freq * 0.95) * rate)
		.clip(20,20000), 1);
	
	sig = BLowCut.ar(sig, lowcut.lag(1).clip(20,20000), 1);
	
	Out.ar( 0, Balance2.ar( sig[0], sig[1], pan, amp * env ) );
}).load(s)
);

)
	
	
	