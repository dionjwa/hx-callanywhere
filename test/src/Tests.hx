class Tests
{
	static function main()
	{
		function sendRpc(rpc :haxe.remoting.JsonRpc.RequestDef) {
			trace(rpc);
		}
		t9.anymethodanywhere.Macros.buildCLIRpcSender(sendRpc, macros.mock.Foo);
	}

	// static function main()
	// {
	// 	var r = new haxe.unit.TestRunner();
	// 	r.add(new macros.TestMacros());
	// 	r.run();
	// }
}