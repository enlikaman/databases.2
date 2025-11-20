-- laboratory work 8: sql indexes (lowercase version)

-- part 1: setup
create table departments (
    dept_id int primary key,
    dept_name varchar(50),
    location varchar(50)
);

create table employees (
    emp_id int primary key,
    emp_name varchar(100),
    dept_id int,
    salary decimal(10,2),
    email varchar(100),
    phone varchar(20),
    hire_date date,
    foreign key (dept_id) references departments(dept_id)
);

create table projects (
    proj_id int primary key,
    proj_name varchar(100),
    budget decimal(12,2),
    dept_id int,
    foreign key (dept_id) references departments(dept_id)
);

-- part 2: indexes
create index emp_salary_idx on employees(salary);
create index emp_dept_idx on employees(dept_id);

-- part 3: multicolumn
create index emp_dept_salary_idx on employees(dept_id, salary);
create index emp_salary_dept_idx on employees(salary, dept_id);

-- part 4: unique
create unique index emp_email_unique_idx on employees(email);

-- part 5: sorting
create index emp_salary_desc_idx on employees(salary desc);
create index proj_budget_nulls_first_idx on projects(budget nulls first);

-- part 6: expression
create index emp_name_lower_idx on employees(lower(emp_name));
create index emp_hire_year_idx on employees(extract(year from hire_date));

-- part 7: managing
alter index emp_salary_idx rename to employees_salary_index;
drop index if exists emp_salary_dept_idx;
reindex index employees_salary_index;

-- part 8: partial index
create index proj_high_budget_idx on projects(budget) where budget > 80000;

-- part 9: index types
create index dept_name_hash_idx on departments using hash (dept_name);
create index proj_name_btree_idx on projects(proj_name);
create index proj_name_hash_idx on projects using hash (proj_name);

-- part 10: cleanup
drop index if exists proj_name_hash_idx;

-- documentation view
create view index_documentation as
select
    tablename,
    indexname,
    indexdef,
    'improves salary-based queries' as purpose
from pg_indexes
where schemaname = 'public'
and indexname like '%salary%';
