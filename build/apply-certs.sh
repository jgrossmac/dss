#!/bin/bash

if [ "$1" == "" ]; then
  echo "usage: ./apply-certs.sh <cluster_context>"
  exit 1
fi


set -e
set -x

# Paths to directories in which to store certificates and generated YAML files.
CONTEXT="$1"
DIR="$(pwd)"
NAMESPACE="dss-main"
CLIENTS_CERTS_DIR="$DIR/workspace/$CONTEXT/client_certs_dir"
NODE_CERTS_DIR="$DIR/workspace/$CONTEXT/node_certs_dir"
CA_KEY_DIR="$DIR/workspace/$CONTEXT/ca_key_dir"
CA_CRT_DIR="$DIR/workspace/$CONTEXT/ca_certs_dir"
JWT_PUBLIC_CERTS_DIR="$DIR/jwt-public-certs"
UPLOAD_CA_KEY=true

# Delete previous secrets in case they have changed.
kubectl create namespace "$NAMESPACE"  --context "$CONTEXT" || true

kubectl delete secret cockroachdb.client.root --context "$CONTEXT" || true
kubectl delete secret cockroachdb.client.root --namespace "$NAMESPACE"  --context "$CONTEXT" || true
kubectl delete secret cockroachdb.node --namespace "$NAMESPACE"  --context "$CONTEXT" || true
kubectl delete secret cockroachdb.ca.crt --namespace "$NAMESPACE"  --context "$CONTEXT" || true
kubectl delete secret cockroachdb.ca.key --namespace "$NAMESPACE"  --context "$CONTEXT" || true
kubectl delete secret dss.public.certs --namespace "$NAMESPACE"  --context "$CONTEXT" || true

kubectl create secret generic cockroachdb.client.root --from-file "$CLIENTS_CERTS_DIR"  --context "$CONTEXT"
kubectl create secret generic cockroachdb.client.root --namespace "$NAMESPACE" --from-file "$CLIENTS_CERTS_DIR"  --context "$CONTEXT"
kubectl create secret generic cockroachdb.node --namespace "$NAMESPACE" --from-file "$NODE_CERTS_DIR"  --context "$CONTEXT"
# The ca key is not needed for any typical operations, but might be required to sign new certificates.
$UPLOAD_CA_KEY && kubectl create secret generic cockroachdb.ca.key --namespace "$NAMESPACE" --from-file "$CA_KEY_DIR"  --context "$CONTEXT"
# The ca.crt is kept in it's own secret to more easily manage cert rotation and 
# adding other operators' certificates.
kubectl create secret generic cockroachdb.ca.crt --namespace "$NAMESPACE" --from-file "$CA_CRT_DIR"  --context "$CONTEXT"
kubectl create secret generic dss.public.certs --namespace "$NAMESPACE" --from-file "$JWT_PUBLIC_CERTS_DIR"  --context "$CONTEXT"
  