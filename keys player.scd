(
~keys = ~keys ? EM();

~keys.player = ~keys.player ? EM();

~keys.player.synths = Order();

~keys.player.amp = 0.1;
~keys.player.spread = PintC( Pwhite( 0.0, 1.0), 0.01 ).linexp(0,1,0.5,4).asStream;

~keys.player.createDict = { |evt|
	var offset;
	evt.dict = ();
	offset = 100.rand * 36;
	"1234567890abcdefghijklmnopqrstuvwxyz".scramble.do({ |char, i|
		evt.dict[ char ] = i+offset;
	});
};

~keys.player.createDict;

~keys.player.keyDownAction = { |evt, char, mod, ascii, key| 
	var nn;
	nn = ~keys.player.dict[ char ];
	if( nn.notNil ) {
		~keys.player.synths.do(_.release); 
		~keys.player.synths[ nn ] = 
			Synth( [ "keys_fm", "keys_fm_long" ].wchoose([0.75,0.25]), [ 
				\seed, nn ,
				\amp, ~keys.player.amp,
				 \sustain, 0.125 exprand: 0.5,
				 \spread, ~keys.player.spread.next
				//\repeat, [0, 4.0 exprand: 10].choose
			] ).freeAction_({ |synth|
			~keys.player.synths.remove( synth );
			});
	} {
		~keys.player.synths.do(_.release);
		~keys.player.createDict;
	};
};

~keys.player.start = { |evt|
	~keys.keyDownAction = evt[ \keyDownAction ];
};

~keys.player.end = { |evt|
	if( ~keys[ \keyDownAction ] == evt[ \keyDownAction ] ) {
		~keys[ \keyDownAction ] = nil;
	};
	evt.synths.do(_.release);
};

~keys.player.start;
~keys.player.end;

~keys.player.seed = 1000.rand;

(
SynthDef( "keys_fm", { |sustain = 0.2, seed = 0, amp = 0.1, spread = 1|
	var levels, n = 4, phases;
	var sig, freqs, ranges, decays, pan;
	RandID.ir(2);
	phases = Rand(-pi.dup(n), pi);
     RandID.ir(1);
	RandSeed.ir( 1, seed + ~keys.player.seed ); // make it sound different on different machines
	levels = ExpRand(0.1.dup(n),1);
	levels = levels / levels.sum;
	freqs = SortedRand.ir( n, 200, 7000, \exp, spread );
	#ranges, decays = n.collect({ [ 
			[ ExpRand(200,7000), ExpRand(200,7000) ],
			ExpRand(0.25,1)
		]
	}).flop;
	pan = Rand(-0.5,0.5);
	Line.kr(0,1,sustain, doneAction:2);
	sig =  n.collect({ |i|
		SinOsc.ar( 
			SinOsc.ar(freqs[i]).range( *ranges[i] ), 
			phases[i], 
			levels[i] 
		) *( Env.perc(0.001,sustain * ExpRand(0.25,1)).ar )
	}).sum * 0.25;
	Out.ar( 0, Pan2.ar( sig, pan ) * amp );
}).load(s);
);

(
SynthDef( "keys_fm_long", { |sustain = 0.2, seed = 0, amp = 0.1, gate = 1, spread = 1|
	var levels, n = 4, phases;
	var sig, freqs, ranges, decays, pan;
	RandID.ir(2);
	phases = Rand(-pi.dup(n), pi);
     RandID.ir(1);
	RandSeed.ir( 1, seed + ~keys.player.seed ); // make it sound different on different machines
	levels = ExpRand(0.1.dup(n),1);
	levels = levels / levels.sum;
	freqs = SortedRand.ir( n, 200, 7000, \exp, spread );
	#ranges, decays = n.collect({ [ 
			[ ExpRand(200,7000), ExpRand(200,7000) ],
			ExpRand(0.25,1)
		]
	}).flop;	pan = Rand(-0.5,0.5);
	RandID.ir(2);
	levels = levels * SinOsc.kr( ExpRand(0.05.dup(n),0.7), 0.5pi ).range(0,1);
	sig =  n.collect({ |i|
		SinOsc.ar( 
			SinOsc.ar(freqs[i]).range( *ranges[i] ), 
			phases[i], 
			levels[i] 
		) * (Env.perc(0.001,sustain * decays[i]).ar + 0.075)
	}).sum * 0.25;
	sig = sig * Env.cutoff.kr(2,gate.max( Impulse.kr(1) ));
	Out.ar( 0, Pan2.ar( sig, pan ) * amp );
}).load(s);
)

)


/*


(
~keys.player.window.view.keyDownAction = { |doc, char, mod, ascii, key| 
	var nn;
	nn = ~keys.player.dict[ char ];
	if( nn.notNil ) {
		if( ~keys.player.synths[ nn ].notNil ) {
			 ~keys.player.synths[ nn ].set( \repeat, 0 ); 
		};
		~keys.player.synths[ nn ] = 
			Synth( "keys_fm", [ 
				\seed, nn ,
				\amp, 0.1,
				 \sustain, 0.25 exprand: 0.5,
				//\repeat, [0, 4.0 exprand: 10].choose
			] ).freeAction_({ |synth|
			~keys.player.synths.remove( synth );
			});
	} {
		~keys.player.synths.do(_.set( \repeat, 0 ) );
		~keys.player.createDict;
	};
};

)



gfffggdhksgotslg;skfjsjffklfdkffsssg
fkstidfgjslrpgogjkgjkfkfkfkfkgjsgfkfgdflfdgkdfgjcvkrbofjfskdfkdkdfkdfkgfosffogegufgkdfj,fjug
gsghtjsthgywggffssaaggddsssaazzzcccvvvvvvvvvbbbhhjjkkssggsssffssggffeeetthhjhtthiiiikkddffaasssxdfdgdfg
fsjskfisfgfffggosirggksflgdagdfdttttttg
rtdddddfghjkkkkklllllldyyhgfhfdtsggggfayyyddggddsfjfudlfdffgggvvssbbbajfnsdjsfisjddjdfdd
fjsdjsfkfffsddfgdddsadaddasdfggsd
djskfiafiafiadfdhdftttehsggfadasdfhjtyjbdscccxxxzzxxadhsa
fsjidfsjfajp]xxckeigsarifajfiefkdlslgso;ajfsjf
sfsfssfsuddydudaaidahrufsygsnfvhsfsyfudhfshfsjdhsdyrrutsifsursfysr
fsfsfhsfudfgjsrsshfjffdauraoedsassjfsfnxfhssdhds
fsshdsfufshguyrrrdjadkadhvjnsvdkdggaffdsjklfdsajlfjdsla
asdfhrvnfewcunewccewchdewcydewywcdfdhtet
dewchdewvhuveuefvyefvjdbbbggdjdaogireauthjsdfdffffdragyjhfsaye5grsssddss
dsdsd
sdsdsgghhhhfksfkgjfgkritf
fsfsjfhgksahjfdjksfhdskafdsahjkfdsauywiryeiwqrerewregsajkkdfjvsnfeieahdyegktugsjshdf
gddshrthkfhjthf
gfd
ggggggggggggggggg
gggggggggggggggggggggggffffffffffffffffff
ggggggggdhhhhhhrttthddddddfffgdkfghorrtiiii
ssdssddseeerfffeeffssaghteethhteethhte
bgkodpsgkpdskstjrukurss
afvbbvdabadhddhrurrurbbbbrtsfgbfgdsdfgbgfdsdfgbgbgfdsdfgbgfdsfgsgsgsgsgggggrrffeeswwrrweeeffrrgghujhgfdiuytredfghjhgfdddsfgsareettetesffsfsetetryyrdggdhhfgfdgettesffsdddfefrwaggtfeeddewavtgtgtggfdgd
sfgjkdsjgklfdsris
dsjgrdsjgrdsfjdfg
fdfgjsssssdsd
ggghkdrita
tifmsfkf
kfjgskjgks;fglgkfskjr;rgridfjddfgjhksrusghsfugoiruvsfsssds
ffififsorfslgsirrowlggggksllgkskffjdogjsrlgksjfffff

ddjfskgpagkggdjfks;akfgjskririgjsfisjfsjfgsksflgkaurghargurgharguargha
argjargjargjarjagjsidfisdjfskrifjsksjdkkddjdfjffjdkslajklfdsaadffdsjkladfjkldsafklsajfldsatiesjgdjgfkdafkdskfksgksr
sfgjksdgjsrhiagjriajrr
grjgiorjgoaf
dsfjolgelhprrpe;akf;dkfs

fjskfsokfaggggfaggghhjjlnkcmt
tt

tkdkfdaaf
rflf

fskdlgs[stkgs
fksflldjglssddsd
eedetiieteoorkglsfkfjgworgjskaavmf
ff
ffklgfjdfjsadogwirvaifjrogskfkvodkgs
kvdms[vjjagwkfai vvcks;dvjokd
kbokbsb gregekg 343 'f k sdfsjfo djiojfosjo sofjsjg4 vjojvojvosfoidf3 40t4ts sfkdlfkj ksfd ljfs sfjlsfhal 
fdgdgklhcfldsa;h;dg;gdlp;gpd;tot'pdgdkape'toep'fdgklfjdkj\'fjdgjlkjaf';jg;wkrssddffbk'd;bkklbfdldbslgprkd'ak'fvkwjf\'kfj'jrota'gjklfe'vksl'vksl'sfkk'skfjgdkdd'dddd'dddd'ddd'd'd'd'd'd'dks'fdskl'mdsvmsd;'vsmvklsv'



~keys.player.dict = ();

"1234567890abcdefghijklmnopqrstuvwxyz".scramble.do({ |char, i|
	~keys.player.dict[ char ] = i+38;
});

1234567890110101210

48-57
qwertyuiop[]asdfghjklzxcvbn,mbkndlijf

97

76 - 10

Synth( "keys_pluck", [ \nn, 76, \repeat, 7 ])

abcdefghijklmnopqrstuvwxyz


IRand(43,74)

74 - 43

97 + 26

*/