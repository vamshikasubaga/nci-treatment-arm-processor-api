#!/bin/sh

aws dynamodb delete-table --table-name treatment_arm --endpoint-url http://localhost:8000
sleep 1
aws dynamodb delete-table --table-name treatment_arm_assignment_event --endpoint-url http://localhost:8000

sleep 2
set -x
aws dynamodb list-tables --endpoint-url http://localhost:8000