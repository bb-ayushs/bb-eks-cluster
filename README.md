# README.md

### Hygiene.

* If you are making changes to this REPO NEVER commit directly to the main branch,
* Create a feature branch (e.g. feature/yourfeaturename)
* When ready raise a pull request

### Provision an EKS Cluster using Terraform modules 


---

#### **Please Note**This is a  (in progress) self-serve article aka  method of procedure to provision a AWS EKS cluster on demand. Upon completion this you will have a working ####

* EKS Cluster with worker nodes
* security groups
* Service accounts
* VPC
* public and private subnets 
* Internet gateway
* security gateway 
* nat gateway
* route tables
* IAM Role, Policy
* a kubernetes dashboard on your local 
*  RDS MySQL database
* ingress (in progress)
* s3 bucket for BB application Static files contents
* Actve MQ

---


## Instructions ##

First and foremost, please ensure you have the following pre-requisites met: Pre-requisites

#### Get access to AWS account ####

Once you have received credentials and logged into AWS console, please select “My Security Credentials” from top right where your name and account displays. Once inside that page, you will see option to “Create Access keys” create them and take a note of those two information ( access key ,secret) 

#### AWS CLI  - Download, install and verify information: ####

https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html - Configure CLI after install: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config

#### IAM Authenticator:  ####

please open terminal and run  brew install aws-iam-authenticatorif you have performed these two steps correctly then verify by running in Mac Terminal : aws sts get-caller-identity 

#### EKS CLI  - Download , install and verify information:  ####

https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html 

#### KUBECTL  - Download, install and verify information: ####

https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html 

#### Helm (v3): -Download, install and verify information:   ####

https://docs.aws.amazon.com/eks/latest/userguide/helm.html  

#### Terraform:- Download, install and verify information: ####

https://learn.hashicorp.com/tutorials/terraform/install-cli

---
---

## DEPLOY TERRAFORM MODULE: ##

Please clone this repository 

Please edit variables.tf and change the following variables:
* region
* user_id
* project_name
* environment


* Please go inside the main folder & run command: 

```
terraform init
terraform plan -var 'user_id=yourusername' -out eks-state
terraform apply "eks-state"
```
* Please don't forget to clean-up your environment when you are finished:

```
terraform destroy
```
NOTE: Sometimes destroy fails as it cannot delete module.db.module.db_option_group.aws_db_option_group.this[0].
To fix go to https://ap-southeast-2.console.aws.amazon.com/rds/home?region=ap-southeast-2#snapshots-list: and delete the snapshot and rerun terrafrom destroy.

** if you come across version related errror in terraform init command, try running " terraform init -upgrade " to allow selection of new versions 

* terraform init , initializes terraform modules
* terraform plan shows you whats being applied (like a dry run ) 
* -out <name> creates a local state file which stores a snapshot or information of current infrastructure state. Next time when you apply terraform changes again, it till compare remote eks cluster state with this local copy and show you diff on the “terraform plan” command. 
* when first time running terraform apply and everytime you run terraform destroy , it will prompt you and ask you if you want to proceed . say “yes”. you can verify using:

```
bb-anz-eks stephen$ aws eks list-clusters --region ap-southeast-2
{
    "clusters": [
        "bbanz-eks-bFpkRbCr"
    ]
} 
```

* I’m When you are done with your work, please run below command, to delete EKS cluster and cleanup any associated resources which were created during cluster creation

```
terraform destroy
```

* you can verify deletion using:

```
bb-anz-eks stephen$ aws eks list-clusters --region ap-southeast-2
{
    "clusters": [
        " "
    ]
} 

```

---

---

## OPTIONAL - But useful ##

### Deploy Kubernetes Metrics Server ###

* The Kubernetes Metrics Server, used to gather metrics such as cluster CPU and memory usage over time, is not deployed by default in EKS clusters
* Download and unzip the metrics server by running the following command

``` 
wget -O v0.3.6.tar.gz https://codeload.github.com/kubernetes-sigs/metrics-server/tar.gz/v0.3.6 && tar -xzf v0.3.6.tar.gz 
```

### Deploy the metrics server to the cluster by running the following command 

```
kubectl apply -f metrics-server-0.3.6/deploy/1.8+/ 
```

* Verify that the metrics server has been deployed kubectl get deployment metrics-server -n kube-system 

* If successful, you should see something like this 

```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE metrics-server   
1/1     1            1           4s

```


#### Deploy Kubernetes Dashboard ####

The following command will schedule the resources necessary for the dashboard.

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml  
```

output should be:

```
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding..authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created 
```


* Now, create a proxy server that will allow you to navigate to the dashboard from the browser on your local machine. This will continue running until you stop the process by pressing CTRL + C

`kubectl proxy
Starting to serve on 127.0.0.1:8001 `


* You should be able to access the Kubernetes dashboard here (http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

#### Authenticate the dashboard ####

* To use the Kubernetes dashboard, you need to create a ClusterRoleBinding and provide an authorization token. This gives the cluster-admin permission to access the kubernetes-dashboard. Authenticating using kubeconfig is not an option. You can read more about it in the Kubernetes documentation

* In another MAC terminal tab (do not close the terminal with kubectl proxy process), create the ClusterRoleBinding resource

```
kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-eks-cluster/master/kubernetes-dashboard-admin.rbac.yaml 

```

* Then, generate the authorization token

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}') 
```

output should be:

```
Name:         service-controller-token-46qlm
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: service-controller
              kubernetes.io/service-account.uid: dd1948f3-6234-11ea-bb3f-0a063115cf22

Type:  kubernetes.io/service-account-token

Data
====
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6I..something
ca.crt:     1025 bytes 
```


* Select "Token" on the Dashboard UI then copy and paste the entire token you receive into the dashboard authentication screen to sign in. You are now signed in to the dashboard for your Kubernetes cluster

* Navigate to the "Cluster" page by clicking on "Cluster" in the left navigation bar. You should see a list of nodes in your cluster

-----

for any feedback or questions leave a comment in this repo 
([this repo url](https://stash.backbase.com/users/mahmudul/repos/bb-anz-eks/browse))


This was cofnigured using  ([this](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster )) official hashicorp ref doc  


------
### contacts: ###
####  Stephen Hopkins <stephenh@backbase.com> ####

