from flask import Flask, request
import json
from waitress import serve
import yaml 
import boto3
import os
from botocore.config import Config

'''
Script heavily inspired from https://github.com/MeteoSwiss/euliaa_proc/blob/main/tests_bucket_notifications/02_http_listener.py

Originally written by Anne-Claire.

'''

with open('/home/eric/credential_s3_notification.yaml', 'r') as file:
    config = yaml.safe_load(file)
    
# Extract the necessary values from the configuration
access_key_id = config['access_key_id']
secret_access_key = config['secret_access_key']
topic_name = config['topic_name']
ceph_endpoint = config['ceph_endpoint']  # The Ceph endpoint
region_name = config['region_name']  # The region name for the SNS client
bucket_name = config['bucket_name']  # The bucket name for S3 notifications

app = Flask(__name__)

@app.route('/', methods=['POST'])
def catch_root_post():
    try:
        raw_data = request.data.decode()
        #print("RAW POST RECEIVED:")
        #print(raw_data)

        # Try parsing JSON
        notification = json.loads(raw_data)
        #print("Parsed notification:", notification)
        
        if (notification['Records'][0]['eventName'] == 'ObjectCreated:Put'):
            # Extract the file name if the structure matches
            key = notification['Records'][0]['s3']['object']['key']
            
            process_uploaded_file(key)
        else: 
            print('This is not a new object, ignoring !')

    except Exception as e:
        print("Error processing notification:", e)

    return 'OK', 200

def process_uploaded_file(filename):
    s3 = boto3.client('s3',
        endpoint_url=ceph_endpoint ,
        aws_access_key_id=access_key_id,
        aws_secret_access_key=secret_access_key,
    )
    localfolder = '/data/eprofile-mwr-l1/'
    local_filename = os.path.join(localfolder, filename)
    print(f"Downloading file: {filename} to {local_filename}")
    s3.download_file(bucket_name, filename, local_filename)
    

if __name__ == '__main__':
    #app.run(debug=True, host='0.0.0.0', port=8080) # this line runs the Flask app directly, for testing
    serve(app, host='0.0.0.0', port=8080) # this line runs the Flask app using Waitress, for production (waitress is a WSGI server)

