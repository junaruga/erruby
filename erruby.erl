-module(erruby).
-export([eruby/1, start_ruby/0, stop_ruby/1, parse_ast/2]).

main([SrcFileName]) ->
  try
    io:format("input file name ~s\n", [SrcFileName]),
    eruby(SrcFileName)
  catch
    _:_ ->
      io:format("error\n", []),
      erlang:display(erlang:get_stacktrace())
  end;

main(_) ->
  usage().

eruby(SrcFileName) ->
  {ok, Binary} = file:read_file(SrcFileName),
  FileLines = binary:bin_to_list(Binary),
  Ruby = start_ruby(),
  Ast = parse_ast(Ruby, FileLines),
  stop_ruby(Ruby),
  eval_ast(Ast).

eval_ast(Ast) ->
  print_ast(Ast).

install_encoder(Ruby) ->
  ruby:call(Ruby, './erruby.rb', 'install_encoder',[]).

print_ast(Ast) ->
  io:format("~p ~n",[Ast]).

parse_ast(Ruby, String) ->
  ruby:call(Ruby, './erruby.rb','parse', [String]).

add_lib_path() ->
  code:add_path("./erlport/ebin").

stop_ruby(Ruby) ->
  ruby:stop(Ruby).

start_ruby() ->
  add_lib_path(),
  {ok, Ruby} = ruby:start(),
  install_encoder(Ruby),
  Ruby.

usage() ->
  io:format("usage: erruby filename\n"),
  halt(1).
