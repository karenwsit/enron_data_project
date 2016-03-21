import email
from email.parser import HeaderParser
import os
from dateutil.parser import parse
import seed

def create_list_of_filepaths():
    """Returns a list of filepaths for files ending with .txt"""
    
    filepath_list = []

    for root, dirs, files in os.walk("./enron_with_categories"):
        for f in files:
            if f.endswith('.txt'):
                filepath_list.append(os.path.join(root, f))
    return filepath_list

#This function is doing too much. Parsing through files, getting email headers, seeding. How do I best separate it out the seeding into the seed file?
def get_email_headers(filepath_list):
    """Decode header_text for each file"""

    for filepath in filepath_list:
        with open(filepath, 'r') as f:
            msg = email.message_from_file(f)  # Returns a message object structure tree from an open file object

        parser = HeaderParser()
        headers = parser.parsestr(msg.as_string())  # msg.as_string returns the entire message flattened as a string & parses the headers; returns an instance object

        msg_id = headers['Message-ID']
        date_str = headers['Date']
        from_str = headers['From']
        to_str = headers['To']
        cc_str = headers['Cc']
        bcc_str = headers['Bcc']
        subject_line = headers['Subject']

        #normalize data
        msg_id = msg_id.strip()
        datetime_obj = get_datetime(date_str)
        recipient_set = get_recipient_set(to_str, cc_str, bcc_str)
        sender_set = get_sender_set(from_str)
        subject_clean = clean_subject_line(subject_line)

        seed.load_database(msg_id, datetime_obj, recipient_set, sender_set, subject_clean)

def get_sender_set(from_str):
    if from_str:
        try:
            from_list = from_str.split(',')
        except AttributeError:
            raise
    sender_set = set(from_list)

    # remove leading & trailing space
    sender_set = [sender.strip() for sender in sender_set]
    return sender_set

def get_recipient_set(to_str, cc_str, bcc_str):
    recipient_list = []
    if to_str:
        try:
            to_list = to_str.split(',')
            recipient_list.extend(to_list)
        except:
            pass
    if cc_str:
        try:
            cc_list = cc_str.split(',')
            recipient_list.extend(cc_list)
        except:
            pass
    if bcc_str:
        try:
            bcc_list = bcc_str.split(',')
            recipient_list.extend(bcc_list)
        except:
            pass

    # remove duplicates
    recipient_set = set(recipient_list)

    # remove leading & trailing space
    recipient_set = [recipient.strip() for recipient in recipient_set]

    return recipient_set

def get_datetime(date_str):
    time_obj = parse(date_str)
    naive_time_obj = time_obj.replace(tzinfo=None)
    return naive_time_obj

def clean_subject_line(subject_line):
    return subject_line.lower().strip()

def main():
    filepath_list = create_list_of_filepaths()
    get_email_headers(filepath_list)

if __name__ == "__main__":
    main()