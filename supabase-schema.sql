-- Meal Inventory & Grocery Planner: shared database schema
-- Run this once in the Supabase SQL Editor (Project > SQL Editor > New query > Run)

create extension if not exists pgcrypto;

create table if not exists pantry (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  qty double precision default 0,
  unit text,
  expiration date,
  threshold double precision,
  updated_at timestamptz default now()
);

create table if not exists recipes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tags text,
  instructions text,
  ingredients jsonb default '[]'::jsonb,
  updated_at timestamptz default now()
);

create table if not exists meal_plan (
  date date not null,
  meal text not null check (meal in ('breakfast','lunch','dinner')),
  recipe_id uuid references recipes(id) on delete set null,
  cooked boolean default false,
  updated_at timestamptz default now(),
  primary key (date, meal)
);

alter table meal_plan add column if not exists cooked boolean default false;

create table if not exists grocery_list (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  qty double precision default 0,
  unit text,
  checked boolean default false,
  source text,
  updated_at timestamptz default now()
);

-- Row Level Security: enabled, with permissive policies so the app's
-- publishable key can read/write. Actual access is gated by the app's
-- passcode screen, not by RLS (there are no user accounts in this app).
alter table pantry enable row level security;
alter table recipes enable row level security;
alter table meal_plan enable row level security;
alter table grocery_list enable row level security;

drop policy if exists "allow all pantry" on pantry;
create policy "allow all pantry" on pantry for all using (true) with check (true);

drop policy if exists "allow all recipes" on recipes;
create policy "allow all recipes" on recipes for all using (true) with check (true);

drop policy if exists "allow all meal_plan" on meal_plan;
create policy "allow all meal_plan" on meal_plan for all using (true) with check (true);

drop policy if exists "allow all grocery_list" on grocery_list;
create policy "allow all grocery_list" on grocery_list for all using (true) with check (true);

-- Enable realtime sync for live multi-user updates
alter publication supabase_realtime add table pantry, recipes, meal_plan, grocery_list;
