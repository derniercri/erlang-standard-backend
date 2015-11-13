-module(uri).
-author(["Xavier van de Woestyne", "Arthur d'Azémar de Fabrègues"]).
-vsn(1).
-include("yaws_api.hrl").
-export([tokenize/1, root/2]).

%% transform request_uri into a list 
tokenize(Arg) ->
    case Arg#arg.appmoddata of 
        [] -> [];
        AnUri -> string:tokens(AnUri, "/")
    end.

%% Map to real root
root(Path, Target) ->
    Flashback = lists:map(fun(_) -> ".." end, Path),
    NewTarget = lists:append(Flashback, [Target]),
    filename:join(NewTarget).
