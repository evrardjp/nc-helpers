#!/bin/bash

function get_kubectl {
  CONTAINER=$(docker create $(awk '/hyperkube-amd64/ { print $1 ; exit }' /usr/local/bin/kubectl))
  docker cp $CONTAINER:/hyperkube $HOME/kubectl
  docker rm $CONTAINER
}

function kubectl {
  export KUBECONFIG=/etc/kubernetes/admin/kubeconfig.yaml
  $HOME/kubectl $@
}

function host_jump {
  HOST=$1
  kubectl -n ucp exec -it $(kubectl get -n ucp pods -l application=divingbell,component=exec -o wide --no-headers | awk "/${HOST}/ { print \$1; exit }") -- nsenter -t 1 -m -u -n -i bash
}

function get_openrc {
  SERVICE=$1
  USER=$2
  kubectl get -n openstack secrets ${SERVICE}-keystone-${USER} -o go-template='{{ range $k, $v := .data }}export {{$k}}={{ $v | base64decode}}{{"\n"}}{{end}}'
  echo "export OS_IDENTITY_API_VERSION=3"
}

function get_config {
  NS=$1
  SECRET=$2
  kubectl get -n $NS secrets ${SECRET} -o go-template='{{ range $k, $v := .data }}--- {{$k}} ---{{"\n"}}{{ $v | base64decode }}{{"\n"}}{{end}}'
}
