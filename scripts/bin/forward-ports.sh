#!/bin/sh


#port status
netstat -tnlp

echo "forward kubernetes dashboard port"
nohup kubectl port-forward -n kube-system --address 0.0.0.0 svc/kubernetes-dashboard 5080:80 &
echo "kubernetes dashboard url: http://localhost:5080"

echo "forward openfaas gateway port"
nohup kubectl port-forward -n openfaas --address 0.0.0.0 svc/gateway 8080:8080 &
echo "openfaas gateway url: http://localhost:5180"

#port status
netstat -tnlps