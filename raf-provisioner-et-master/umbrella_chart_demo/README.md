# Umbrella Chart Demo
:warning: This package is Strictly for DEMO purposes.

- raf-datasetmanagerui-0.1.0.tgz :- Helm chart implementation of Raf-Dataset manager UI Component.
- raf-metadatamanagement-service-0.1.0.tgz :- Helm Chart implementation of Raf-Metadata Management Service Component.
- superset.tgz :- Helm Chart implementation of Raf-Superset Component.

## umb_test-0.1.0.tgz : 

- Umbrella Chart implementation for Raf-Dataset manager UI & Raf-Metadata Management Service Component

## Pre-Reqs for Raf-Metadata Management Service Component : 
- Namespace to be created of name : guavus-raf by following command: 
```
Kubectl create namespace guavus-raf
```
- Token to be created for Raf-Meta data Management service by following commands:
```
kubectl -n guavus-raf create serviceaccount ingestion-admin-sa
kubectl create clusterrolebinding ingestion-admin-sa --clusterrole=cluster-admin --serviceaccount=guavusraf:ingestion-admin-sa
```
Be sure to update the new value for field "kubernetes_server_token_secret_name" in values.yml inside of raf-metadatamanagement-service-0.1.0.tgz package.

- Update the value of image to be pulled for raf Metadata or ManagerUI in values.yml as per requirement.

## Pre-Reqs for Superset Component : 
- Secrets to be created for Superset component by executing following commands: 
```
kubectl create secret generic psql-secret --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=postgres
kubectl create secret generic  ldap-secret --from-literal=username="cn=svc-ldap,ou=ApplicationObjects,ou=Custom,dc=guavus,dc=com" --from-literal=password="qKH^wSejvJDe"
kubectl create secret tls superset-tls --key "/tls/tls.key"  --cert "/tls/tls.crt"
```
