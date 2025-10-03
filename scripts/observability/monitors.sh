#!/bin/bash

observability_disable_monitor() {
    local monitor_identifier=$1
    local url=$2
    local service_token=$3
    /usr/local/bin/sts monitor disable --identifier $monitor_identifier --service-token $service_token --url $url
}

observability_deploy_monitor() {
    local file $1
    local url=$2
    local service_token=$3
    /usr/local/bin/sts monitor apply -f $file --service-token $service_token --url $url
}

observability_enable_monitor() {
    local monitor_identifier=$1
    local url=$2
    local service_token=$3
    /usr/local/bin/sts monitor enable --identifier $monitor_identifier --service-token $service_token --url $url
}

