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
	states,
	
	recFast,
	binScramble, 
	fastFreeze, 
	loops,
	keyLoop, 
	keyTexture, 
	noise, 
	player, 
	specFreeze
	
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