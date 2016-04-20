-module(route).
-author(["Xavier van de Woestyne", "Arthur d'Azémar de Fabrègues"]).
-vsn(1).
-include("yaws_api.hrl").
-include("error.hrl").
-export([out/1]).

%% Routing
route(_, _, ["hello"]) -> return:html({h1, [], ["Hello World"]});
route(_, _, _) -> return:html(?ERROR_NO_SERVICE).

%% Entry point
out(Arg) ->
    Path   = uri:tokenize(Arg),
    Method = (Arg#arg.req)#http_request.method,
    route(Arg, Method, Path).



