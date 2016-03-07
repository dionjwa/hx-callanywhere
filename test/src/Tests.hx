import t9.anymethodanywhere.*;

class Tests
{
	static function main()
	{
		function sendRpc(rpc :haxe.remoting.JsonRpc.RequestDef) {
			trace(rpc);
		}
		var rpcData :Array<RemoteMethodDefinition>= t9.anymethodanywhere.Macros.buildCLIRpcSender(sendRpc, macros.mock.Foo);

		// var commander = new js.npm.Commander();
		// trace('rpcData=${rpcData}');

		t9.anymethodanywhere.RpcTools.parseCliArgs(rpcData);
	}

	// static function main()
	// {
	// 	var r = new haxe.unit.TestRunner();
	// 	r.add(new macros.TestMacros());
	// 	r.run();
	// }
}