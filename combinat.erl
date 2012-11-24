-module(combinat).
-export([permuts_out/2, combs_out/2, permuts_out_2/2, combs_out_2/2, permuts_res/2, combs_res/2, permuts_clb/3, combs_clb/3, permuts_comp/2, combs_comp/2, proc/3]).


permuts_out(List, Number) -> permuts_out(List, [], Number, List).
permuts_out(_Remain, Result, Number, _List) when length(Result) == Number -> 
    io:format("~w~n", [Result]);
permuts_out([], _Result, _Number, _List) -> ok;
permuts_out([RemainH|RemainT], Result, Number, List) -> 
    permuts_out(RemainT, Result, Number, List),
    permuts_out(List -- [RemainH|Result], [RemainH|Result], Number, List).

combs_out(List, Number) -> combs_out(List, [], Number).
combs_out(_Remain, Result, Number) when length(Result) == Number -> 
    io:format("~w~n", [Result]);
combs_out([], _Result, _Number) -> ok;
combs_out([RemainH|RemainT], Result, Number) -> 
    combs_out(RemainT, Result, Number),
    combs_out(RemainT, [RemainH|Result], Number).


permuts_out_2(List, Number) -> permuts_out_hor(List, [], Number, List).
permuts_out_hor([], _Result, _Number, _List) -> ok;
permuts_out_hor([RemainH|RemainT], Result, Number, List) -> 
    permuts_out_hor(RemainT, Result, Number, List),
    permuts_out_ver(List -- [RemainH|Result], [RemainH|Result], Number, List).
permuts_out_ver(_Remain, Result, Number, _List) when length(Result) == Number -> 
    io:format("~w~n", [Result]);
permuts_out_ver(Remain, Result, Number, List) ->
    permuts_out_hor(Remain, Result, Number, List).

combs_out_2(List, Number) -> combs_out_hor(List, [], Number).
combs_out_hor([], _Result, _Number) -> ok;
combs_out_hor([RemainH|RemainT], Result, Number) -> 
    combs_out_hor(RemainT, Result, Number),
    combs_out_ver(RemainT, [RemainH|Result], Number).
combs_out_ver(_Remain, Result, Number) when length(Result) == Number -> 
    io:format("~w~n", [Result]);
combs_out_ver(Remain, Result, Number) ->
    combs_out_hor(Remain, Result, Number).


permuts_res(List, Number) -> permuts_res(List, [], Number, List).
permuts_res(_Remain, Result, Number, _List) when length(Result) == Number -> 
    [Result];
permuts_res([], _Result, _Number, _List) -> [];
permuts_res([RemainH|RemainT], Result, Number, List) -> 
    permuts_res(RemainT, Result, Number, List) ++
    permuts_res(List -- [RemainH|Result], [RemainH|Result], Number, List).

combs_res(List, Number) -> combs_res(List, [], Number).
combs_res(_Remain, Result, Number) when length(Result) == Number -> 
    [Result];
combs_res([], _Result, _Number) -> [];
combs_res([RemainH|RemainT], Result, Number) -> 
    combs_res(RemainT, Result, Number) ++
    combs_res(RemainT, [RemainH|Result], Number).


permuts_clb(List, Number, Callback) -> permuts_clb(List, [], Number, List, Callback).
permuts_clb(_Remain, Result, Number, _List, Callback) when length(Result) == Number -> 
    Callback(Result);
permuts_clb([], _Result, _Number, _List, _Callback) -> ok;
permuts_clb([RemainH|RemainT], Result, Number, List, Callback) -> 
    permuts_clb(RemainT, Result, Number, List, Callback),
    permuts_clb(List -- [RemainH|Result], [RemainH|Result], Number, List, Callback).

combs_clb(List, Number, Callback) -> combs_clb(List, [], Number, Callback).
combs_clb(_Remain, Result, Number, Callback) when length(Result) == Number -> 
    Callback(Result);
combs_clb([], _Result, _Number, _Callback) -> ok;
combs_clb([RemainH|RemainT], Result, Number, Callback) -> 
    combs_clb(RemainT, Result, Number, Callback),
    combs_clb(RemainT, [RemainH|Result], Number, Callback).


%% Function = permuts_clb | combs_clb
proc(Function, List, Number) ->
    process_flag(trap_exit, true),    
    Supervisor = self(),
    spawn_link(combinat, Function, [List, Number, fun(R)->Supervisor!R end]),
    loop([]).

loop(Total) ->
    receive
	{'EXIT', Worker, normal} ->
	    unlink(Worker),
	    Total;
	Result ->
	    loop([Result|Total])
    end.


permuts_comp(List, Number) -> permuts_comp(List, [], Number).
permuts_comp(_Remain, Result, Number) when length(Result) == Number -> 
    io:format("~w~n", [Result]);
permuts_comp(Remain, Result, Number) -> 
    [permuts_comp(Remain -- [R], [R|Result], Number) || R <- Remain].

combs_comp(List, Number) -> 
    ListIndexed = lists:zip(List, lists:seq(1, length(List))),
    combs_comp(ListIndexed, [], Number).
combs_comp(_Remain, Result, Number) when length(Result) == Number ->
    {ResultValue, _I} = lists:unzip(Result),
    io:format("~w~n", [ResultValue]);
combs_comp(Remain, [], Number) ->
    [combs_comp(Remain -- [R], [R], Number) || R <- Remain];
combs_comp(Remain, [{HValue,HIndex}|T], Number) ->
    [combs_comp(Remain -- [{R,I}], [{R,I}|[{HValue,HIndex}|T]], Number) || {R,I} <- Remain, I > HIndex].

	
permuts(List, Number) -> 
    {Res, _Rem} = lists:unzip(reduce_permuts(List, Number)),
    Res.
reduce_permuts(List, 0) -> [{[], List}];
reduce_permuts(List, Number) ->
    lists:foldr(fun(X, Acc)->map_permuts(X)++Acc end, [], reduce_permuts(List,  Number - 1)).
map_permuts({Res, Rem}) ->
    [{[X|Res], Rem--[X]}||X<-Rem].

combs(List, Number) -> 
    {Res, _Rem} = lists:unzip(reduce_combs(List, Number)),
    Res.
reduce_combs(List, 0) -> [{[], List}];
reduce_combs(List, Number) ->
    lists:foldr(fun(X, Acc)->map_combs(X)++Acc end, [], reduce_combs(List,  Number - 1)).
map_combs({_Res, []}) -> [];
map_combs({Res, [HRem|TRem]}) ->
    [{[HRem|Res], TRem}|map_combs({Res, TRem})].


permuts2(List, Number) -> 
    {Res, _Rem} = lists:unzip(each_level(fun map_permuts/1, List, Number)),
    Res.
combs2(List, Number) -> 
    {Res, _Rem} = lists:unzip(each_level(fun map_combs/1, List, Number)),
    Res.
each_level(Fun, List, Number) ->
    lists:foldl(fun(_X, Acc1)->lists:foldr(fun(X, Acc2)->Fun(X)++Acc2 end, [], Acc1)  end, 
        [{[], List}], 
        lists:seq(1, Number)).
