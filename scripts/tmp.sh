sudo microk8s.enable dns
sudo microk8s.enable storage
sudo microk8s.enable ingress
sudo snap install postman

snap alias microk8s.kubectl kubectl
snap alias microk8s.helm3 helm

echo "Mojaloop: add vagrant user to microk8s group"
usermod -a -G microk8s vagrant


MOJALOOP_WORKING_DIR=/vagrant
MOJALOOP_TMP_WORKING_DIR=/home/vagrant/tmp/helm
MOJALOOP_CHARTS_DIR=${MOJALOOP_WORKING_DIR}/helm
MOJALOOP_REPO_DIR=${MOJALOOP_CHARTS_DIR}/repo
MOJALOOP_CHARTS_BRANCH='fix/219-kubernetes-17-helm2-2'
RELEASE_NAME="miniloop"
TIMEOUT_SECS="1200s"

rm -rf ${MOJALOOP_TMP_WORKING_DIR}
rm -rf ${MOJALOOP_CHARTS_DIR}
mkdir -p ${MOJALOOP_TMP_WORKING_DIR}
mkdir -p ${MOJALOOP_CHARTS_DIR}

# Clone into tmp dir to get around virtualbox issue
sudo git clone https://github.com/vessels-tech/helm.git ${MOJALOOP_WORKING_DIR}/helm-vt
cd ${MOJALOOP_WORKING_DIR}/helm-vt 
git checkout -b fix/219-kubernetes-17-helm2-2 origin/fix/219-kubernetes-17-helm2-2
./package.sh
python3 -m http.server & 


helm install miniloop http://localhost:8000/mojaloop-9.3.0.tgz 
