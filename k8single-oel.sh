# v2.3
# Install K8 single node on Ubuntu
# !!!!!! Rodar em oel7.8 !!!!!!!!
# https://enabling-cloud.github.io/oci-learning/manual/KubernetesClusterOnOCI.html
# tem que desabilitar SELINUX e SWAP
# https://www.x-cellent.com/blog/selecting-the-best-linux-distribution-for-kubernetes-clusters/
# com OKE
#  
# 1 install docker---------------------------------
sudo yum -y update
sudo yum -y install docker-engine
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
sudo docker version

# 1.1 SETUP ------------------------------------
# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo sed -i 's/^SELINUXTYPE=mls$/SELINUXTYPE=targeted/' /etc/selinux/config
sudo systemctl disable firewalld && sudo systemctl stop firewalld


# 2 install k8 ---------------------------------
# @@@@@@@@@@@@ FAZER MANUAL @@@@@@@@@@@@@@2/
#sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
#[kubernetes]
#name=Kubernetes
#baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
#enabled=1
#gpgcheck=1
#repo_gpgcheck=1
#gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
#        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
#EOF
#sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#EOF
sudo sysctl --system
sudo yum install -y  kubelet kubeadm kubectl kubernetes-cni
sudo systemctl enable kubelet && sudo systemctl start kubelet
#disable swap
sudo swapoff -a &&  sed -i '/ swap / s/^/#/' /etc/fstab
# 3 init cluster--------------------------------
sudo kubeadm reset -f && sudo rm -rf /etc/kubernetes/
sudo kubeadm init
sudo export KUBECONFIG=/etc/kubernetes/admin.conf
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 4 setup pod net--------------------------------
sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl  version | base64 | tr -d '\n')"
sudo kubectl get pods --all-namespaces
#5 allow pods on master--------------------------
sudo kubectl taint nodes --all node-role.kubernetes.io/master-


