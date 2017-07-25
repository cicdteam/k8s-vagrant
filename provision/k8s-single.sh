#!/bin/bash

# install docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu

# set k8s version
K8S_VERSION='1.7.1'

# add k8s repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get -yq update

# install k8s main components
sudo apt-get -yq install -y kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00 kubernetes-cni

# init k8s cluster
sudo kubeadm init --kubernetes-version=stable --pod-network-cidr=10.244.0.0/16

# put k8s config to home dir
mkdir -p ~/.kube
sudo cat /etc/kubernetes/admin.conf | tee ~/.kube/config >/dev/null
echo 'source <(kubectl completion bash)' | tee -a ~/.bashrc

# wait while node apper
while ! kubectl get nodes k8s-single --no-headers; do sleep 5; done

# install flannel pod networking
kubectl apply -f https://rawgit.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
kubectl apply -f https://rawgit.com/coreos/flannel/master/Documentation/kube-flannel.yml

# remove master taint
kubectl taint nodes --all node-role.kubernetes.io/master-

# launch k8s apps
[ -d /tmp/k8s ] && kubectl apply -f /tmp/k8s

# wait while echoserver come (that mean whole k8s stack up)
while [ $(curl -s -w %{http_code} -o /dev/null localhost) -ne 200 ]; do
    echo 'waiting for k8s become online'; sleep 5
done

echo 'add logrotation for docker containers'
cat <<'EOF' | sudo tee /etc/logrotate.d/containers
/var/lib/docker/containers/*/*-json.log {
  rotate 5
  copytruncate
  missingok
  notifempty
  compress
  maxsize 10M
  daily
  create 0644 root root
}
EOF

echo 'add cleanup for docker containers with status exited'
cat <<'EOF' | sudo tee /etc/cron.daily/clean-docker
#!/bin/sh

set -e

docker ps -a -f status=exited -q | xargs --no-run-if-empty docker rm
EOF
sudo chmod 0755 /etc/cron.daily/clean-docker

echo
echo 'DONE!'
