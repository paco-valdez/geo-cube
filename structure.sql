-- example_schema
\timing off
\pset null ''
\x off
\pset pager
\set ON_ERROR_STOP on
\set QUIET 1

begin;
-- drop schema if exists public cascade;
create schema if not exists public;
set search_path to public;

create table if not exists tenants (
  tenant_id integer primary key generated by default as identity,
  name text
);

create table if not exists vendors (
  tenant_id integer not null references tenants,
  vendor_id integer primary key generated by default as identity,
  name text,
  credit_limit money,
  lat float,
  lon float,
  h3_9 varchar(10),
  _updated_at timestamp default now()
);

create table if not exists orders (
  tenant_id integer not null,
  order_id integer primary key generated by default as identity,
  vendor_id integer references vendors,
  title text,
  budgeted_amount money,
  lat float,
  lon float,
  h3_9 varchar(10),
  _updated_at timestamp default now()
);

create table if not exists line_items (
  tenant_id integer not null,
  line_item_id integer primary key generated by default as identity,
  order_id integer references orders,
  title text,
  cost money,
  _updated_at timestamp default now()
);
commit;

begin;

insert into tenants (tenant_id, name) values
(1, 'A'),
(2, 'B')
on conflict do nothing;

insert into vendors (tenant_id,vendor_id, name, credit_limit, lat, lon, h3_9) values
  (1, 1, 'Acme', 10230, 32.743249, -117.189582, '29a411a2b')
, (1, 2, 'National', 456.12, 32.671550, -117.114431, '29a41a58b')  -- this vendor will have no orders
, (1, 3, 'Empty', 101.01, 33.758991, -118.245725, '29a560687')
on conflict do nothing;

insert into orders (tenant_id, order_id, vendor_id, title, budgeted_amount, lat, lon, h3_9) values
  (1,1,1,'$100 order w/3li', 100.00, 32.78401236891236, -117.19916781641939, '29a4031db')
, (1,2,1,'$200 order w/1li', 200.00, 32.72343350245376, -117.1304643948471 , '29a41a8d3')
, (1,3,1,'$302 order w/0li', 302.00, 32.71695046609805, -117.16107380616378, '29a41ad8b')
, (1,4,3,'$404 order w/0li', 404.00, 33.82524899050014, -118.02409857821776, '29a56b28f')
on conflict do nothing;

insert into line_items (tenant_id, line_item_id, order_id, title, cost) values
(1,1,1,'materials', 20.00),
(1,2,1,'lumber', 340.00),
(1,3,1,'labor', 100.00),
(1,4,2,'labor', 5000.00)
on conflict do nothing;

commit;
\d
