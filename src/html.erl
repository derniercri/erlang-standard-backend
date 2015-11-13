-module(html).
-author(["Xavier van de Woestyne"]).
-vsn(1).
-include("yaws_api.hrl").
-export([css/1, icon/1,javascript/1, charUTF8/0, viewport/0]).
-export([mobile_header/4]).

rlink(Rel, Mime, Url) -> {link, [{rel, Rel}, {type, Mime}, {href, Url}]}.
css(Url) -> rlink("stylesheet", "text/css", Url).
icon(Url) -> rlink("shortcut icon", "image/x-icon", Url).


rmeta(Name, Content) -> {meta, [{name, Name}, {content, Content}]}.
viewport() -> rmeta("viewport", "width=device-width, initial-scale=1.0").

charUTF8() ->
    {meta, 
     [{'http-equiv', "Content-Type"}, 
      {content, "text/html; charset=utf-8"}]}.

javascript(Url) ->
    {script, 
     [{src, Url},
      {type, "text/javascript"}]}.

mobile_header(Status, Startup, Favicon, Icon) ->
    [icon(Favicon),
     charUTF8(),
     viewport(),
     rmeta("apple-mobile-web-app-capable", "yes"),
     rmeta("apple-touch-fullscreen", "yes"),
     rmeta("apple-mobile-web-app-status-bar-style", Status),
     {link, [{rel, "apple-touch-startup-image"}, {href, Startup}]},
     {link, [{rel, "apple-touch-icon"}, {href, Icon}]}
    ].
