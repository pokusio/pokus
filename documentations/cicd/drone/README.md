# Drone CI gitlab configuration

## Initialization

* I add a `.drone.yml` in the source code.
* then i follow https://docs.drone.io/server/provider/gitlab/ :
  * I create a gitlab Oauth Application with my Gitlab.com user :
    * problem here is that I need to set the "redirect URI", which should be https://drone.pegasusio.io/login
    * but https://drone.pegasusio.io/login is a private server of mine, and that's why I need to have either :
      * drone in a public cloud, so that It gets an IP address
      * and I use a Kubernetes `External DNS` in the single VM `k3d`, to setup the domain name, in my godaddy account for DNS pegasusio
  * then I start my private drone CI, feeding it the client sectet and client id



## Drone CI set up

#### HashiCorp Packer

With HAshiCorp Packer, create an ISO image for your VM, whith the following packages and configuration :

* Create one VM, with hostname `pegasusio.io` on the network you work in. It has to have ssh inside, base image is a debian.

* install `docker` :

```bash
# TODO
```

* install `k3d` :

```bash
# TODO
```


* install `kubectl` :

```bash
# TODO
```

* install `helm v3` :

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
```

* and then run :

```bash

# create the cluster
k3d create cluster jblCluster --api-port 6550  -p 8989:80@loadbalancer --masters 1 --workers 9
export KUBECONFIG=$(k3d get kubeconfig jblCluster)
kubectl get all,nodes

# deploy drone to the cluster
# https://github.com/drone/charts
helm repo add drone https://charts.drone.io
helm repo update

# Then drone is not just one chart, it is a collection of charts
# https://github.com/drone/charts

git clone https://github.com/drone/charts
# there are no releases in this repo, just the last commit on master.

# 1. If you have not yet installed Drone server, start with the drone chart.
export HELM_RELEASE_NAME=pegasus-drone
helm delete ${HELM_RELEASE_NAME}

export HELM_LOCAL_PKG=$(helm package charts/charts/drone | awk '{print $NF}')

export MY_DRONE_SERVER_HOST=pegassusio.io
export MY_DRONE_SERVER_PROTO=https
export MY_DRONE_GITLAB_CLIENT_ID=672a675bbc75dd307b9b130341dac22b0337ac729b5bc16222f60952ae6b9e2f
export MY_DRONE_GITLAB_CLIENT_SECRET=b47116e3b75818b03f88d06dd1bf9e86ad9513afb8597716b5f0a5b1c9286fc2
export MY_DRONE_RPC_SECRET=anythingcomplicatedtoguessandrandomlygenerated

helm install pegasus-drone ${HELM_LOCAL_PKG} --set env.DRONE_SERVER_HOST=pegassusio.io,env.DRONE_SERVER_PROTO=https,env.DRONE_RPC_SECRET=${MY_DRONE_RPC_SECRET},env.DRONE_GITLAB_CLIENT_ID=${MY_DRONE_GITLAB_CLIENT_ID},env.DRONE_GITLAB_CLIENT_SECRET=${MY_DRONE_GITLAB_CLIENT_SECRET}


```

* Alright, now that the drone server is up n running, it is available through https://pegasusio.io:8989/
* And here is what I get :

![gitlab OAuth application redirect URI failing](documentations/images/impr.ecran/drone/gitlab/GITLAB_APPLICATION_DRONE_CI_CONFIG_PRIVATE_INFRA_2020-07-25T01-47-57.246Z.png)

* knowing that I created the gitlab OAuth application like this :

![gitlab OAuth application](documentations/images/impr.ecran/drone/gitlab/GITLAB_APPLICATION_DRONE_CI_CONFIG_2020-07-25T01-40-15.895Z.png)

* To configure dorne server, we need (according to https://docs.drone.io/server/provider/gitlab/ ) :
  * `DRONE_GITLAB_CLIENT_ID` : Required string value provides your GitLab oauth Client ID.
  * `DRONE_GITLAB_CLIENT_SECRET` : Required string value provides your GitLab oauth Client Secret.
  * `DRONE_GITLAB_SERVER` : Option string value provides your GitLab server url. The default value is the gitlab.com server address at https://gitlab.com.
  * `DRONE_GIT_ALWAYS_AUTH` : Optional boolean value configures Drone to authenticate when cloning public repositories. This should only be enabled when using self-hosted GitLab with private mode enable.
  * `DRONE_RPC_SECRET` : Required string value provides the shared secret generated in the previous step. This is used to authenticate the rpc connection between the server and runners. The server and runner must be provided the same secret value.
  * `DRONE_SERVER_HOST` : Required string value provides your external hostname or IP address. If using an IP address you may include the port. For example, drone.domain.com
  * `DRONE_SERVER_PROTO` : Required string value provides your external protocol scheme. This value should be set to http or https. This field defaults to https if you configure ssl or acme.

# Going Inlets

* https://blog.alexellis.io/ingress-for-your-local-kubernetes-cluster/
* see also to customize fro AWS : https://github.com/inlets/inlets-operator#using-a-provider-which-requires-an-access-key-and-secret-key-aws-ec2-scaleway

I'll do that using AWS (I do not trust enough digital Ocean yet to give them my credit card, and I already gave it to `AWS`)

```bash
# install arkade cli
curl -sSL https://dl.get-arkade.dev | sudo sh

arkade install inlets-operator --help

# inlets operator provisioning on AWS
arkade install inlets-operator \
 --provider ec2 \
 --region eu-west-1 \
 --token-file $HOME/Downloads/access-key \
 --secret-key-file $HOME/Downloads/secret-access-key \
 --license $(cat $HOME/inlets-pro-license.txt)
```

# Drone Gitea

I want to try and switch to gitea, which is mush lighter than `gitlab ce`.

Plus, there exists integration between gitea and drone https://docs.drone.io/server/provider/gitea/
