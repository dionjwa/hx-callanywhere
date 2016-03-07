package t9.anymethodanywhere;

import haxe.remoting.JsonRpc;

/**
 * These are the types that can be passed in via the CLI
 * and are checked at runtime.
 */
// abstract enum CLIType {
// 	Int;
// 	String;
// }

@:enum
abstract CLIType(String) {
  var Int = 'Int';
  var String = 'String';
  var Unknown = 'Unknown';
}

typedef CLIArgument = {
	var name :String;
	var type :String;
	var optional :Bool;
	@:optional var doc :String;
	@:optional var short :String;
}

typedef RemoteMethodDefinition = {//>RequestDef,
	var method :String;
	@:optional var doc :String;
	@:optional var aliases :Array<String>;
	var args :Array<CLIArgument>;

	// @:optional var paramDocStrings :Dynamic<String>;
	// @:optional var paramTypes :Dynamic<CLIType>;
	// @:optional var paramIsOptional :Dynamic<Bool>;
	// @:optional var paramNames :Array<String>;
}
