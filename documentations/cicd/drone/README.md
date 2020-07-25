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
# create secret files
export YOUR_AWS_ACCESS_KEY=AKIAJJMKFWNIVPS2Q22Q
export YOUR_AWS_SECRET_ACCESS_KEY=HIQM11SqGDMZCzDXDejF2eYKwpIaMD9lYELAbK2i

mkdir -p $HOME/inlets-operator/secrets/aws
touch $HOME/inlets-operator/secrets/aws/access-key
touch $HOME/inlets-operator/secrets/aws/secret-access-key

echo "${YOUR_AWS_ACCESS_KEY}" > $HOME/inlets-operator/secrets/aws/access-key
echo "${YOUR_AWS_SECRET_ACCESS_KEY}" > $HOME/inlets-operator/secrets/aws/secret-access-key

# install arkade cli
curl -sSL https://dl.get-arkade.dev | sudo sh

arkade install inlets-operator --help

# inlets operator provisioning on AWS for the inlets free version
arkade install inlets-operator \
 --provider ec2 \
 --region eu-west-1 \
 --token-file $HOME/inlets-operator/secrets/aws/access-key \
 --secret-key-file $HOME/inlets-operator/secrets/aws/secret-access-key
```
* Well, holy s***t it works !
  * arkade deployment went just fine
  * after a while my traefik ingress controller gets an `External IP` Address
  * I do see the AWS instance VM that was created by inlets :

![Inlets operator created AWS EC2 instance](documentations/images/impr.ecran/inlets/INLETS_OPERATOR_AWS_CREATED_EC2_INSTANCE_VM_2020-07-25T03-13-03.079Z.png)

  * I do also see traefikl mentioned in my inlets-operator logs :

```bash
# --- #


```

  * But most importantly this is how I  tested it does work :) :

```bash
jbl@pegasusio:~$ kubectl get all,nodes --all-namespaces|grep traefik
kube-system   pod/helm-install-traefik-528vr                    0/1     Completed   0          10h
kube-system   pod/svclb-traefik-cdm97                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-shf4q                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-kvgbw                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-p785x                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-r7szm                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-pnhsj                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-94ll6                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-td5mv                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-kgd46                           2/2     Running     0          10h
kube-system   pod/svclb-traefik-2xwfm                           2/2     Running     0          10h
kube-system   pod/traefik-ingress-controller-78b4959fdf-tfz7k   1/1     Running     0          10h
kube-system   pod/traefik-758cd5fc85-jkhgg                      1/1     Running     0          10h
kube-system   pod/traefik-tunnel-client-68b7c5787b-jcqc9        1/1     Running     0          15m
kube-system   service/traefik-prometheus        ClusterIP      10.43.35.96     <none>                     9100/TCP                      10h
kube-system   service/traefik-ingress-service   NodePort       10.43.39.199    <none>                     80:31481/TCP,8080:30210/TCP   10h
kube-system   service/traefik-web-ui            ClusterIP      10.43.206.216   <none>                     80/TCP                        10h
kube-system   service/traefik                   LoadBalancer   10.43.235.70    172.18.0.7,18.203.92.141   80:31098/TCP,443:31896/TCP    10h
kube-system   daemonset.apps/svclb-traefik   10        10        10      10           10          <none>          10h
kube-system   deployment.apps/traefik-ingress-controller   1/1     1            1           10h
kube-system   deployment.apps/traefik                      1/1     1            1           10h
kube-system   deployment.apps/traefik-tunnel-client        1/1     1            1           15m
kube-system   replicaset.apps/traefik-ingress-controller-78b4959fdf   1         1         1       10h
kube-system   replicaset.apps/traefik-758cd5fc85                      1         1         1       10h
kube-system   replicaset.apps/traefik-tunnel-client-68b7c5787b        1         1         1       15m
kube-system   job.batch/helm-install-traefik   1/1           24s        10h
jbl@pegasusio:~$ curl http://18.203.92.141/
<html>
  <head>
    <style>
      html {
        background: url(./bg.png) no-repeat center center fixed;
        -webkit-background-size: cover;
        -moz-background-size: cover;
        -o-background-size: cover;
        background-size: cover;
      }

      h1 {
        font-family: Arial, Helvetica, sans-serif;
        background: rgba(187, 187, 187, 0.5);
        width: 3em;
        padding: 0.5em 1em;
        margin: 1em;
      }
    </style>
  </head>
  <body>
    <h1>Stilton</h1>
  </body>
</html>
jbl@pegasusio:~$ curl http://wensleydale.minikube/
<html>
  <head>
    <style>
      html {
        background: url(./bg.jpg) no-repeat center center fixed;
        -webkit-background-size: cover;
        -moz-background-size: cover;
        -o-background-size: cover;
        background-size: cover;
      }

      h1 {
        font-family: Arial, Helvetica, sans-serif;
        background: rgba(187, 187, 187, 0.5);
        width: 6em;
        padding: 0.5em 1em;
        margin: 1em;
      }
    </style>
  </head>
  <body>
    <h1>Wensleydale</h1>
  </body>
</html>
jbl@pegasusio:~$ curl http://cheddar.minikube/
<html>
  <head>
    <style>
      html {
        background: url(./bg.jpg) no-repeat center center fixed;
        -webkit-background-size: cover;
        -moz-background-size: cover;
        -o-background-size: cover;
        background-size: cover;
      }

      h1 {
        font-family: Arial, Helvetica, sans-serif;
        background: rgba(187, 187, 187, 0.5);
        width: 4em;
        padding: 0.5em 1em;
        margin: 1em;
      }
    </style>
  </head>
  <body>
    <h1>Cheddar</h1>
  </body>
</html>
jbl@pegasusio:~$ ping -c 4 cheddar.minikube/
ping: cheddar.minikube/: Nom ou service inconnu
jbl@pegasusio:~$ ping -c 4 cheddar.minikube
PING wensleydale.minikube (18.203.92.141) 56(84) bytes of data.
^C
--- wensleydale.minikube ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1014ms

jbl@pegasusio:~$ cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	pegasusio.io	pegasusio

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Cheesies
# 192.168.1.34  wensleydale.minikube stilton.minikube  cheddar.minikube
18.203.92.141 wensleydale.minikube stilton.minikube  cheddar.minikube

```
* Ok, so now I need to create a traefik ingress route for the drone service (it is not exposed by default) :

```bash
jbl@pegasusio:~$ kubectl get all |grep drone
pod/pegasus-drone-79b74b977b-96cbh    1/1     Running   0          105m
service/pegasus-drone   ClusterIP   10.43.84.203    <none>        80/TCP    105m
deployment.apps/pegasus-drone     1/1     1            1           105m
replicaset.apps/pegasus-drone-79b74b977b    1         1         1       105m
```

* And then I can hit drone with a public IP Address.
* without domain name worries, I can test drone integration to gitlab.com that way
* And All I will have left to do, aftet that, is to configure the godaddy with an A record manually (and later do that with AWS Route 53 and `Kubernetes External DNS`)
* I also finally nte about my operations to provision inlets, that I used direct AWS security credentials, aand that is bad, instead I shoould : create an AWS IAM Role, which has enough permissiosn to create EC2 instances and do the `Kubernetes External DNS` thing (the `inlets` `AWS IAM Role`?), and after that, create a `pegasusio` IAM user which will be alowed to assume `inlets` role
* All in all I still have one problem with inlets : it is a tunnel, and the free part does not support all TLS options (so no way can it be secured).


# Drone Gitea

I want to try and switch to gitea, which is mush lighter than `gitlab ce`.

Plus, there exists integration between gitea and drone https://docs.drone.io/server/provider/gitea/
