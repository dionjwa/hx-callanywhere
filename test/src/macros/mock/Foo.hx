package macros.mock;

import promhx.Promise;

class Foo
{
	/**
	 * Here is some documentation
	 */
	@rpc({
		aliases:['aliasToFoo', 'anotherAliasToFoo'],
		methodDoc:'foo description',
		// aliases:'1',
		argumentDocs:{'arg1':'arg1doc','arg2':'arg2doc', 'arg3':'arg3doc'},
		short:{'arg1':'a','arg2':'z', 'arg3':'f'}
		// ,test:{'foo':'bar'}
	})
	public function foo(arg1 :Int, arg2 :String, ?arg3 :String = 'defaultVal') :Promise<String>
	{
		return null;
	}

	@rpc({
		methodDoc:'foo2 description'
	})
	public function foo2() :Promise<String>
	{
		return null;
	}
}