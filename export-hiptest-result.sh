#! /bin/sh

hiptest-publisher \
  --token=32566011687122469819438825419833000201479941620470807818 \
  --language=cucumber \
  --framework=java \
  --test-run-id=433046 \
  --execution-environment=release \
  --push "build/reports/cucumber-junit/*.xml" \
  --push-format junit
