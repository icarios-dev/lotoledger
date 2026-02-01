begin;
set role app_loto_owner;

-- pgls-ignore-start lint/safety/banDropTable
drop table if exists app.draws;
-- pgls-ignore-end lint/safety/banDropTable

-- canonical table in app
--
create table app.draws(
	id bigserial primary key,
	rule_set app.rule_set not null,
	draw_sub app.draw_sub,
	draw_date date not null,
	order_nums app.main_num[] not null,
	main_sorted app.main_num[] generated always as (
		app.sort_main_nums(order_nums)
	) stored,
	bonus_type app.bonus_type,
	bonus_value int, -- plage vérifiée par contrainte
	draw_key text generated always as (
		app.make_draw_key(order_nums, bonus_type, bonus_value)
	) stored,
	unique (rule_set, draw_date, draw_sub),
	constraint order_nums_len check (array_length(order_nums, 1) = app.expected_main_count(rule_set)),
	constraint array_same_len check (array_length(main_sorted, 1) = array_length(order_nums, 1)),
	constraint no_dupes check (app.array_no_dupes(main_sorted)),
	constraint expected_bonus check (bonus_type is not distinct from app.expected_bonus_type(rule_set)),
	constraint bonus_valid check (app.valid_bonus(bonus_type, bonus_value)),
	constraint draw_date_sane check (draw_date between date '1976-05-19' and current_date)
);
create index if not exists draws_date_idx on app.draws(draw_date);
create index if not exists draws_main_sorted_gin on app.draws using gin(main_sorted);
create index if not exists draws_order_nums_gin on app.draws using gin(order_nums);
create index if not exists draws_draw_key_idx on app.draws(rule_set, draw_key);

reset role;
commit;
