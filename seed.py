# from sqlalchemy.engine import Engine
# from sqlalchemy import event
from model import emails, email_recipients, email_senders, engine

engine.execute('pragma foreign_keys=on')
conn = engine.connect()

# @event.listens_for(engine, "connect")
# def set_sqlite_pragma(dbapi_connection, connection_record):
#     cursor = dbapi_connection.cursor()
#     cursor.execute("PRAGMA foreign_keys=ON")
#     cursor.close()

def load_database(msg_id, datetime, recipient_set, sender_set, subject_line):

    email_ins = conn.execute(emails.insert(), msg_id=msg_id, date=datetime, subject_line=subject_line)

    last_inserted_id = email_ins.inserted_primary_key  # returns a list containing 1 integer

    for recipient in recipient_set:
        num_recipients = len(recipient_set)
        conn.execute(email_recipients.insert(), email_fk=last_inserted_id[0], recipient=recipient, num_recipients=num_recipients)

    for sender in sender_set:
        conn.execute(email_senders.insert(), email_fk=last_inserted_id[0], sender=sender)
