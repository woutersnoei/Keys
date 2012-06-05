~keys = ~keys ? EM();

~keys.ir = InputRouter.unique( s, \pow, [ \keys, \clavKeys, \clavMic ] );
~keys.ir.gui;
~keys.ir.start; 