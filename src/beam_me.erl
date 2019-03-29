%%
%% Helper to create loadable binaries from a markdown string.
%%
%% This is written in Erlang to resemble Elixir's own `elixir_erl.erl` closely to allow
%% maintaining this.
%%
-module(beam_me).

-export([string_to_beam/2]).

string_to_beam(ModuleName, String)
  when is_atom(ModuleName),
       is_binary(String) ->
    Line = 0,
    Forms = [
             {attribute, Line, module, ModuleName},
             %% __info__/1 must be available!
             %%
             %% This is the form translated from the following code:
             %%
             %%     -export(['__info__'/1]).
             %%     '__info__'(:compile) -> [{source, "docception"} | module_info(:compile)];
             %%     '__info__'(Arg) -> module_info(Arg).
             %%
             %% I transformed it in two steps:
             %%
             %% 1) -export
             %%   erl_parse:parse_form(element(2, erl_scan:string("f() -> 10."))).
             %% 2) __info__
             %%    107> Form =
             %%    107> "'__info__'(compile) -> [{source, \"docception\"} | module_info(compile)];\n"
             %%    107> "'__info__'(Arg) -> module_info(Arg).".
             %%    108> erl_parse:parse_form(element(2, erl_scan:string(Form))).
             {attribute,1,export,[{'__info__',1}]}, % 1)
             {function,1,'__info__',1,              % 2)
              [{clause,1,
                [{atom,1,compile}],
                [],
                [{cons,1,
                  {tuple,1,[{atom,1,source},{string,1,"docception"}]},
                  {call,1,{atom,1,module_info},[{atom,1,compile}]}}]},
               {clause,1,
                [{var,1,'Arg'}],
                [],
                [{call,1,{atom,1,module_info},[{var,1,'Arg'}]}]}]}
            ],
    DocsChunk =
        term_to_binary(
          {
              docs_v1,
              erl_anno:new(Line),
              elixir,
              <<"text/markdown">>,
              #{<<"en">> => String},
              #{},
              []
          }, [compressed]),
    Chunks = [{<<"Docs">>, DocsChunk}],
    CompileOpts = [{extra_chunks, Chunks}],
    case compile:forms(Forms, CompileOpts) of
        {ok, _, Beam} -> {ok, Beam};
        error -> error
    end.

