-- laboratory work №10: sql transactions and isolation levels
-- all content is written in lowercase as requested

-- 1. objective
-- this lab explores transactions, acid properties, commit/rollback/savepoint usage, and sql isolation levels.

-- 2. theoretical background
-- 2.1 what is a transaction?
-- a transaction is a sequence of sql operations executed as one logical unit.

-- 2.2 acid properties
-- atomic — all or nothing.
-- consistent — db stays valid.
-- isolated — appears to run alone.
-- durable — changes persist after crash.

-- 2.3 transaction control statements (examples)
begin;
commit;
rollback;
savepoint savepoint_name;
rollback to savepoint_name;
release savepoint savepoint_name;

-- 2.4 isolation levels (examples)
-- set transaction isolation level serializable;
-- begin transaction isolation level repeatable read;

-- 3. practical tasks
-- 3.1 setup tables and test data
create table if not exists accounts (
  id serial primary key,
  name varchar(100) not null,
  balance decimal(10,2) default 0.00
);

create table if not exists products (
  id serial primary key,
  shop varchar(100) not null,
  product varchar(100) not null,
  price decimal(10,2) not null
);

-- insert test data (use once)
insert into accounts (name, balance) values
('alice', 1000.00),
('bob', 500.00),
('wally', 750.00);

insert into products (shop, product, price) values
('joe''s shop', 'coke', 2.50),
('joe''s shop', 'pepsi', 3.00);

-- 3.2 task 1 — basic transaction with commit
-- transfer 100 from alice to bob atomically
begin;
update accounts set balance = balance - 100.00 where name = 'alice';
update accounts set balance = balance + 100.00 where name = 'bob';
commit;

-- expected: alice 900.00, bob 600.00

-- 3.3 task 2 — rollback demonstration
begin;
update accounts set balance = balance - 500.00 where name = 'alice';
select * from accounts where name = 'alice';
rollback;
select * from accounts where name = 'alice';
-- expected: after update (before rollback) alice shows 500.00 in that session; after rollback alice returns to 1000.00

-- 3.4 task 3 — savepoints (partial rollback)
begin;
update accounts set balance = balance - 100.00 where name = 'alice';
savepoint my_savepoint;
update accounts set balance = balance + 100.00 where name = 'bob';
rollback to my_savepoint;
update accounts set balance = balance + 100.00 where name = 'wally';
commit;
-- expected final: alice 900.00, bob 500.00, wally 850.00

-- 3.5 task 4 — isolation level demonstration (requires two separate sessions)
-- scenario a: read committed (terminal 1)
-- begin transaction isolation level read committed;
-- select * from products where shop = 'joe''s shop';
-- (wait for terminal 2 to change and commit)
-- select * from products where shop = 'joe''s shop';
-- commit;

-- terminal 2 (while terminal 1 is open):
-- begin;
-- delete from products where shop = 'joe''s shop';
-- insert into products (shop, product, price) values ('joe''s shop', 'fanta', 3.50);
-- commit;

-- scenario b: serializable (repeat above with serializable)
-- begin transaction isolation level serializable;
-- select * from products where shop = 'joe''s shop';
-- ... etc

-- 3.6 task 5 — phantom read demonstration (repeatable read)
-- terminal 1:
-- begin transaction isolation level repeatable read;
-- select max(price), min(price) from products where shop = 'joe''s shop';
-- (wait for terminal 2 to insert and commit)
-- select max(price), min(price) from products where shop = 'joe''s shop';
-- commit;
-- terminal 2:
-- begin;
-- insert into products (shop, product, price) values ('joe''s shop', 'sprite', 4.00);
-- commit;

-- 3.7 task 6 — dirty read demonstration (read uncommitted)
-- terminal 1:
-- begin transaction isolation level read uncommitted;
-- select * from products where shop = 'joe''s shop';
-- (wait for terminal 2 to update but not commit)
-- select * from products where shop = 'joe''s shop';
-- (wait for terminal 2 to rollback)
-- select * from products where shop = 'joe''s shop';
-- commit;
-- terminal 2:
-- begin;
-- update products set price = 99.99 where product = 'fanta';
-- -- don't commit yet
-- rollback;

-- 4. independent exercises (templates)
-- exercise 1: transfer $200 from bob to wally only if bob has sufficient funds
-- example (plpgsql for conditional logic):
/*
do $$
begin
  begin transaction;
    update accounts set balance = balance - 200.00 where name = 'bob' and balance >= 200.00;
    if (select balance from accounts where name = 'bob') >= 0 then
      update accounts set balance = balance + 200.00 where name = 'wally';
      commit;
    else
      rollback;
    end if;
  exception when others then
    rollback;
    raise;
  end;
end $$;
*/

-- exercise 2: multiple savepoints workflow (template)
/*
begin;
insert into products (shop, product, price) values ('joe''s shop', 'testprod', 1.00);
savepoint sp1;
update products set price = 1.50 where product = 'testprod';
savepoint sp2;
delete from products where product = 'testprod';
rollback to sp1; -- undo delete and second update
commit;
-- final state: product 'testprod' exists with price 1.50
*/

-- exercise 3: concurrent withdrawals
-- simulate by running two sessions that try to withdraw from same account and observe locks / serialization.

-- exercise 4: demonstrate max < min anomaly when transactions are not used properly (use interleaved updates/selects)

-- 5. self-assessment questions (answer in lab report)
-- 1) explain each acid property with an example
-- 2) difference between commit and rollback
-- 3) when to use savepoint
-- 4) compare isolation levels
-- 5) what is a dirty read and which level allows it
-- 6) what is a non-repeatable read
-- 7) what is a phantom read and which levels prevent it
-- 8) why choose read committed over serializable in high-traffic apps
-- 9) how transactions help maintain consistency
-- 10) what happens to uncommitted changes if db crashes

-- 6. lab report requirements
-- include screenshots, answers, sql code, independent exercises, self-assessment, conclusion

-- end of file
