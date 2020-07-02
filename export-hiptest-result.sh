#! /bin/sh

hiptest-publisher \
  --token=181005036618164955036858448907656792073644625028690844341 \
  --language=cucumber \
  --framework=java \
  --test_run_id=430611 \
  --push "build/reports/cucumber-junit/*.xml" \
  --push-format junit