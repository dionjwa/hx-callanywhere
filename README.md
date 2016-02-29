1) a macro to enumerate class methods and signatures
2) convert the signature to json (or any defined transport mechanism)
3) object that maps the json to the method, returning the result
4) bind to a remoting interface

CLI has metadata on remote methods, so can wrap CLI commands into a RPC call.
RPC object takes the remote call bundle, and sends it.
Server has the RPC reciever.
