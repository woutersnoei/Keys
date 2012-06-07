(
~keys = ~keys ? EM();

~keys.recFast = ~keys.recFast ? EM();

// preload the buffer with recorded data for rehearsal
~keys.recFast.buffer = Buffer.read( s, 
	thisProcess.nowExecutingPath.dirname +/+ "samples/goska_fast.aif" 
);

~keys.recFast.start = { |evt|
	evt.task.stop;
	if( ~keys.recbuf.active == true ) {
		"~keys.recFast : buffer recording started".postln;
		evt.task = Task({ 
			6.wait;
			~keys.recbuf.catch( evt.buffer, 1, 
				{ "~keys.recFast : buffer recording done".postln; }
			);
		}).start;
	} {
		"~keys.recFast : can't record, ~keys.recbuf not active".postln;
	};
};

~keys.recFast.end = { |evt|
	if( evt.task.isPlaying ) {
		evt.task.stop;
		evt.task = nil;
		"~keys.recFast : buffer recording aborted".postln;
	};
};
)