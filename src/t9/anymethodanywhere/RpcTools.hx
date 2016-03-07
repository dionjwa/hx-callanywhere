package t9.anymethodanywhere;

import haxe.remoting.JsonRpc;
import js.npm.Commander;

using Lambda;

class RpcTools
{
	public static function parseCliArgs(definitions :Array<RemoteMethodDefinition>) :RequestDef
	{
		var request :RequestDef = {
			jsonrpc: '2.0',
			method: ''
		}

		var program :Commander = js.Node.require('commander');
		program.version('0.0.1');
		for (definition in definitions) {
			var commandName = definition.method;
			for (arg in definition.args.filter(function(v) return !v.optional)) {
				commandName += ' <${arg.name}>';
			}
			var command = program.command(commandName);
			command.description(definition.doc);
			// command.option("-s, --setup_mode [mode]", "Which setup mode to use");
			for (alias in definition.aliases) {
				command.alias(alias);
			}
			for (arg in definition.args.filter(function(v) return v.optional)) {
				trace('arg=${arg}');
				var optionalArgString = '--${arg.name} [${arg.name}]';
				if (arg.short != null) {
					optionalArgString = '--${arg.short}, ' + optionalArgString;
				}
				command.option(optionalArgString, arg.doc);
			}

			// command.action(function(cmd :String, arg1 :Dynamic, arg2 :Dynamic, options :Dynamic) {
			command.action(function(arg1 :Dynamic, arg2 :Dynamic, arg3 :Dynamic, arg4 :Dynamic, arg5 :Dynamic, arg6 :Dynamic, arg7 :Dynamic) {
				var options :{options:Dynamic} = getOptions(arg1, arg2, arg3, arg4, arg5, arg6, arg7);
				var arguments = getArguments(arg1, arg2, arg3, arg4, arg5, arg6, arg7);
				trace('arguments=${arguments}');
				// trace('options=${options}');
				trace(options.options);
				// for (k in Reflect.fields(options)) {
				// 	trace(k);
				// }
				// trace('cmd=', cmd);//options=$options
				// trace('arg1=${arg1}');
				// trace('arg2=${arg2}');
				// trace('do $commandName $definition');
			});
		}

		if (js.Node.process.argv.slice(2).length == 0) {
			program.outputHelp();
		} else {
			program.parse(js.Node.process.argv);
		}

		return request;
	}

	static function getOptions(arg1 :Dynamic, arg2 :Dynamic, arg3 :Dynamic, arg4 :Dynamic, arg5 :Dynamic, arg6 :Dynamic, arg7 :Dynamic)
	{
		if (arg7 == null) {
			if (arg6 == null) {
				if (arg5 == null) {
					if (arg4 == null) {
						if (arg3 == null) {
							if (arg2 == null) {
								if (arg1 == null) {
									trace('Should not be here');
									return null;
								} else {
									return arg1;
								}
							} else {
								return arg2;
							}
						} else {
							return arg3;
						}
					} else {
						return arg4;
					}
				} else {
					return arg5;
				}
			} else {
				return arg6;
			}
		} else {
			return arg7;
		}
	}

	static function getArguments(arg1 :Dynamic, arg2 :Dynamic, arg3 :Dynamic, arg4 :Dynamic, arg5 :Dynamic, arg6 :Dynamic, arg7 :Dynamic)
	{
		if (arg7 == null) {
			if (arg6 == null) {
				if (arg5 == null) {
					if (arg4 == null) {
						if (arg3 == null) {
							if (arg2 == null) {
								if (arg1 == null) {
									trace('Should not be here');
									return null;
								} else {
									return [];
								}
							} else {
								return [arg1];
							}
						} else {
							return [arg1, arg2];
						}
					} else {
						return [arg1, arg2, arg3];
					}
				} else {
					return [arg1, arg2, arg3, arg4];
				}
			} else {
				return [arg1, arg2, arg3, arg4, arg5];
			}
		} else {
			return [arg1, arg2, arg3, arg4, arg5, arg6];
		}
	}
}