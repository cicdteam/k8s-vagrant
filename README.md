# Single-node Kubernetes cluster in Vagrant/VirtualBox environment

### Kubernetes version

Provision script installs Kubernetes 1.7 by `kubeadm` tool.

### TL;DR

- clone/pull repo
- run `vagrant up`
- wait while cluster bootsraps
- go inside by `vagrant ssh`
- run `kubectl get no` and any other `kubectl...` commands


### What installed

Everything from folder [k8s](k8s) installed over cluster when VM created. Also you can manage these
yaml's from inside VM (it accessible by `/vagrant/k8s` path)

- nginx ingress controller (it used `spec.hostNetwork: true` allowing access to ports 80 and 443)
- simple echo server

### Check's

try `curl localhost` from inside VM and you will see answer from echoserver running in Kubernetes
