import boto3
import os
import yaml
import secrets
import logging
from botocore.exceptions import ClientError

# Logging
# local debug file
logger = logging.getLogger()
logger.setLevel(logging.INFO)
s = secrets

with open('config.yaml') as f:
    config = yaml.safe_load(f.read())

client = boto3.client('ds')


def main():
    env = config[os.environ['PIPELINE_ENVIRONMENT']]
    subnets = env['SubnetIds']
    vpcId = env['VpcId']
    secretName = env['SecretName']
    directoryName = env['DirectoryName']
    NETBIOS = env['ShortDirectoryName']
    if s.checkSecret('{}-{}-{}-{}'.format(config['Pipeline']['Portfolio'],
                                          config['Pipeline']['App'],
                                          os.environ['PIPELINE_ENVIRONMENT'], secretName)) is False:
        s.put(secretName)
    try:
        response = client.create_microsoft_ad(
            Name=directoryName,
            ShortName=NETBIOS,  # NetBios
            Password=s.get('{}-{}-{}-{}'.format(config['Pipeline']['Portfolio'],
                                                config['Pipeline']['App'],
                                                os.environ['PIPELINE_ENVIRONMENT'],
                                                secretName)),
            Description='Managed Directory Service for {}'.format(os.environ['PIPELINE_ENVIRONMENT']),
            Edition='Enterprise',
            VpcSettings={
                'VpcId': vpcId,
                'SubnetIds': [
                    subnets[0],
                    subnets[1]
                ]
            },
            Tags=[
                {
                    'Key': 'Portfolio',
                    'Value': '{}'.format(config['Pipeline']['Portfolio'])
                },
                {
                    'Key': 'App',
                    'Value': '{}'.format(config['Pipeline']['App'])
                },
                {
                    'Key': 'Branch',
                    'Value': '{}'.format(config['Pipeline']['Branch'])
                },
            ]
        )
    except ClientError as e:
            logger.error("Error {}".format(e))
            raise e
    else:
        print(response)
        return response['DirectoryId']
