(
~keys = ~keys ? EM();
/*
~keys.ir = InputRouter.unique( s, \keys, [ \keys, 'clav keys', 'clav mic' ] );
~keys.ir.gui;
~keys.ir.start;
*/

(
SynthDef( "keys_recbuf_3", { |t_trig = 0, in = 0|
	var buffers, phasor;
	var input, n = 3;
	buffers = \buffers.kr( 0!n );
	phasor = Phasor.ar( 0, 1, 0, BufFrames.kr( buffers[0] ) );
	input = PrivateIn.ar( in, n );
	input.do({ |channel, i|
		BufWr.ar( channel, buffers[i], phasor, 1 );
	});
	SendReply.kr( t_trig, '/recbuf_pos', phasor );
}).load(s);
);

~keys.recbuf = ~keys.recbuf ? EM();

~keys.recbuf.bufs = { Buffer.alloc( s, 44100 * 20 ) }!3; // 5 20-second buffers

~keys.recbuf.start = { |evt|
	if( evt.sn.isNil or: { evt.sn.isRunning.not }) {
		evt.sn = Synth( "keys_recbuf_3", [ \buffers, evt.bufs ], addAction: \addToTail ).register;
	};
};

~keys.recbuf.active = { |evt|
	 evt.sn.notNil and: { evt.sn.isRunning.not }
};

~keys.recbuf.end = { |evt|
	evt.sn.free; evt.sn = nil;
};

~keys.recbuf.catch = { |evt, buf, index = 0, action, fadeTime = 0.25, delay = 0|
	if( (evt.sn !? _.isRunning) == true ) {	
		ReceiveReply( evt.sn, { |value|
			buf.asCollection.do({ |buf, i|
				if( fadeTime != 0 ) {	
					evt.bufs[index+i].copyLoopCF( buf, 
						value - buf.numFrames - (44100 * fadeTime) - (delay * 44100), 
						fadeTime: fadeTime, 
						action: action );
				} {
					evt.bufs[index+i].copyLoopTo( buf, srcStartAt: value - buf.numFrames - (delay * 44100), 
						action: action );
				};
			});
		}, '/recbuf_pos' ).oneShot;
		evt.sn.set( \t_trig, 1 );
	} {
		"~keys.recbuf.catch : synth not running!!".postln;
		false;
	};
};

)
/*

~keys.recbuf.start;

~longbuf = Buffer.alloc( s, 44100 * 1 );

(
~keys.player.window.view.keyDownAction = { |doc, char, mod, ascii|
	if( char == $ ) { 
		~keys.recbuf.catch( ~longbuf, 0, { 
			{ 
				var sig;
				sig = 
					PlayBuf.ar( 1, ~longbuf, 
						(0.5,0.6..1) * 0.5, 
						1,
						BufFrames.kr(~longbuf) * (0.5,0.4..0) * 0.97, 
						doneAction: [0,0,0,0,0,2]) * 0.5;
				BLowCut.ar( Splay.ar(sig), 300, 4 )
			 }.play; 
		}, 0 );
	};
};
)
 
 
 
(
~keys.player.window.view.keyDownAction = { |doc, char, mod, ascii|
	if( char == $ ) { 
		~keys.recbuf.catch( ~longbuf, 0, { 
			2.do({ |i|
				{ 
				var sig, n = 4, rate = [0.7,1.1][i];
				var env;
				sig = PlayBuf.ar( 1, ~longbuf, 
						LFDNoise3.kr(1.dup(n)).range(0.5,1) * rate, 
						1,
						BufFrames.kr(~longbuf) * ({1.0.rand}!n),
						loop: 1
				) * 1;
				env = Env([0,0.75,0.25,0.1,1,0], [0.01, 1,0.5, 0.5,0.01] * 
					(BufDur.kr(~longbuf) / rate)).kr(2);
				//sig = FreqShift.ar( sig, Rand(-200.dup(n), 300) );
				sig = BLowCut.ar( sig, ExpRand(150.dup(n),400), 2 );
				sig = BHiCut.ar( sig, ExpRand(5000.dup(n),20000), 2 );
				sig = (sig.sum/n) * env;
				Out.ar( i, sig );
			 }.play; 
			});
		}, 0.02 );
	};
};
)

~keys.recbuf.catch( b, 0, { { PlayBuf.ar( 1, b, 0.5, 1, [0,BufdoneAction: [0,2]).dup * 0.5 }.play; }, 0 );


b = { Buffer.alloc( s, 44100 * 0.2 ) }!20;
c = [];

b = c;
c = [];


(
~keys.player.window.view.keyDownAction = { |doc, char, mod, ascii|
	if( char == $ ) { 
		~keys.recbuf.catch( b, 0, { 
			2.do({ |i|
				{ 
				var sig, n = 4, rate = [0.3,0.5][i];
				var env;
				sig = PlayBuf.ar( 1, b, 
						{ 0.5 rrand: 1.0 }!n * rate, 
						1,
						BufFrames.kr(b) * ({1.0.rand}!n),
						loop: 1
				) * 1;
				env = Env([0,0.75,0.25,0.1,1,0], [0.01, 1,0.5, 0.5,0.01] * (BufDur.kr(b) / rate)).kr(2);
				sig = FreqShift.ar( sig, Rand(-200.dup(n), 300) );
				sig = BLowCut.ar( sig, ExpRand(150.dup(n),400), 5 );
				sig = BHiCut.ar( sig, ExpRand(3000.dup(n),20000), 5 );
				sig = (sig.sum/n) * env;
				Out.ar( i, sig );
			 }.play; 
			});
		}, 0.1 );
	};
};
)

~dict = ();

~dict.do(_.stop);

(
~keys.player.window.view.keyDownAction = { |vw, char|
	var buf, t;
	
	if( b.size == 0 ) {
		b = c;
		c = [];
	};
	
	buf = b.removeAt(0);
	c = c.add( buf );
	{ 	0.16.wait; 
		t = 0.2 rrand: 1.0;
		if( ~dict[ char ].notNil ) {
			~dict[ char ].stop;
			~dict[ char ] = nil;
			~dict.keys.postln;
		} {	
			~keys.recbuf.catch( buf, 0, 
				{ 
					
					~dict[ char ] = Task({
						(t - 0.18).wait;
						loop {
							Synth( "keys_playkey", [ \bufnum, buf ] );
							t.wait;
						};
					}).start;
					~dict.keys.postln;
				 }, 
			0 ); 
		};
	}.fork;
};
)


SynthDef( "keys_playkey", { |bufnum = 0, 
		amp = 0.25, pan = 0, rate = 1,
		lowcut = 20, hicut = 20000,
		filter = 0|
	var sig;
	 sig = PlayBuf.ar( 1, bufnum, rate, doneAction: 2 );
	 sig = sig * amp;
	 sig = BLowCut.ar( sig, ((lowcut * filter) + (20 * (1-filter))).clip(20,20000), 3 );
	 sig = BHiCut.ar( sig, ((hicut * filter) + (20000 * (1-filter))).clip(20,20000), 3 );
	 sig = Pan2.ar( sig, pan );
	 Out.ar(0,sig);
}).load(s);







Document.current.keyDownAction = {
	x.set( \t_trig, 1, \spd, 0.75 );
};




Document.current.keyDownAction = nil;


GrainIn

nil;


gsjrwifg







{ Out.ar(1, PrivateIn.ar(0) ) }.play;

x = { |t_trig = 0, spd = 0.5|
	Out.ar(1, 
		DelayC.ar( PrivateIn.ar(0), 5, Phasor.ar(t_trig, spd/44100, 0.25, 5 ) ) 
	) 
}.play;

x.set( \t_trig, 1, \spd, 0.75 );

{LFSaw.ar(100)}.plot

{ Out.ar( 0, PitchShift.ar( PrivateIn.ar(0), 0.2.dup, 0.5, 0.01, 0.2 ) ) }.play



~keys.recbuf.catch( b, 0, { "done".postln }, 0 );

b.playfpgdpsv.fls;foriwgksdllv,fgmdk

c[11].play

kdfogskfktriwoprepvkgdlf;s04dk

~keys.recbuf.bufs[0].plot
*/