import boto3
import botocore
import sys
import os


def main():

    # Replace following parameters with your IP and credentials
    CLUSTER_IP = '<API endpoint IP>'
    AWS_ACCESS = '<AWS Access Key ID>'
    AWS_SECRET = '<AWS Secret Access Key>'

    BUCKET_NAME = 'test-bucket'
    TEST_FILE = '/tmp/test-my-bucket.txt'
    TEST_FILE_KEY = 'test-my-bucket.txt'
    TEST_FILE_TARGET = '/tmp/test-my-bucket-target.txt'

    """
    This script shows and example of Boto3 S3 integration with Stratoscale Symphony.

    The scenario is as such:
         1. List buckets
         2. Create bucket
         3. Upload file
         4. Download file
         5. Remove file
         6. Remove bucket
    
    This example was tested on versions:
    - botocore 1.7.35
    - boto3 1.4.7
    """

    print ("Disabling warning for Insecure connection")
    botocore.vendored.requests.packages.urllib3.disable_warnings(
        botocore.vendored.requests.packages.urllib3.exceptions.InsecureRequestWarning)

    # creating a connection to Symphony AWS Compatible region
    client = boto3.client(service_name="s3", region_name="symphony",
                          endpoint_url="https://%s:1060" % CLUSTER_IP,
                          verify=False,
                          aws_access_key_id = AWS_ACCESS,
                          aws_secret_access_key=AWS_SECRET)

    def my_list_buckets():
        # list buckets
        buckets_list_response = client.list_buckets()

        # check buckets list returned successfully
        if buckets_list_response['ResponseMetadata']['HTTPStatusCode'] == 200:
            print ("Buckets list: " + ' '.join(p for p in [bucket['Name']
                                               for bucket in buckets_list_response['Buckets']]))
        else:
            print ("List buckets failed")

    my_list_buckets()

    # create bucket
    create_bucket_response = client.create_bucket(Bucket=BUCKET_NAME)

    # check create bucket returned successfully
    if create_bucket_response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print "Successfully created bucket %s" % BUCKET_NAME
    else:
        print ("Create bucket failed")

    my_list_buckets()

    for file_to_delete in [TEST_FILE, TEST_FILE_TARGET]:
        try:
            os.remove(file_to_delete)
        except OSError:
            pass

    # Upload file
    with open(TEST_FILE, 'w') as f:
        f.write('Hello world, symphony bucket')

    client.upload_file(TEST_FILE, BUCKET_NAME, TEST_FILE_KEY)
    print "Uploading file %s to bucket %s" % (TEST_FILE, BUCKET_NAME)

    # download file
    client.download_file(BUCKET_NAME, TEST_FILE_KEY, '/tmp/file-from-bucket.txt')
    print "Downloading object %s from bucket %s" % (TEST_FILE_KEY, BUCKET_NAME)

    #delete object in bucket
    delete_object_response = client.delete_object(Bucket=BUCKET_NAME, Key=TEST_FILE_KEY)

    if delete_object_response['ResponseMetadata']['HTTPStatusCode'] == 204:
        print "Successfully deleted object %s from bucket %s" % (TEST_FILE_KEY, BUCKET_NAME)
    else:
        print ("Download file failed")

    # delete bucket
    delete_bucket_response = client.delete_bucket(Bucket=BUCKET_NAME)

    # check delete bucket returned successfully
    if delete_bucket_response['ResponseMetadata']['HTTPStatusCode'] == 204:
        print "Successfully delete bucket %s" % BUCKET_NAME
    else:
        print ("Delete bucket failed")

if __name__ == '__main__':
    sys.exit(main())
