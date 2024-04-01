
drop table if exists customers;
CREATE TABLE public.customers (
    id_string integer NULL,
    first_name varchar(50) NULL,
    last_name varchar(50) NULL,
    gender varchar(50) NULL,
    email varchar(50) NULL,
    phone_number varchar(10) NULL,
    address varchar(50) NULL,
    income integer NULL,
    state varchar(50) NULL,
    birthday date NULL,
    hair_color varchar(50) NULL,
    credit integer NULL,
    PRIMARY KEY (id_string)
);

drop table if exists loans;
CREATE TABLE public.loans (
    id_string integer NULL,
    customer_id_string integer,
    lender_state varchar(50) NULL,
    origination_date varchar(50) NULL,
    due_date date NULL,
    term_weeks integer NULL,
    principal_amount real NULL,
    total_due_amount real NULL,
    paid_amount real NULL,
    fee_amount real NULL,
    collateral_assessed real NULL,
    collateral_sold real NULL,
    defaulted integer NULL
--    PRIMARY KEY (id_string),
--    CONSTRAINT fk_customer_id
--        FOREIGN KEY (customer_id_string) REFERENCES customers (id_string)
);


drop table if exists transactions;
CREATE TABLE public.transactions (
    id_string integer NULL,
    loan_id_string integer NULL,
    amount real NULL,
    "date" date NULL,
    direction varchar(50) NULL,
    is_late integer NULL,
    fee real NULL
--    PRIMARY KEY (id_string)
--    , CONSTRAINT fk_loan_id
--        FOREIGN KEY (loan_id_string) REFERENCES loans (id_string)
);


