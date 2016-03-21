#Question 1:How many emails did each person receive each day?

# SELECT COUNT(*), recipient, strftime('%m-%d-%Y', date)
# FROM email_recipients
# JOIN emails ON email_fk = email_id
# GROUP BY recipient, strftime('%m-%d-%Y', date)
# ORDER BY date;

#How to make the people who received 0 show up?
# Answer: Make a Calendar table with the dates to compare against
# SELECT calendar.calendar_date, COUNT(email_recipients.er_id)
# LEFT JOIN emails_recipients
# ON calendar.calendar_date = emails.
# http://stackoverflow.com/questions/10586746/how-to-have-group-by-and-count-include-zero-sums

##################################################################################

#Question 2a:Let's label an email as "direct" if there is exactly one recipient and "broadcast" if it has multiple recipients.Identify the person (or people) who received the largest number of direct emails

# SubQuery:

# SELECT MAX(num_direct_emails), recipient
# FROM (
# SELECT COUNT(num_recipients) as num_direct_emails , recipient
# FROM email_recipients
# WHERE num_recipients=1
# GROUP BY recipient
# )

#Alternative Solution: Python code to show the top queries until the num changes.

#Question 2b: Identify the person (or people) who sent the largest number of broadcast emails.

# SELECT MAX(num_b_emails), sender
# FROM(
# SELECT COUNT(*) as num_b_emails , sender
# FROM email_senders as es
# JOIN email_recipients as er on es.email_fk = er.email_fk
# WHERE num_recipients > 1
# GROUP BY sender
# );


##################################################################################
#Question 3: Find the five emails with the fastest response times. (A response is defined as a message from one of the recipients to the original sender whose subject line contains all of the words from the subject of the original email, and the response time should be measured as the difference between when the original email was sent and when the response was sent.)
