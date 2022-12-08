#!/bin/bash

helm upgrade --install  logstash --version 7.17.3 -n logstash --create-namespace elastic/logstash -f values.yaml -f configs/logstash.conf -f configs/logstash.yml
