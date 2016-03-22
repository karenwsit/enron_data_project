#Question 1:How many emails did each person receive each day?

SELECT COUNT(*), recipient, strftime('%m-%d-%Y', date)
FROM email_recipients
JOIN emails ON email_fk = email_id
GROUP BY recipient, strftime('%m-%d-%Y', date)
ORDER BY date;

#Question 2a:Let's label an email as "direct" if there is exactly one recipient and "broadcast" if it has multiple recipients.Identify the person (or people) who received the largest number of direct emails

# SELECT MAX(num_direct_emails), recipient
# FROM (
# SELECT COUNT(num_recipients) as num_direct_emails , recipient
# FROM email_recipients
# WHERE num_recipients=1
# GROUP BY recipient
# )

#Inner Select: Give me a email id, # of distinct recipients  AS T1
#Outer Select: Go into recipient table & match email_id to email_id in Inner Query & give me recipient & num of dir_emails

# SELECT recipient, COUNT(*)
# FROM email_recipients, (
#     SELECT email_fk, COUNT(*) as num_dir_emails
#     FROM email_recipients
#     GROUP BY email_fk ) as t1
# WHERE email_recipients.email_fk = t1.email_fk AND t1.num_dir_emails = 1
# GROUP BY recipient
# ORDER BY COUNT(*) DESC;

#Question 2b: Identify the person (or people) who sent the largest number of broadcast emails.

SELECT s.sender, COUNT(r.num_recipients) FROM email_senders s, email_recipients r, emails  WHERE s.email_fk = emails.email_id and r.email_fk = emails.email_ID AND s.sender = "steven.kean@enron.com" AND r.num_recipients > 1 GROUP BY s.sender, r.email_fk;

SELECT s.sender, r.email_fk, COUNT(r.num_recipients) FROM email_senders s, email_recipients r, emails  WHERE s.email_fk = emails.email_id and r.email_fk = emails.email_ID GROUP BY r.email_fk, s.sender HAVING COUNT(r.num_recipients) > 1 ORDER BY r.email_fk DESC;

SELECT email_senders.sender, COUNT(email_senders.sender)
FROM email_senders
WHERE email_senders.sender IN (SELECT s.sender FROM email_senders s, email_recipients r, emails  WHERE s.email_fk = emails.email_id and r.email_fk = emails.email_ID GROUP BY r.email_fk HAVING COUNT(r.num_recipients) > 1)
GROUP BY email_senders.sender
ORDER BY COUNT(email_senders.sender) ASC;


#New Query:
SELECT t2.emailsender, MAX(t2.emailssentout)
FROM (SELECT email_senders.sender as emailsender, COUNT(*) as emailssentout 
FROM email_senders, (SELECT s.sender, r.email_fk, COUNT(r.num_recipients) FROM email_senders s, email_recipients r, emails  WHERE s.email_fk = emails.email_id and r.email_fk = emails.email_ID GROUP BY s.sender, r.email_fk HAVING COUNT(r.num_recipients) > 1) as t1
WHERE email_senders.email_fk = t1.email_fk 
GROUP BY email_senders.sender) as t2;

# showing us the sender, the email ID, and the number of recipients that email has filtered only to show unique email IDs
SELECT s.sender, r.email_fk, COUNT(r.num_recipients) FROM email_senders s, email_recipients r, emails  WHERE s.email_fk = emails.email_id and r.email_fk = emails.email_ID GROUP BY s.sender, r.email_fk HAVING COUNT(r.num_recipients) > 1 ORDER BY COUNT(r.num_recipients) ASC

# WRONG: Counting the # of recipients per email instead of the number of emails

# SELECT MAX(num_b_emails), sender
# FROM(
# SELECT COUNT(*) as num_b_emails , sender
# FROM email_senders as es
# JOIN email_recipients as er ON es.email_fk = er.email_fk
# WHERE num_recipients > 1
# GROUP BY sender
# );

SELECT email_senders.email_fk, email_recipients.email_fk, COUNT(*) as num_dir_emails, num_recipients 
    FROM email_recipients, email_senders
    WHERE email_senders.email_fk = email_recipients.email_fk
    GROUP BY email_senders.email_fk, email_recipients.email_fk

SELECT sender, COUNT(*)
FROM email_senders, (
    SELECT email_fk, COUNT(*) as num_b_emails
    FROM email_recipients
    GROUP BY email_fk ) as t1
WHERE email_senders.email_fk = t1.email_fk AND t1.num_b_emails > 1
GROUP BY sender
ORDER BY COUNT(*) ASC;

##################################################################################

#Question 3: Find the five emails with the fastest response times. (A response is defined as
# 1)a message from one of the recipients to the original sender
# 2)whose subject line contains all of the words from the subject of the original email
# 3)the response time should be measured as the difference between when the original email was sent and when the response was sent

WITH email as (
SELECT 
e.subject_line
,e.date
,es.sender
,er.recipient
,e.email_id
from emails e
inner join email_senders es on e.email_id = es.email_fk
inner join email_recipients er on e.email_id = er.email_fk
 )

Select o.subject_line
,o.date as date_receive
,r.date AS date_response
,(strftime('%s' ,r.date) - strftime('%s' ,o.date))/60 AS response_time
,o.sender
,o.recipient
,o.email_id
,r.email_id
FROM email o
INNER JOIN email r ON ((o.subject_line != "" AND r.subject_line LIKE '%'||o.subject_line||'%') OR (o.subject_line = "" AND r.subject_LINE = "re:"))
and o.recipient = r.sender # original recipient now becomes the new sender on the response email
and o.sender = r.recipient # original sender now becomes the new recipient of the response email
and o.date < r.date
ORDER BY (strftime('%s',r.date) - strftime('%s', o.date))/60 ASC
LIMIT 5;
