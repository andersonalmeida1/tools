# v1.5
# Install K8 single node on Ubuntu
# https://enabling-cloud.github.io/oci-learning/manual/KubernetesClusterOnOCI.html
# tem que desabilitar SELINUX e SWAP
# https://www.x-cellent.com/blog/selecting-the-best-linux-distribution-for-kubernetes-clusters/
# com OKE
#  
# 1 install docker---------------------------------
sudo yum -y update
sudo yum -y install docker
sudo systemctl daemon-reload
sudo systemctl enable docker && systemctl start docker
docker version

# 1.1 SETUP ------------------------------------
# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo sed -i 's/^SELINUXTYPE=mls$/SELINUXTYPE=targeted/' /etc/selinux/config
sudo systemctl disable firewalld && systemctl stop firewalld


# 2 install k8 ---------------------------------
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
yum install -y  kubelet kubeadm kubectl kubernetes-cni
systemctl enable kubelet && systemctl start kubelet
#disable swap
swapoff -a &&  sed -i '/ swap / s/^/#/' /etc/fstab
# 3 init cluster--------------------------------
kubeadm reset -f && rm -rf /etc/kubernetes/
kubeadm init
export KUBECONFIG=/etc/kubernetes/admin.conf
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 4 setup pod net--------------------------------
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl  version | base64 | tr -d '\n')"
kubectl get pods --all-namespaces
#5 allow pods on master--------------------------
kubectl taint nodes --all node-role.kubernetes.io/master-


