-- 1. Create a procedure that adds a late fee to any customer who returned their rental after 7 days.

-- Create procedure to add late fee
CREATE PROCEDURE add_late_fee()
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE payment
  SET amount = amount + 5
  WHERE rental_id IN (
    SELECT rental_id
    FROM rental
    WHERE rental_duration > INTERVAL '7 days'
  );
END;
$$;

-- Check rental and payment tables to see amounts of a payment with a rental duration of more than 7 days
SELECT*
FROM rental
ORDER BY rental_id DESC;

SELECT*
FROM payment
ORDER BY rental_id DESC;

-- Call the procedure to add the late fees to entries with a duration greater than 7 days
CALL add_late_fee();

-- Check tables once more to make sure that the $5 fee was added to entries with a duration longer than 7 days
SELECT*
FROM rental
ORDER BY rental_id DESC;

SELECT*
FROM payment
ORDER BY rental_id DESC;


-- 2. Add a new column in the customer table for Platinum Member.
-- This can be a boolean.
-- Platinum Members are any customers who have spent over $200. 
-- Create a procedure that updates the Platinum Member column to 
-- True for any customer who has spent over $200 and False for any customer who has spent less than $200.

-- Add the column 'platinum_member' to the customer table
ALTER TABLE customer
ADD COLUMN platinum_member BOOLEAN DEFAULT false;

-- Check customer table to ensure column was added correctly
SELECT*
FROM customer;

-- Create procedure to update Platinum Membership for customers who've spent over $200
CREATE PROCEDURE update_platinum_status()
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE customer
  SET platinum_member = true
  WHERE customer_id IN (
    SELECT customer_id
    FROM (
      SELECT customer_id, SUM(amount) as total_amount
      FROM payment
      GROUP BY customer_id
    ) as customer_totals
    WHERE total_amount > 200
  );
END;
$$;

-- Call the new procedure
CALL update_platinum_status();

-- Check the customer table to see if the procedure worked correctly.
SELECT*
FROM customer
WHERE platinum_member = True;


