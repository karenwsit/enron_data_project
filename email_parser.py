import email
import os
from dateutil.parser import parse
import seed

def create_list_of_filepaths(data_file_loc):
    """Returns a list of filepaths for files ending with .txt"""

    filepath_list = []

    for root, dirs, files in os.walk("./enron_with_categories"):
        for f in files:
            if f.endswith('.txt'):
                filepath_list.append(os.path.join(root, f))
    return filepath_list


    # for root, dirs, files in os.walk(data_file_loc):
    #     for f in files:
    #         if f.endswith('.txt'):
    #             yield (os.path.join(root, f))

def get_email_headers(filepath_list):
    """Decode header_text for each file"""

    for filepath in filepath_list:
        with open(filepath, 'r') as f:
            msg = email.message_from_file(f)  # Returns a message object structure tree from an open file object
            
        # parser = HeaderParser()
        # headers = parser.parsestr(msg.as_string())  # msg.as_string returns the entire message flattened as a string & parses the headers; returns an instance object

        # yield msg

# done
        msg_id = msg['Message-ID']
        date_str = msg['Date']
        from_str = msg['From']
        to_str = msg['To']
        cc_str = msg['Cc']
        bcc_str = msg['Bcc']
        subject_line = msg['Subject']

        #normalize data
        msg_id = msg_id.strip()
        datetime_obj = get_datetime(date_str)
        recipient_set = get_recipient_set(to_str, cc_str, bcc_str)
        sender_set = get_sender_set(from_str)
        subject_clean = clean_subject_line(subject_line)

        seed.load_database(msg_id, datetime_obj, recipient_set, sender_set, subject_clean)

def get_sender_set(from_str):
    if from_str:
        from_list = from_str.split(',')

    # Assumption: even if sender appears multiple times in the 'from' field, recipient will only receive 1 email
    # remove duplicates
    sender_set = set(from_list)

    # remove leading & trailing space on email
    sender_set = [sender.strip() for sender in sender_set]
    return sender_set

def get_recipient_set(to_str, cc_str, bcc_str):
    recipient_list = []
    if to_str:
        to_list = to_str.split(',')
        recipient_list.extend(to_list)
    if cc_str:
        cc_list = cc_str.split(',')
        recipient_list.extend(cc_list)
    if bcc_str:
        bcc_list = bcc_str.split(',')
        recipient_list.extend(bcc_list)

    # Assumption: Even if recipient appears in more than 1 field (to/cc/bcc) or multiple times in the same field, recipient will only receive 1 email
    # remove duplicates
    recipient_set = set(recipient_list)

    # remove leading & trailing space on email
    recipient_set = [recipient.strip() for recipient in recipient_set]

    return recipient_set

def get_datetime(date_str):
    time_obj = parse(date_str)

    #return naive time object instead of aware time object because many libs & database adapters have no idea about timezones
    naive_time_obj = time_obj.replace(tzinfo=None)
    return naive_time_obj

def clean_subject_line(subject_line):
    #Assumption: Emails with blank subject lines be kept as blank instead of being marked NULL since they still have valid information and/or content and this happens frequently (66 blank subject line emails in the dataset)
    return subject_line.lower().strip()

def main():
    filepath_list = create_list_of_filepaths("./enron_with_categories")
    get_email_headers(filepath_list)

if __name__ == "__main__":
    main()
