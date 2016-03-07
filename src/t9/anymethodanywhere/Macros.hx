package t9.anymethodanywhere;

import haxe.remoting.JsonRpc;
import t9.anymethodanywhere.RemoteMethodDefinition;

import Type in StdType;


#if macro
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Printer;
#end

using StringTools;
using haxe.macro.Tools;
using Lambda;

class Macros
{
	/**
	 * This takes in a number of classes (not instances) and builds a CLI
	 * parser for the methods marked with @rpc metadata.
	 * TODO: send the JSON-RPC via a websocket.
	 * @param  e<Expr> [description]
	 * @return         [description]
	 */
	macro public static function buildCLIRpcSender(rpcDispatcher :Expr, classes:Array<Expr>) :Expr
	{
		var pos = Context.currentPos();

		var className = getClassNameFromClassExpr(classes[0]);
		if (className == null || className == "") {
			throw className + " not found. Maybe specify the entire class identifier?";
		}

		var proxyClassName = (className.lastIndexOf('.') > -1 ? className.substr(className.lastIndexOf('.') + 1) : className ) + "Proxy" + (Std.int(Math.random() * 100000));

		var metaKey = 'rpc';

		var remoteDefinitions :Array<RemoteMethodDefinition> = [];

		var rpcType = Context.getType(className);
		var newFields = [];
		switch(rpcType) {
			case TInst(t, params):
				var fields = t.get().fields.get();
				for (field in fields) {
					if (field.meta.has(metaKey)) {
						var definition :RemoteMethodDefinition = {'method':field.name, args:[], aliases:[]};
						remoteDefinitions.push(definition);
						var functionArgs;
						switch(TypeTools.follow(field.type)) {
							case TFun(args, ret):
								for (arg in args) {
									var argumentTypeString = TypeTools.toString(arg.t);
									if (argumentTypeString.startsWith('Null')) {
										argumentTypeString = argumentTypeString.substring(5, argumentTypeString.length - 1);
									}
									var typeEnum :CLIType = cast argumentTypeString;
									// var type = switch(typeEnum) {
 								// 		case Int: CLIType.Int;
									// 	case String: CLIType.String;
									// 	default: CLIType.Unknown;
									// }
									var methodArgument :CLIArgument = {name :arg.name, optional:arg.opt, type:argumentTypeString, doc:null};//
									definition.args.push(methodArgument);
								}

								var metaRpc = field.meta.extract(metaKey).find(function(x) return x.name == metaKey);
								if (metaRpc.params != null) {
									for (param in metaRpc.params) {
										switch(param.expr) {
											case EObjectDecl(expr):
												for (metaObjectField in expr) {
													if (metaObjectField.field == 'aliases') {
														switch(metaObjectField.expr.expr) {
															case EArrayDecl(arrayDeclaration):
																for (arrayItemExpr in arrayDeclaration) {
																	switch(arrayItemExpr.expr) {
																		case EConst(CString(s)):definition.aliases.push(s);
																		default: Context.error('$className.${field.name}: rpc metadata ' + "'aliases' elements must be Strings", pos);
																	}
																}
															default: Context.error('$className.${field.name}: rpc metadata ' + "'aliases' field must be an array.", pos);
														}
													} else if (metaObjectField.field == 'argumentDocs') {
														switch(metaObjectField.expr.expr) {
															case EObjectDecl(objectDeclaration):
																for (objectItemExpr in objectDeclaration) {
																	switch(objectItemExpr.expr.expr) {
																		case EConst(CString(s)):
																			var docKey = objectItemExpr.field.substr("@$__hx__".length);
																			var arg :CLIArgument = definition.args.find(function(v) return v.name == docKey);
																			if (arg == null) {
																				Context.error('$className.${field.name}: rpc metadata ' + "'docs' values: there is no matching method argument '" + docKey + "'", pos);
																			}
																			arg.doc = s;
																		default: Context.error('$className.${field.name}: rpc metadata ' + "'docs' values must be Strings", pos);
																	}
																}
															default: Context.error('$className.${field.name}: rpc metadata ' + "'docs' field must be an Object.", pos);
														}
													} else if (metaObjectField.field == 'methodDoc') {
														switch(metaObjectField.expr.expr) {
															case EConst(CString(s)):
																definition.doc = s;
															default: Context.error('$className.${field.name}: rpc metadata ' + "'doc' field must be an String.", pos);
														}
													} else if (metaObjectField.field == 'short') {
														switch(metaObjectField.expr.expr) {
															case EObjectDecl(objectDeclaration):
																for (objectItemExpr in objectDeclaration) {
																	switch(objectItemExpr.expr.expr) {
																		case EConst(CString(s)):
																			var argKey = objectItemExpr.field.substr("@$__hx__".length);
																			var arg :CLIArgument = definition.args.find(function(v) return v.name == argKey);
																			if (arg == null) {
																				Context.error('$className.${field.name}: rpc metadata ' + "'short' values: there is no matching method argument '" + argKey + "'", pos);
																			}
																			if (s.length != 1) {
																				Context.error('$className.${field.name}: rpc metadata ' + "'short' values must be a string of length=1, '" + s + "'.length=" + s.length, pos);
																			}
																			arg.short = s;
																		default: Context.error('$className.${field.name}: rpc metadata ' + "'docs' values must be Strings", pos);
																	}
																}
															default: Context.error('$className.${field.name}: rpc metadata ' + "'docs' field must be an Object.", pos);
														}
													} else {
														Context.error("Unrecognized field ('" + metaObjectField.field + " ') in rpc metadata. Allows fields=['aliases', 'docs']", pos);
													}
												}
											default:
												Context.error("The rpc metadata must be an object formatted e.g. {'alias':['alias1', 'alias2'], 'docs':{'argumentName1':'argumentDocString1', 'argumentName2':'argumentDocString2'}}. All fields are optional", pos);
										}
									}
								}
								functionArgs = args;
							default: throw '"@$metaKey" metadata on a variable ${field.name}, only allowed on methods.';
						}

						switch(field.kind) {
							case FMethod(k):
							default: throw '"@$metaKey" metadata on a variable ${field.name}, only allowed on methods.';
						}
					}
				}
			default:
		}
		return macro $v {remoteDefinitions};
	}

#if macro
	public static function getClassNameFromClassExpr (classNameExpr :Expr) :String
	{
		var drillIntoEField = null;
		var className = "";
		drillIntoEField = function (e :Expr) :String {
			switch(e.expr) {
				case EField(e2, field):
					return drillIntoEField(e2) + "." + field;
				case EConst(c):
					switch(c) {
						case CIdent(s):
							return s;
						case CString(s):
							return s;
						default:Context.warning(StdType.enumConstructor(c) + " not handled", Context.currentPos());
							return "";
					}
				default: Context.warning(StdType.enumConstructor(e.expr) + " not handled", Context.currentPos());
					return "";
			}
		}
		switch(classNameExpr.expr) {
			case EField(e1, field):
				className = field;
				switch(e1.expr) {
					case EField(_, _):
						className = drillIntoEField(e1) + "." + className;
					case EConst(c):
						switch(c) {
							case CIdent(s):
								className = s + "." + className;
							case CString(s):
								className = s + "." + className;
							default:Context.warning(StdType.enumConstructor(c) + " not handled", Context.currentPos());
						}
					default: Context.warning(StdType.enumConstructor(e1.expr) + " not handled", Context.currentPos());
				}
			case EConst(c):
				switch(c) {
					case CIdent(s):
						className = s;
					case CString(s):
						className = s;
					default:Context.warning(StdType.enumConstructor(c) + " not handled", Context.currentPos());
				}
			default: Context.warning(StdType.enumConstructor(classNameExpr.expr) + " not handled", Context.currentPos());
		}

		return className;
	}
#end
}