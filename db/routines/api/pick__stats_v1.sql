begin;
set role app_loto_owner;

create or replace function api.pick_stats_v1(p_pick app.main_num[])
returns jsonb
language sql
stable
as $$
select jsonb_build_object(
  'pick', p_pick,
  'summary', (
    select jsonb_build_object(
      'total_draws', s.total_draws,
      'occurrences', s.occurrences,
      'pct_of_draws', s.pct_of_draws
    )
    from app.pick_stats(p_pick) s
  ),
  'draws', (
    select coalesce(s.draws, '[]'::jsonb)
    from app.pick_stats(p_pick) s
  )
  -- plus tard tu ajoutes:
  -- , 'numbers', (select jsonb_agg(to_jsonb(ns)) from app.number_stats(p_pick) ns)
  -- , 'pairs',   (select jsonb_agg(to_jsonb(ps)) from app.pair_stats(p_pick) ps)
)
$$;


reset role;
commit;
