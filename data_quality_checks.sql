
-- Customers
-- Check PK - OK
select * from loans where id_string is null;
-- check surrogate key
select id_string from customers group by id_string having count(*) > 1;
-- just look at the data
select * from customers order by income;
-- check columns for uniqueness
select email from customers group by 1 having count(*) > 1;
select phone_number from customers group by 1 having count(*) > 1;
-- Not unique on first,last - ok
select first_name, last_name from customers group by 1,2 having count(*) > 1;
select address  from customers group by 1 having count(*) > 1;

-- Loans
-- Check PK - 50 records
select * from loans where id_string is null;
-- check FK - OK
select * from loans where customer_id_string is null;

-- check for null values
select * from loans 
where lender_state is null 
or origination_date is null 
or principal_amount is null 
or due_date  is null
or term_weeks is null 
or collateral_assessed is null
or principal_amount = 0;

-- Examine loans that might be duplicates more closely
with _mult as (
    select customer_id_string, principal_amount, count(*)
    from loans group by 1,2 having count(*) > 1
)
select * from loans L
join _mult m
on L.customer_id_string = m.customer_id_string
    and  L.principal_amount = m.principal_amount

-- Confirm uniqueness of loans by larger key
select customer_id_string, principal_amount, lender_state, origination_date, count(*)
from loans
group by 1,2, 3, 4 having count(*) > 1

-- Does every loan have a customer in the customers table? 
select customer_id_string from loans 
exclude 
select id_string from customers;

-- Transactions
-- check pk - 50 (also missing loan_id_string)
select * from transactions where id_string is null;
-- check FK - 211 with no loan_id_string values (but with an id_string)
select * from transactions
where loan_id_string is null
and id_string is not null;

-- check amount, date values
select * from transactions
where amount is null 
or amount <= 0 
or fee < 0 
or "date"::date > current_date;

-- profile "date"
select min("date"), max("date") from transactions;

-- Uniqueness of transactions
select loan_id_string, date, amount 
from transactions 
where loan_id_string is not null
group by 1, 2, 3 having count(*) > 1;

-- Check values
select distinct is_late from transactions;
select distinct direction from transactions;

-- Check for nulls
select * from transactions t
where amount is null
or "date" is null
or direction is null
or is_late is null
or fee is null

-- Is every transaction for a loan in the loans table? 
select loan_id_string from transactions t 
except
select id_string from loans

-- Check that loans.paid_amount matches total payments
select loan_id, principal_amount, paid_amount, sum(payment_amount) as payments
from loan_transactions
group by 1, 2, 3
having abs(paid_amount - sum(payment_amount)) > 1 -- allow some rounding




