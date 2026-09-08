#!/bin/sh

set -e

# Removing all old crontabs
rm -rf /var/spool/cron/crontabs
mkdir /var/spool/cron/crontabs

echo "${CRON_SCHEDULE} /clean.sh" >> /var/spool/cron/crontabs/root

echo ------------------------------------------------------------------------------------------
echo \| "$(date)"
echo \| "cron expression: ${CRON_SCHEDULE}"
echo \| "Cron service scheduled job successfully."
echo ------------------------------------------------------------------------------------------
crond -l 2 -f
