# v3
# Install K8 single node on iocifree3-oel7.8-1c1g ==> 1g de memoria não rolou....
# RODAR COM "sudo -s"  antes ==> para funcionar os redirects
# !!!!!! Rodar em oel7.8 !!!!!!!!
# https://enabling-cloud.github.io/oci-learning/manual/KubernetesClusterOnOCI.html
# tem que desabilitar SELINUX e SWAP
# https://www.x-cellent.com/blog/selecting-the-best-linux-distribution-for-kubernetes-clusters/
# com OKE
#  Rodar com parametros
#  1 11 2 22 222 3 33 4 5
# Não funcionou direito, acho que eh devido ao limite de memoroia de 1G da maquina utilizada
# Teste com SWAPON:  Kubeadm nao inicializa... com flags ignore preflich: da erro no kubelet
# TODO: desabilitar o swap apenas na instalação.....

# 1 install docker---------------------------------
if [[ $1 == '1' ]]; then
echo "11111111111111111111111111111111111111111111111111111111111111111111111111111111111"
sudo yum -y update
sudo yum -y install docker-engine
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
sudo docker version
fi

# 1.1 SETUP ------------------------------------
echo "111.11.111.1111.1111.111111.1111111111.111111111.1111111111111111111111111111111111"
# Set SELinux in permissive mode (effectively disabling it)
if [[ $1 == '11' ]]; then
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo sed -i 's/^SELINUXTYPE=mls$/SELINUXTYPE=targeted/' /etc/selinux/config
sudo systemctl disable firewalld && sudo systemctl stop firewalld
fi

# 2 install k8 ---------------------------------
# @@@@@@@@@@@@ FAZER MANUAL @@@@@@@@@@@@@@2  ==>rodar em modo iterativo: entrar em  "sudo -i" 
if [[ $1 == '2' ]]; then
echo "122222222222222222222222222222222222222222222222222222222222222222221"
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
#baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-aarch64
#baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
fi
#######################################################################
# ATENCAO:
# para rodar em maquinas com 1GB
if [[ $1 == '22' ]]; then
echo "12.222.22.22.22.222.2222.22.2222.222.222.222222222222222222222222222222222222221"
sudo sysctl --system
sudo yum install -y  kubelet.aarch64 kubeadm.aarch64 kubectl.aarch64 kubernetes-cni.aarch64
sudo systemctl enable kubelet && sudo systemctl start kubelet
fi
#disable swap
if [[ $1 == '222' ]]; then
echo "12-22-22--22--22---2222---222---222---2222222222222221"
sudo swapoff -a &&  sudo sed -i '/ swap / s/^/#/' /etc/fstab
fi
# 3 init cluster--------------------------------
if [[ $1 == '3' ]]; then
echo "3333333333333333333333333333333333333333333333333333333333333333333"
sudo kubeadm reset -f && sudo rm -rf /etc/kubernetes/
sudo kubeadm config images pull
fi
if [[ $1 == '33' ]]; then
echo "333-3333-3--33--3-3-3-3-333-33-3-3-3-3-3-3-333333-3--3-3-33333333333333PARTE INIT3333333333333333333"
sudo kubeadm init --ignore-preflight-errors=NumCPU
export KUBECONFIG=/etc/kubernetes/admin.conf
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
fi
# 4 setup pod net--------------------------------
if [[ $1 == '4' ]]; then
echo "444444444444444444444444444444444444444444444443"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl  version | base64 | tr -d '\n')"
kubectl get pods --all-namespaces
fi
#5 allow pods on master--------------------------
if [[ $1 == '5' ]]; then
echo "5555555555555555555555555555555555555555555555555555553"
kubectl taint nodes --all node-role.kubernetes.io/master-
fi
