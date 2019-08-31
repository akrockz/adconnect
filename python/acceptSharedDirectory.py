#!/bin/python3
# Share the directory service after running the main function.
import boto3
import yaml
import logging
from botocore.exceptions import ClientError

# Logging
# local debug file
logger = logging.getLogger()
logger.setLevel(logging.INFO)

with open('config.yaml') as f:
    config = yaml.safe_load(f.read())

client = boto3.client('ds')


def main(dsid):
    try:
        response = client.accept_shared_directory(
            SharedDirectoryId=dsid
        )
    except ClientError as e:
            logger.error("Error {}".format(e))
            raise e
    else:
        print('Successfully Shared {}'.format(response['SharedDirectoryId']))
        return response['SharedDirectoryId']
