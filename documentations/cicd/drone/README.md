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
kubectl delete -f charts/charts/drone/drone-ingress.yaml
helm delete ${HELM_RELEASE_NAME}

# wait a couple of seconds so that helm delete has completed in peace
sleep 3s

export HELM_LOCAL_PKG=$(helm package charts/charts/drone | awk '{print $NF}')

export MY_DRONE_SERVER_HOST=pegassusio.io
export MY_DRONE_SERVER_PROTO=https
export MY_DRONE_GITLAB_CLIENT_ID=668bc88517e21ccabc10499f248466fec02e7781e17b62b63e25e1fafcbf0982
export MY_DRONE_GITLAB_CLIENT_SECRET=d910bb1968b3de37c0c9c9d6d80c08da776cfa7c18b1b5607e7224f8127b7b49

export MY_DRONE_GITEA_CLIENT_ID=f325c78c-82dc-4cb1-9c96-90bc151bdf49
export MY_DRONE_GITEA_CLIENT_SECRET=Yk3IE9u0IByHLbF3wXUvKQqXqiHgCcQuTyJ3YCMpVcc=
export MY_DRONE_GITEA_SERVER=https://try.gitea.io

export MY_DRONE_RPC_SECRET=anythingcomplicatedtoguessandrandomlygenerated

# helm install pegasus-drone ${HELM_LOCAL_PKG} --set env.DRONE_SERVER_HOST=drone.pegassusio.io,env.DRONE_SERVER_PROTO=http,env.DRONE_RPC_SECRET=${MY_DRONE_RPC_SECRET},env.DRONE_GITLAB_CLIENT_ID=${MY_DRONE_GITLAB_CLIENT_ID},env.DRONE_GITLAB_CLIENT_SECRET=${MY_DRONE_GITLAB_CLIENT_SECRET}
helm install pegasus-drone ${HELM_LOCAL_PKG} --set env.DRONE_SERVER_HOST=drone.pegassusio.io,env.DRONE_SERVER_PROTO=http,env.DRONE_RPC_SECRET=${MY_DRONE_RPC_SECRET},env.DRONE_GITEA_CLIENT_ID=${MY_DRONE_GITEA_CLIENT_ID},env.DRONE_GITEA_CLIENT_SECRET=${MY_DRONE_GITEA_CLIENT_SECRET},env.DRONE_GITEA_SERVER=${MY_DRONE_GITEA_SERVER}

# Now also adding Ingress for drone, so that Traefik picks it up, to expose it through our Inlets Load Balancer

rm charts/charts/drone/drone-ingress.yaml
touch charts/charts/drone/drone-ingress.yaml

cat <<EOF >>charts/charts/drone/drone-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pegasus-drone
spec:
  rules:
  - host: drone.pegasusio.io
    http:
      paths:
      - path: /
        backend:
          serviceName: pegasus-drone
          servicePort: http
EOF

kubectl apply -f charts/charts/drone/drone-ingress.yaml

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
* Ok, so now I need to create a traefik ingress route, or a simple ingress (like the cheese apps, for `traefik v1.7`) for the drone service (it is not exposed by default) :

```bash
jbl@pegasusio:~$ kubectl get all |grep drone
pod/pegasus-drone-79b74b977b-96cbh    1/1     Running   0          105m
service/pegasus-drone   ClusterIP   10.43.84.203    <none>        80/TCP    105m
deployment.apps/pegasus-drone     1/1     1            1           105m
replicaset.apps/pegasus-drone-79b74b977b    1         1         1       105m
```

* `Ingress` like the traefik's cheese applications :

```Yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pegasus-drone
spec:
  rules:
  - host: drone.pegasusio.io
    http:
      paths:
      - path: /
        backend:
          serviceName: pegasus-drone
          servicePort: http
```
* holy sh**t it f**g worked ! Now I do have access to the drone using http://drone.pegasusio.io/ , as long as I have in my `/etc/hosts` :

```bash
# Cheesies
# 192.168.1.34  wensleydale.minikube stilton.minikube  cheddar.minikube
18.203.92.141 wensleydale.minikube stilton.minikube  cheddar.minikube
18.203.92.141 drone.pegasusio.io

```
* Indeed, to test that, I tried accessing http://drone.pegasusio.io/logout because it does not redirect anywhere), and look, it worked !! (so drone actually now exposed through inlets ^^ ) :

![http://drone.pegasusio.io/logout](./documentations/images/impr.ecran/inlets/DRONE_IS_ACTUALLY_RUNNING_AND_EXPOSED_2020-07-25 05-55-43.png)

* If I try now to access http://drone.pegasusio.io/ , I will stil get an error from gitlab, because the domain name pegasusio.io is not yet configured in my godaddy account for the domain name `pegasusio.io` to match `18.203.92.141` IP.

* Note that in my cluster, consequently to previous operations, I have this :

```bash
jbl@pegasusio:~$ kubectl get all,nodes --all-namespaces|grep drone
default       pod/pegasus-drone-79b74b977b-96cbh                1/1     Running     0          125m
default       service/pegasus-drone             ClusterIP      10.43.84.203    <none>                     80/TCP                        125m
default       deployment.apps/pegasus-drone                1/1     1            1           125m
default       replicaset.apps/pegasus-drone-79b74b977b                1         1         1       125m
jbl@pegasusio:~$ kubectl describe service/pegasus-drone
Name:              pegasus-drone
Namespace:         default
Labels:            app.kubernetes.io/component=server
                   app.kubernetes.io/instance=pegasus-drone
                   app.kubernetes.io/managed-by=Helm
                   app.kubernetes.io/name=drone
                   app.kubernetes.io/version=1.8.1
                   helm.sh/chart=drone-0.1.6
Annotations:       meta.helm.sh/release-name: pegasus-drone
                   meta.helm.sh/release-namespace: default
Selector:          app.kubernetes.io/component=server,app.kubernetes.io/instance=pegasus-drone,app.kubernetes.io/name=drone
Type:              ClusterIP
IP:                10.43.84.203
Port:              http  80/TCP
TargetPort:        http/TCP
Endpoints:         10.42.9.8:80
Session Affinity:  None
Events:            <none>
```

* And then I can hit drone with a public IP Address.
* without domain name worries, I can test drone integration to gitlab.com that way
* And All I will have left to do, after that, is to configure the godaddy with an A record manually (and later do that with AWS Route 53 and `Kubernetes External DNS`),n and also a CNAME record to add `drone.pegasusio.io` so that http://drone.pegasusio.io hits the same IP  Address :

![Do Daddy configuration A record and CNAME record](documentations/images/impr.ecran/inlets/GODADDY_DNS_CONFIGURATION_DORONE_PEGASUSIO_IO__2020-07-25T04-43-52.246Z.png)

* ok, so now that DNS is setup, I re-created the Gilab OAuth application, like below (and redeployed drone with new Client ID / Client Secret) :

![Re-created Gitlab Application](documentations/images/impr.ecran/inlets/RECREATED_GITLAB_OAUTH_APPLICATION_FOR_DRONE_WITH_DNS_CNAME_RECORD_2020-07-25T04-42-32.141Z.png)

* Even though all configuration seems ok, I still have a final error with the gitlab application :

![final Gitlab Application error redirect uri not valid](documentations/images/impr.ecran/inlets/FINAL_GITLAB_APPLICATION_ERROR_2020-07-25T05-01-11.215Z.png)

I opened an issue on the subject : https://gitlab.com/gitlab-org/gitlab/-/issues/231603

* Finally, I also tried the `gitea` integration, and I get the same error obviously (so is there anything wrong with my redirect uri ? what?)

![same error on gitea](documentations/images/impr.ecran/inlets/SAME_ERROR_WITH_GITEA_THAN_WITH_GITLAB_ON_REDIRECT_URI_2020-07-25T06-27-05.026Z.png)

* TODO : Try Drone / Github integration and see if I get the same error
* I think I have an explanation see [ANNEX. A `OAuth2` and `TLS`](cccc) : https is required for OAuth2, some part at least, so i'll just go `https` everywhere, especially the drone server here.
_And the IAM users_

* I also finally note about my operations to provision inlets, that I used direct AWS security credentials, aand that is bad, instead I shoould : create an AWS IAM Role, which has enough permissiosn to create EC2 instances and do the `Kubernetes External DNS` thing (the `inlets` `AWS IAM Role`?), and after that, create a `pegasusio` IAM user which will be alowed to assume `inlets` role
* All in all I still have one problem with inlets : it is a tunnel, and the free part does not support all TLS options (so no way can it be secured). In paticular, Oauth2 has to finally use an un protected `http://` `redirect_uri`, instead of an `https://`.



# Drone Gitea

I want to try and switch to gitea, which is mush lighter than `gitlab ce`.

Plus, there exists integration between gitea and drone https://docs.drone.io/server/provider/gitea/

# ANNEX. A `OAuth2` and `TLS`

<div class="post-text" itemprop="text">
<p>The Authorization server is required to use SSL/TLS as per the <a href="http://tools.ietf.org/html/rfc6749">specification</a>, for example:</p>

<blockquote>
  <p>Since requests to the authorization endpoint result in user
     authentication and the transmission of clear-text credentials (in the
     HTTP response), the authorization server MUST require the use of TLS
     as described in Section 1.6 when sending requests to the
     authorization endpoint.</p>

  <p>Since requests to the token endpoint result in the transmission of
     clear-text credentials (in the HTTP request and response), the
     authorization server MUST require the use of TLS as described in
     Section 1.6 when sending requests to the token endpoint.</p>
</blockquote>

<p>That same specification does not <em>require</em> it for the client application, but heavily recommends it:</p>

<blockquote>
  <p>The redirection endpoint SHOULD require the use of TLS as described
     in Section 1.6 when the requested response type is "code" or "token",
     or when the redirection request will result in the transmission of
     sensitive credentials over an open network.  This specification does
     not mandate the use of TLS because at the time of this writing,
     requiring clients to deploy TLS is a significant hurdle for many
     client developers.  If TLS is not available, the authorization server
     SHOULD warn the resource owner about the insecure endpoint prior to
     redirection (e.g., display a message during the authorization
     request).</p>

  <p>Lack of transport-layer security can have a severe impact on the
     security of the client and the protected resources it is authorized
     to access.  The use of transport-layer security is particularly
     critical when the authorization process is used as a form of
     delegated end-user authentication by the client (e.g., third-party
     sign-in service).</p>
</blockquote>

<p>Calls to the resource server contain the access token and require SSL/TLS:</p>

<blockquote>
  <p>Access token credentials (as well as any confidential access token
     attributes) MUST be kept confidential in transit and storage, and
     only shared among the authorization server, the resource servers the
     access token is valid for, and the client to whom the access token is
     issued.  Access token credentials MUST only be transmitted using TLS
     as described in Section 1.6 with server authentication as defined by
     [RFC2818].</p>
</blockquote>

<p>The reasons should be pretty obvious: In any of these does not use secure transport, the token can be intercepted and the solution is not secure.</p>

<p>You question specifically calls out the client application.</p>

<blockquote>
  <p>Client apps: Is it really necessary, as long as it uses SSL for the resource server communication?</p>
</blockquote>

<p>I am assuming that you client is a web application, and you are talking about the communication between the browser and the server after authentication has happened. I am furthermore assuming that you ask the question, because (in your implementation), this communication is not authenticated with access tokens, but through some other means.</p>

<p>And there you have your answer: that communication is authenticated in some way or another. How else would the server know who is making the call? Most web sites use a session cookie they set at the beginning of the session, and use that to identify the session and therefor the user. Anyone who can grab that session cookie can hijack the session and impersonate the user. If you don't want that (and you really should not want that), you must use SSL/TLS to secure the communication between the browser and the server.</p>

<p>In some cases, the browser part of the client talks to the resource server directly; and the server part only serves static content, such as HTML, CSS, images and last but not least, JavaScript. Maybe your client is built like this, and you are wondering whether the static content must be downloaded over SSL/TLS? Well, if it isn't, a man in the middle can insert their own evil JavaScript, that steals you user's access tokens. You do want to secure the download of static content.</p>

<p>Last but not least, your question is based on a hidden assumption, that there might be valid reasons not to use SSL/TLS. Often people claim the cost of the certificate is too high, or the encryption requires too much CPU power, hence requiring more hardware to run the application. I do not believe these costs to be significant in virtually all cases. They are very low, compared to the total cost of building and running the solution. They are also very low compared to the risks of not using encryption. Don't spend time (and money) debating this, just use SSL/TLS all the way through.</p>
    </div>
