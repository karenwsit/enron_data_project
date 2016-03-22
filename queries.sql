/*
Question 1: How many emails did each person receive each day?
Comments: Solution does not display people who received 0 emails. To do so, a calendar table needs to be created & joined to.
Assumption: Each recipient/sender has 1 unique email when in real life, there could be multiple variations/forms of the 'same' email 
*/

SELECT strftime('%m-%d-%Y', date), recipient, COUNT(*)
FROM email_recipients
    JOIN emails ON email_fk = email_id
GROUP BY recipient, strftime('%m-%d-%Y', date)
ORDER BY date;

/*
Question 2A: Identify the person (or people) who received the largest number of direct emails
Comments: 2 Solutions have been provided. The first query uses the num_recipients column in email_recipients table which denormalizes the database but makes a cleaner & simpler query. The second query does not use the num_recipients column which maintains normalization but results in a more complicated query.
Assumption: Each recipient/sender has 1 unique email when in real life, there could be multiple variations/forms of the 'same' email 
*/

-- Solution 1 using num_recipients column

SELECT recipient, MAX(num_direct_emails)
FROM (
    SELECT COUNT(num_recipients) AS num_direct_emails , recipient
    FROM email_recipients
    WHERE num_recipients=1
    GROUP BY recipient
);

-- Solution 2 without using num_recipients column in email_recipients table

SELECT recipient, MAX(num_dir_emails)
FROM (
    SELECT recipient, COUNT(*) AS num_dir_emails
    FROM email_recipients, (
        SELECT email_fk, COUNT(*) AS num_dir_emails
        FROM email_recipients
        GROUP BY email_fk ) AS t1
    WHERE email_recipients.email_fk = t1.email_fk AND t1.num_dir_emails = 1
    GROUP BY recipient
);

/*
Question 2B: Identify the person (or people) who sent the largest number of broadcast emails.
Comments: 2 Solutions have been provided again. The first query uses the num_recipients column in email_recipients table which denormalizes the database AND results in a more complicated query.The second query does not use the num_recipients column which maintains normalization AND results in a simpler and cleaner query.
Assumption: Each recipient/sender has 1 unique email when in real life, there could be multiple variations/forms of the 'same' email 
*/

-- Solution 1 using num_recipients table

SELECT t2.emailsender, MAX(t2.emails_sent)
FROM (
    SELECT email_senders.sender AS emailsender, COUNT(*) AS emails_sent
    FROM email_senders, (
        SELECT s.sender, r.email_fk, COUNT(r.num_recipients) 
        FROM email_senders s, email_recipients r, emails 
        WHERE s.email_fk = emails.email_id AND r.email_fk = emails.email_ID
        GROUP BY s.sender, r.email_fk HAVING COUNT(r.num_recipients) > 1) AS t1
    WHERE email_senders.email_fk = t1.email_fk
    GROUP BY email_senders.sender
) AS t2;


-- Solution 2 without using num_recipients column

SELECT sender, MAX(emails_sent)
FROM(
    SELECT sender, COUNT(*) AS emails_sent
    FROM email_senders, (
        SELECT email_fk, COUNT(*) AS num_b_emails
        FROM email_recipients
        GROUP BY email_fk ) AS t1
    WHERE email_senders.email_fk = t1.email_fk AND t1.num_b_emails > 1
    GROUP BY sender
);

/*
Question 3: Find the five emails with the fastest response times. (A response is defined as a message from one of the recipients to the original sender whose subject line contains all of the words from the subject of the original email; the response time should be measured as the difference between when the original email was sent and when the response was sent)
Comments: Used a common table expression to make it more organized & easier to read & understand
Assumptions: 
    1.Each recipient/sender has 1 unique email when in real life, there could be multiple variations/forms of the 'same' email 
    2.Emails with blank and "re:" subject lines are considered for this query even though it is hard to track responses since large number emails can contain "" or "re:" and be responses to each other and other emails with longer subject lines.
        I have added conditionals to account for these edge cases below. Since the dataset is relatively small, it was manageable to spot check the results.
*/

WITH email AS (
SELECT e.subject_line, e.date, es.sender, er.recipient, e.email_id
FROM emails AS e
    INNER JOIN email_senders AS es on e.email_id = es.email_fk
    INNER JOIN email_recipients AS er on e.email_id = er.email_fk
)
SELECT o.email_id, r.email_id, o.date AS date_received, r.date AS date_response,(strftime('%s', r.date) - strftime('%s',o.date))/60 AS response_time, o.sender, o.recipient, r.subject_line
FROM email AS o
    INNER JOIN email AS r ON ((o.subject_line != "" AND r.subject_line LIKE '%'||o.subject_line||'%') OR (o.subject_line = "" AND r.subject_LINE = "re:"))
    AND o.recipient = r.sender  -- original recipient now becomes the new sender on the response email
    AND o.sender = r.recipient  -- original sender now becomes the new recipient of the response email
    AND o.date < r.date
ORDER BY (strftime('%s',r.date) - strftime('%s', o.date))/60 ASC
LIMIT 5;
