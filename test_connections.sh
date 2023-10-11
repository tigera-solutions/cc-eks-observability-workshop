#!/usr/bin/env bash

# output colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0)

echo Testing some connections between namespaces and pods
echo
echo Testing connectivity from $RED"centos"$NORMAL pod in $YELLOW"dev"$NORMAL namespace to $GREEN"nginx-svc" svc in $YELLOW"dev"$NORMAL namespace
echo Expected result should be $GREEN"HTTP/1.1 200 OK"$NORMAL if the traffic is accepted
RESULT1=$(kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://nginx-svc 2>/dev/null | grep -i http')
echo Actual result is $GREEN"$RESULT1"$NORMAL
echo
echo Testing connectivity from $RED"frontend"$NORMAL pod in $YELLOW"hipstershop"$NORMAL namespace to $RED"recommendationservice"$NORMAL pod in $YELLOW"hipstershop"$NORMAL namespace
echo Expected result should say $GREEN"recommendationservice open"$NORMAL
RESULT2=$(kubectl exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') -c server -- sh -c 'nc -zv -w 3 recommendationservice 8080')
echo Actual result is $GREEN"$RESULT2"$NORMAL
echo
echo Testing connectivity across namespaces
echo Testing connectivity from $RED"centos"$NORMAL pod in $YELLOW"dev"$NORMAL namespace to $RED"frontend"$NORMAL pod in $YELLOW"hipstershop"$NORMAL namespace
echo Expected result should be $GREEN"HTTP/1.1 200 OK"$NORMAL if the traffic is accepted
RESULT3=$(kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http')
echo Actual result is $GREEN"$RESULT3"$NORMAL
echo
echo Testing outbound internet access from $RED"centos"$NORMAL pod in $YELLOW"dev"$NORMAL namespace to $GREEN"www.google.com"$NORMAL
echo Expected result should be $GREEN"HTTP/1.1 200 OK"$NORMAL if the traffic is accepted
RESULT4=$(kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http')
echo Actual result is $GREEN"$RESULT4"$NORMAL
echo
echo Testing outbound internet access from $RED"frontend"$NORMAL pod in $YELLOW"hipstershop"$NORMAL namespace to $GREEN"www.google.com"$NORMAL
echo Expected result should be $GREEN"HTTP/1.1 200 OK"$NORMAL if the traffic is accepted
RESULT5=$(kubectl exec -it $(kubectl get po -l app=loadgenerator -ojsonpath='{.items[0].metadata.name}') -c main -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http')
echo Actual result is $GREEN"$RESULT5"$NORMAL