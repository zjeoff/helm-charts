#!/bin/bash

date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p /tmp/${date}

mysqldump \
    --port="${PXC_NODE_PORT}" \
    --host="${PXC_NODE_NAME}" \
    --user="${PXC_USERNAME}" \
    --password="${PXC_PASS}" \
    --single-transaction \
    --quick \
    --all-databases \
    --source-data=1 > /tmp/${date}/dump.sql

xbstream -C /tmp -c ${date} $XBSTREAM_EXTRA_ARGS \
		| xbcloud put --parallel="$(grep -c processor /proc/cpuinfo)" --storage=s3 --md5 --s3-bucket="$S3_BUCKET" "$S3_BUCKET_PATH" 2>&1 \
		| (grep -v "error: http request failed: Couldn't resolve host name" || exit 1)

rm -fr /tmp/${date}

sleep 600
