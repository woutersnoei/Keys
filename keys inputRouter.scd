~keys = ~keys ? EM();

~keys.ir = InputRouter.unique( s, \pow, [ \keys, \clav ] );

~keys.ir.path = File.getcwd;
~keys.ir.readSettings;

~keys.ir.gui;
~keys.ir.start; 