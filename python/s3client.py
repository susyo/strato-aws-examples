#!/usr/bin/python


import argparse
import traceback
import ConfigParser
import time
import logging
# import awscli.clidriver
import boto3
from botocore import UNSIGNED
from botocore.client import Config
from subprocess import Popen, PIPE, STDOUT
from botocore.handlers import disable_signing
from inspect import getmembers, ismethod

class S3API:
    def __init__(self, KeyID, secretKey, endpointURL):
        self.resources = boto3.resource('s3', aws_access_key_id=KeyID, aws_secret_access_key=secretKey, endpoint_url=endpointURL)
        self.client = boto3.client('s3', aws_access_key_id=KeyID, aws_secret_access_key=secretKey, endpoint_url=endpointURL)
        self.transfer = boto3.s3.transfer
#   May need the following for public bucket access:        self.resources.meta.client.meta.events.register('choose-signer.s3.*', disable_signing)

    def bucketCreate(self, args):
        self.client.create_bucket(Bucket=args.bucket)
        return self.bucketList(args)

    def bucketList(self, args):
        self.buckets = self.client.list_buckets()
        bucketList = list()
        for bucket in self.buckets["Buckets"]:
            bucketList.append(bucket["Name"])
        return bucketList

    def objectCount(self, args):
        return len(self.objectList(args))

    def objectList(self, args):
        allObjects = list()
        for page in self.resources.Bucket(args.bucket).objects.pages():
            for obj in page:
                allObjects.append(obj.key)
        return allObjects
    # may need this later to print size. key = Bucket.lookup('my_key_name') -> key.size

    def upload(self, args):
        data = open(args.file, 'rb')
        self.resources.Bucket(args.bucket).put_object(Key=args.key, Body=data)

    def uploadMultiPart(self, args):
        try:
            print "Uploading file:", args.file
            tc = self.transfer.TransferConfig()
            t = self.transfer.S3Transfer(client=self.client, config=tc)

            t.upload_file(args.file, args.bucket , args.key)

        except Exception as e:
            print "Error uploading: %s" % (e)

    def uploadTest(self, args):
        key = args.key
        localArgs = args
        for index in range(1 , int(args.copies) + 1):
            localArgs.key = str(index) + key
            s3api.upload(localArgs)



def _get_args(commands):
    from argparse import RawTextHelpFormatter
    parser = argparse.ArgumentParser(description='***Boto3 examples for using Symphony S3 server***', formatter_class=RawTextHelpFormatter)
    parser.add_argument('target', action='store', help='URL of the object store \n For Symphony use: http://<Symphony IP>:80/s3 \n For ASW S3 use: http://s3.amazonaws.com' )
    parser.add_argument('access_key', action='store', help='')
    parser.add_argument('secret_key', action='store', help='')
    parser.add_argument('command', action='store', help="One of: \n" + "\n".join(commands) )

    parser.add_argument('--bucket', action='store', help='bucket to use')
    parser.add_argument('--file', action='store', help='file to upload')
    parser.add_argument('--key', action='store', help='key on the object store')
    parser.add_argument('--copies', action='store', help='number of copies per uploaded file')


    return parser.parse_args()

def printList(aList):
    for item in aList:
        print item

if __name__ == "__main__":
    commands = dict()
    for item in getmembers(S3API):
        key, method = item
        if ismethod(method) & ("__" not in key):
            commands[key] = method

    my_args = _get_args(commands.keys())
    s3api = S3API(my_args.access_key, my_args.secret_key, my_args.target)


    if my_args.command in commands.keys():
        response = commands[my_args.command](s3api, my_args)
        if type(response) == type(list()):
            printList(response)
        else:
            print response
    else:
        print "Command must be one of:"
        printList(commands.keys())
        exit(1)

    exit(0)



