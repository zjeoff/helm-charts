#!/bin/bash

mysqldump \
    --port="${PXC_NODE_PORT}" \
    --host="${PXC_NODE_NAME}" \
    --user="${PXC_USERNAME}" \
    --password="${PXC_PASS}" \
    --single-transaction \
    --quick \
    --all-databases \
    --source-data=1 > /tmp/dump.sql

sleep 3600
