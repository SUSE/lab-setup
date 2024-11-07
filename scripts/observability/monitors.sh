#!/bin/bash

observability_disable_monitor() {
    local url=$1
    local service_token=$2
    local monitor_identifier=$3
    /usr/local/bin/sts monitor disable --identifier $monitor_identifier --service-token $service_token --url $url
}

observability_deploy_monitor() {
    local url=$1
    local service_token=$2
    local file $3
    /usr/local/bin/sts monitor apply -f $file --service-token $service_token --url $url
}

observability_enable_monitor() {
    local url=$1
    local service_token=$2
    local monitor_identifier=$3
    /usr/local/bin/sts monitor enable --identifier $monitor_identifier --service-token $service_token --url $url
}

