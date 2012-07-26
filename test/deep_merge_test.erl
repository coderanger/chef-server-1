-module(deep_merge_test).

-include_lib("eunit/include/eunit.hrl").

%% Sort everything that we can sort so that expected values will compare equal
%% to computed values regardless of sorting (Our use case for deep_merge is
%% indifferent to sort order).
normalize({JSONObject}) ->
  {normalize_json_object(JSONObject)};
normalize(JSONArray) when is_list(JSONArray) ->
  lists:sort([normalize(JSONTerm) || JSONTerm <- JSONArray]);
normalize(Anything) ->
  Anything.

%% Normalize a list of {Key, Value} Tuples.
normalize_json_object(JSONObject) ->
  lists:sort([{Key, normalize(Value)} || {Key, Value} <- JSONObject]).

json_read(Filename) ->
  {ok, Daters} = file:read_file(Filename),
  DecodedDaters = ejson:decode(Daters),
  DecodedDaters.


deep_merge_comparison({MergeeFile, OtherFile, ExpectedFile}) ->
  TestIndex = string:sub_string(filename:basename(MergeeFile),1,3),
  MergeeTerm   = json_read(MergeeFile),
  OtherTerm    = json_read(OtherFile),
  ExpectedTerm = json_read(ExpectedFile),
  {"Deep Merge Test: " ++ TestIndex, fun() ->
        Result = deep_merge:merge(MergeeTerm, OtherTerm),
        NormalizedExpected = normalize(ExpectedTerm),
        NormalizedResult = normalize(Result),
        ?assertEqual(NormalizedExpected,NormalizedResult)
    end
  }.

compat_test_() ->
  {setup,
    fun() ->
        MergeeFile   = filelib:wildcard("../test/deep_merge_compat/*mergee.json"),
        OtherFile    = filelib:wildcard("../test/deep_merge_compat/*other.json"),
        ExpectedFile = filelib:wildcard("../test/deep_merge_compat/*expected.json"),
        lists:zip3(MergeeFile, OtherFile, ExpectedFile)
    end,
    fun(TestDataTriples) ->
        [deep_merge_comparison(TestDataTriple) ||TestDataTriple <- TestDataTriples ]
    end

  }.

