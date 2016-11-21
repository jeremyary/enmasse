#!/bin/bash

# This script is for deploying EnMasse into OpenShift. The target of
# installation can be an existing OpenShift deployment or an all-in-one
# container can be started.
#
# In either case, access to the `oc` command is required.
#
# example usage:
#
#    $ enmasse-deploy.sh -c 10.0.1.100 -o enmasse.10.0.1.100.xip.io
#
# this will deploy EnMasse into the OpenShift cluster running at 10.0.1.100
# and set the EnMasse webui route url to enmasse.10.0.1.100.xip.io.
# further it will use the user `developer` and project `myproject`, asking
# for a login when appropriate.
# for further parameters please see the help text.

if which oc &> /dev/null
then :
else
    echo "Cannot find oc command, please check path to ensure it is installed"
    exit 1
fi

ENMASSE_TEMPLATE_MASTER_URL=https://github.com/EnMasseProject/openshift-configuration/blob/master/generated

ENMASSE_TEMPLATE=https://github.com/EnMasseProject/openshift-configuration/blob/master/generated/enmasse-base-template.yaml

DEFAULT_OPENSHIFT_USER=developer
DEFAULT_OPENSHIFT_PROJECT=myproject

while getopts c:dp:t:u:h opt; do
    case $opt in
        c)
            OS_CLUSTER=$OPTARG
            ;;
        d)
            OS_ALLINONE=true
            ;;
        p)
            PROJECT=$OPTARG
            ;;
        t)
            ENMASSE_TEMPLATE=$OPTARG
            ;;
        u)
            OS_USER=$OPTARG
            USER_REQUESTED=true
            ;;
        h)
            echo "usage: enmasse-deploy.sh [options]"
            echo
            echo "deploy the EnMasse suite into a running OpenShift cluster"
            echo
            echo "optional arguments:"
            echo "  -h             show this help message"
            echo "  -c CLUSTER     OpenShift cluster url to login against (default: https://localhost:8443)"
            echo "  -d             create an all-in-one docker OpenShift on localhost"
            echo "  -p PROJECT     OpenShift project name to install oshinko into (default: $DEFAULT_OPENSHIFT_USER)"
            echo "  -t TEMPLATE    An alternative opan OpenShift template file to deploy EnMasse (default: curl'd from upstream)"
            echo "  -u USER        OpenShift user to run commands as (default: $DEFAULT_OPENSHIFT_PROJECT)"
            echo
            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit
            ;;
    esac
done

if [ -z "$OS_USER" ]
then
    echo "user not set, using default value"
    OS_USER=$DEFAULT_OPENSHIFT_USER
fi

if [ -z "$PROJECT" ]
then
    echo "project name not set, using default value"
    PROJECT=$DEFAULT_OPENSHIFT_PROJECT
fi

if [ -n "$OS_ALLINONE" ]
then
    if [ -n "$OS_CLUSTER" ]
    then
        echo "Error: You have requested an all-in-one deployment AND specified a cluster address."
        echo "Please choose one of these options and restart."
        exit 1
    fi
    if [ -n "$USER_REQUESTED" ]
    then
        echo "Error: You have requested an all-in-one deployment AND specified an OpenShift user."
        echo "Please choose either all-in-one or a cluster deployment if you need to use a specific user."
        exit 1
    fi
    oc cluster up
fi

oc login $OS_CLUSTER -u $OS_USER

oc new-project $PROJECT

# oc create sa enmasse -n $PROJECT
oc policy add-role-to-user view system:serviceaccount:${PROJECT}:default
oc policy add-role-to-user edit system:serviceaccount:${PROJECT}:deployer


if [ -n "$ALT_TEMPLATE" ]
then
    oc create -n $PROJECT -f $ALT_TEMPLATE
else
    oc create -n $PROJECT -f https://raw.githubusercontent.com/EnMasseProject/openshift-configuration/master/generated/enmasse-base-template.yaml
fi


oc new-app --template enmasse-base -n $PROJECT
