# Example Go app with LetsEncrypt certificates

This is an example (Go app)[https://github.com/golang/example/tree/master/outyet] deployed with Helm chart and secured with LetsEncrypt certificates, deployed with the help of [cert-manager](https://github.com/jetstack/cert-manager/). 
Example Go app is a web server that answers the question: "Is Go 1.x out yet?"
Docker container is running under non-privileged user (`appuser`) and port `8080` in [Docker multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) to create the smallest possible container

## Prerequisites
If you plan to try out this project, you need the following:

1. Working Kubernetes cluster (managed on AWS, Azure, GCP, self-hosted or [minikube](https://kubernetes.io/docs/setup/minikube/)). Also, `kubectl` is locally installed on your workstation and configured to use with your K8s cluster
2. `Helm` is locally installed
3. Once you clone the repo, change the following:
- `email` in `cert-manager/letsencrypt-prod-yaml`, to match the e-mail address you used to register the domain
- `certSecret` and `domainName` in `example-go-k8s-certmanager/values.yaml` to match your own domain name, and certificate name you desire

## Setup

1. Install `Tiller` in your Kubernetes cluster
```
$ kubectl --namespace kube-system create sa tiller
$ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
$ helm init --service-account tiller
```
2. Install `nginx-ingress` in `kube-system` namespace
```
helm install stable/nginx-ingress --namespace kube-system --name nginx-ingress
```
3. Install `cert-manager` and create `ClusterIssuer` object. Be sure to change your e-mail address in `cert-manager/letsencrypt-prod.yaml`, it should match the e-mail address used to register the domain
```
$ helm install --name cert-manager --namespace kube-system \
--set ingressShim.defaultIssuerName=letsencrypt-prod \
--set ingressShim.defaultIssuerKind=ClusterIssuer stable/cert-manager
$ kubectl create -f cert-manager/letsencrypt-prod.yaml
```
If you want to test first, follow the instructions from [cert-manager docs](http://docs.cert-manager.io/en/latest/tutorials/acme/http-validation.html) in order to use `staging` LetsEncrypt endpoint
4. Install `example-go-k8s-certmanager` local Helm chart
```
helm install --name example-go-k8s-certmanager ./example-go-k8s-certmanager
```

In order to find the external IP address of `nginx-ingress-controller` LoadBalancer to hook up your domain name with, use
```
$ kubectl get svc nginx-ingress-controller -n kube-system
```