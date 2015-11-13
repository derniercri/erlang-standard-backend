-module(return).
-author(["Xavier van de Woestyne", "Arthur d'Azémar de Fabrègues"]).
-vsn(1).
-include("yaws_api.hrl").
-export([text/1, text/2, html/1, html/2, html/3]).

text(Content) -> text(Content, "utf-8").    
text(Content, Charset) ->
    {content, "text/plain; charset=" ++ Charset, Content}.

html(BodyContent) -> html([], BodyContent).
html(HeadContent, BodyContent) -> html(HeadContent, [], BodyContent).
html(HeadContent, BodyArgument, BodyContent) ->
    {ehtml, 
     [<<"<!DOCTYPE html><html>">>,
      {head, [], HeadContent},
      {body, BodyArgument, BodyContent}, 
      <<"</html>">>
     ]}.
