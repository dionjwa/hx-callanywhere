package macros.mock;

class Foo
{
	@rpc
	public function foo(arg1 :Int, arg2 :String, ?arg3 :String = 'defaultVal') :String
	{
		return null;
	}
}