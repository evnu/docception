%%
%% Helper to create loadable binaries from a markdown string.
%%
%% This is written in Erlang to resemble Elixir's own `elixir_erl.erl` closely to allow
%% maintaining this.
%%
-module(beam_me).

-export([string_to_beam/3]).

string_to_beam(ModuleName, String, Source)
  when is_atom(ModuleName),
       is_binary(String) ->
    Line = erl_anno:new(1),
    Forms = [
             {attribute, Line, module, ModuleName},
             %% __info__/1 must be available!
             %%
             %% This is the form translated from the following code:
             %%
             %%     -export(['__info__'/1]).
             %%     '__info__'(:compile) -> [{source, "SOURCE"} | module_info(:compile)];
             %%     '__info__'(Arg) -> module_info(Arg).
             %%
             %% I transformed it in two steps:
             %%
             %% 1) -export
             %%   erl_parse:parse_form(element(2, erl_scan:string("f() -> 10."))).
             %% 2) __info__
             %%    107> Form =
             %%    107> "'__info__'(compile) -> [{source, \"SOURCE\"} | module_info(compile)];\n"
             %%    107> "'__info__'(Arg) -> module_info(Arg).".
             %%    108> erl_parse:parse_form(element(2, erl_scan:string(Form))).
             {attribute,Line,export,[{'__info__',Line}]}, % 1)
             {function,Line,'__info__',Line,              % 2)
              [{clause,Line,
                [{atom,Line,compile}],
                [],
                [{cons,Line,
                  {tuple,Line,[{atom,Line,source},{string,Line,Source}]},
                  {call,Line,{atom,Line,module_info},[{atom,Line,compile}]}}]},
               {clause,Line,
                [{var,Line,'Arg'}],
                [],
                [{call,Line,{atom,Line,module_info},[{var,Line,'Arg'}]}]}]}
            ],
    DocsChunk =
        term_to_binary(
          {
              docs_v1,
              Line,
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

