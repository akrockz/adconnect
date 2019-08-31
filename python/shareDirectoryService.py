#!/bin/python3
# Share the directory service after running the main function.
import boto3
import os
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
        accounts = config[os.environ['PIPELINE_ENVIRONMENT']]['SharedAccounts']
        for account in accounts:
            response = client.share_directory(
                DirectoryId=dsid,
                ShareNotes='Connectivity to Shared Services AD Connector',
                ShareTarget={
                    'Id': account,
                    'Type': 'ACCOUNT'
                },
                ShareMethod='HANDSHAKE'
            )
    except ClientError as e:
            logger.error("Error {}".format(e))
            raise e
    else:
        print('Successfully Shared {}'.format(response['SharedDirectoryId']))
        return response['SharedDirectoryId']
