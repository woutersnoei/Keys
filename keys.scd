(
~keys = ~keys ? EM();

~keys.path = thisProcess.nowExecutingPath.dirname;

~keys.docs = ();

#[
	inputRouter,
	gate, 
	recbuf, 
	looprec,
	reverb,
	
	recFast,
	binScramble, 
	fastFreeze, 
	loops,
	keyLoop, 
	keyTexture, 
	noise, 
	player, 
	specFreeze,
	
	states,
	
	// midi   // <- uncomment for midi support
	
].collect({ |item| 
	var path;
	path =  (~keys.path +/+ "keys" + item ++ ".scd");
	~keys.docs[ item ] = path;
	path.load;
});
	
)
	
/*


Document.open( ~keys.docs[ \gate ] ); // quick link to doc

"open '%'".format(~keys.path).unixCmd; // open folder in finder

*/