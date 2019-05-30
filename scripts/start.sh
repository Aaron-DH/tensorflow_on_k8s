#!/bin/bash

function run_tensorflow_cluster() {
    TASK_INDEX=$(hostname | awk -F'-' '{print $NF}')
    SCRIPT_DIR=$( cd ${0%/*} && pwd -P )
    exec python ${SCRIPT_DIR}/grpc_tf_server.py --cluster_spec=$CLUSTER_SPEC --job_name=$RESOURCE_NAME --task_id=$TASK_INDEX
}

function run_tensorflow_tfboard() {
    exec tensorboard --logdir=$TRAIN_LOG_DIR
}

function run_ssh_server() {
    mkdir -p /root/.ssh
    echo "$SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
    /sbin/sshd -e
}

function run_jupyter_notebook() {
    exec jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root
}

function run_tensorflow_session() {
    run_ssh_server

    run_jupyter_notebook
}

case $RESOURCE_TYPE in
    "client"      ) run_tensorflow_client ;;
    "compute"     ) run_tensorflow_cluster ;;
    "tensorboard" ) run_tensorflow_tfboard ;;
esac
