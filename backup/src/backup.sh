#!/bin/sh

DB_DUMP=/data/db/dump/$(date '+%Y-%m-%dT%H_%M')

mongodump \
--host mongo-service \
--out $DB_DUMP

# set up AWS role and credentials
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set profile.backup.role_arn $AWS_ROLE_ARN
aws configure set profile.backup.source_profile default

alias s3backup='aws cli s3 --profile=backup'

BACKUP_FILE=$DB_DUMP.tar.gz
tar -zcvf $BACKUP_FILE $DB_DUMP

if [ -z "$S3_BUCKET" ]; then
    echo "S3 Bucket not specified!"
    rm $BACKUP_FILE
    exit 1
else
    if [ -z "$BACKUP_DIR"  ]; then
	s3backup cp $BACKUP_FILE s3://$S3_BUCKET
    else
	s3backup cp $BACKUP_FILE s3://$S3_BUCKET/$BACKUP_DIR/
    fi
fi

rm $BACKUP_FILE
