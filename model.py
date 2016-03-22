from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData, ForeignKey, DateTime
from sqlalchemy.interfaces import PoolListener

#Enforces foreign key constraints
class ForeignKeysListener(PoolListener):
    def connect(self, dbapi_con, con_record):
        db_cursor = dbapi_con.execute('pragma foreign_keys=ON')

DB_URI = "sqlite:///enron.db"
engine = create_engine(DB_URI, echo=True, listeners=[ForeignKeysListener()])
metadata = MetaData()  # container object to keep features of the database together

emails = Table('emails', metadata,
    Column('email_id', Integer, autoincrement=True, primary_key=True),  # synthetic pk
    Column('msg_id', String, nullable=False),
    Column('date', DateTime, nullable=False),
    Column('subject_line', String, nullable=False),
    )

email_recipients = Table('email_recipients', metadata,
    Column('er_id', Integer, autoincrement=True, primary_key=True),  # synthetic pk
    Column('email_fk', None, ForeignKey('emails.email_id'), nullable=False),
    Column('recipient', String, nullable=False),
    Column('num_recipients', Integer, nullable=False),
    )

email_senders = Table('email_senders', metadata,
    Column('es_id', Integer, autoincrement=True, primary_key=True),  # synthetic pk
    Column('email_fk', None, ForeignKey('emails.email_id'), nullable=False),
    Column('sender', String, nullable=False),
    )

metadata.create_all(engine)