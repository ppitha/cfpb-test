-- Try matching expected payment amount from the loan to actual payment amounts,
-- where loan id is missing.
select customer_id_string,
    lender_state
    origination_date,
    total_due_amount / term_weeks as payment_due,
    t.id_string as transaction_id ,
    t."date",
    t.amount ,
     t.fee
from loans l
left join transactions t
    on t.loan_id_string is null and t.amount = l.total_due_amount / l.term_weeks
where l.id_string is null
and defaulted = 0
order by customer_id_string , origination_date , "date";

-- First attempt - match on calculated payment amount to actual payment amount
-- Then try matching on total paid - ithis is better
-- Matching 22 loans (on payment amount ) match 145 transactions
-- Leaves 128 transactions unmatched this way.
-- These can be grouped by payment amount, yielding 16 groups.
-- This does not check dates
with new_loans as (
    select customer_id_string, lender_state, origination_date, paid_amount,
        total_due_amount / term_weeks as payment_due
    from loans
    where id_string is null
    and defaulted = 0
)
,
matching as (
    select nl.customer_id_string, nl.lender_state, nl.origination_date, nl.payment_due,
        nl.paid_amount, sum(t.amount) as total_payments, count(*) as payments
    from transactions t
    join new_loans nl on t.amount = nl.payment_due
    where t.loan_id_string is null
    group by 1, 2, 3, 4, 5
    order by 1, 2, 3
)
--select * from matching;
, unmatched as (
    select  t.amount, count(*) as payment_count, t.amount * count(*) as total_paid
    from transactions t
    left join new_loans nl on t.amount = nl.payment_due
    where t.loan_id_string is null
    and nl.customer_id_string is null
    group by t.amount
), match_paid_amt as (
    select *
    from unmatched u
    left join new_loans nl on u.total_paid = nl.paid_amount
)
select * from matching
union all
select customer_id_string, lender_state, origination_date, payment_due,
        paid_amount, total_paid, payment_count
from match_paid_amt


-- Second attempt.
-- Match loans with no ID to trans with no loan id
-- This matches based on total paid matching, and the first transaction
-- (min_date) being later than the origination date, and the last transaction
-- being no more than 20 days after the due date (20 was determined empirically)
with new_loans as (
    select customer_id_string, lender_state, origination_date, due_date, paid_amount,
        total_due_amount / term_weeks as payment_due
    from loans
    where id_string is null
    and defaulted = 0
),
no_loan_trans as (
    select  t.amount, min("date") as min_date, max("date") as max_date,
        count(*) as payment_count, t.amount * count(*) as total_paid, count(*) as transaction_count
    from transactions t
    where t.loan_id_string is null
    group by t.amount
),
matching as (
    select customer_id_string, lender_state, origination_date, due_date, paid_amount, nlt.min_date, nlt.max_date, nlt.total_paid, transaction_count
    from no_loan_trans nlt
    left join new_loans nl
    on nlt.total_paid = nl.paid_amount
    and min_date > origination_date::date
    and max_date < due_date +20
    order by paid_amount
)
select customer_id_string is not null as matched, sum(transaction_count)
from matching
group by 1


