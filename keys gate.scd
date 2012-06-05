(
~keys = ~keys ? EM();

~keys.keygate = ~keys.keygate ? EM();

SynthDef("keys_gate", { |in = 0, out = 0, thresh = -60, gate = 1|
	var sig, ampl;
	sig = PrivateIn.ar(in);
	ampl = Amplitude.kr( sig );
	sig = sig * Schmidt.kr( ampl, (thresh - 3).dbamp, (thresh + 3).dbamp ).lag(0,0.1);
	sig = BPeakEQ.ar( sig, 2000, 1, -3 );
	sig = BHiShelf.ar( sig, 3000, 1, 9 );
	PrivateReplaceOut.ar(in, sig * Env.cutoff.kr(2,gate));
}).load(s);

SynthDef("keys_amp", { |in = 0, out = 0, amp = 0.1, gate = 1|
	var sig;
	sig = PrivateIn.ar(in);
	Out.ar(out, sig * 2 * amp.dup * Env.cutoff.kr(2,gate));
}).load(s);


~keys.keygate.start = { |evt|
	evt.end;
	evt.sn = Synth( "keys_gate" );
};

~keys.keygate.end = { |evt, time|
	evt.sn.free;
	evt.sn = nil;
};


~keys.keyamp = ~keys.keyamp ? EM();

~keys.keyamp.amp = 0.1;
~keys.keyamp.amp_ = { |evt, amp = 0.1|
	evt[ \amp ] = amp;
	evt.sn.set( \amp, amp );
	evt.changed( \amp, amp );
};

~keys.keyamp.start = { |evt|
	evt.end;
	evt.sn = Synth( "keys_amp", [ \amp, evt.amp ], addAction: \addToTail );
};

~keys.keyamp.end = { |evt, time|
	evt.sn.release(time);
	evt.sn = nil;
};


)

/*

~keys.keygate.start;
~keys.keyamp.start;
~keys.keyamp.amp = 0.1;

(
a = {
	arg cutoff = 3000, width = 0.2, speed = 10, dur = 0.1;
	var sig, env;
	sig = PinkNoise.ar(0.1.dup);
	speed = LFDNoise3.kr(0.1).exprange(3/4,4/3) * speed.lag(1);
	env = Env([0,1,0], [0.5,0.5], \sin).ar(0, Impulse.ar(speed), dur.lag(1) );
	sig = sig * env;
	sig = BLowCut.ar(sig, ( cutoff * (1-(width/2)) ).lag(1).clip(20,20000), 3);
	sig = BHiCut.ar(sig, ( cutoff * (1+(width/2)) ).lag(1).clip(20,20000), 3);
}.play;
)


a.set( \cutoff, 1000, \width, 0.5 )

a.set( \speed, 400 , \dur, 0.005 );

Synth

50.linexp(0,100,0.75, 4/3)

4/3


s.options.hardwareBufferSize = 128;
ServerOptions

*/


