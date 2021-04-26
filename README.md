# Conjur Examples
This repository contains examples for using Conjur

## Run a Conjur CLI pod in Kubernetes

- Optional: Create a namespace for Conjur CLI:

  ```shell-script
  $ kubectl create ns conjur-cli
  ```

- Deploy the Conjur CLI pod:

  ```shell-script
  $ kubectl apply -f https://raw.githubusercontent.com/rafis3/conjur-examples/master/kubernetes/conjur-cli.yaml -n conjur-cli
  ```

- Log into the Conjur CLI:

  ```shell-script
  $ kubectl exec -it conjur-cli -n conjur-cli -- bash
  ```

- Initialize the CLI:

  ```shell-script
  $ conjur init
  ```

- Fill the details such as the Conjur address. Assuming Conjur runs in the same Kubernetes cluster:
  
  ```text
  https://<conjur-service-name>.<conjur-namespace>.svc.cluster.local
  ```

- Login with your user:

  ```shell-script
  $ conjur authn login -u <username>
  ```

- Now you can start working with the Conjur CLI.

## Run a test application pod in Kubernetes

This test application assumes that it's using a Conjur host with the following details:

- The Conjur host is called `kubernetes/apps/my-app`
- The Conjur authenticator name is `demo`
- The Conjur account name is `default`
- The Conjur address is `conjur-conjur-oss.conjur.svc.cluster.local`

### Conjur Policies

Load these policies to root

```yaml
- !variable my-secret

- !permit
  role: !host kubernetes/apps/my-app
  privileges: [ read, execute ]
  resource: !variable my-secret
```

```yaml
- !policy
  id: conjur/authn-k8s/demo
  annotations:
    description: Namespace defs for the Conjur cluster in dev
  body:
  - !webservice
    annotations:
      description: authn service for cluster

  # CA cert and key for creating client certificates
  - !policy
    id: ca
    body:
    - !variable
      id: cert
      annotations:
        description: CA cert for Kubernetes Pods.
    - !variable
      id: key
      annotations:
        description: CA key for Kubernetes Pods.

  # permit a layer of allowlisted authn ids to call authn service
  - !permit
    resource: !webservice
    privilege: [ read, authenticate ]
    role: !layer /kubernetes/apps
```

```yaml
- !policy
  id: kubernetes/apps
  body:
  - !group
    
  - !host
    id: test-app
    annotations:
      authn-k8s/namespace: test-app
      authn-k8s/authentication-container-name: authenticator
  
  - !grant
    role: !group
    member: !host test-app
```

### Steps to run the application

- Go to the test application folder:

  ```shell-script
  $ cd kubernetes/test-app
  ```

- If you are using Minikube, connect your local Docker registry to the Minikube registry:

  ```shell-script
  $ eval $(minikube docker-env)
  ```

- Build the test application image:

  ```shell-script
  $ docker build -t test-app .
  ```

- If you are not using Minikube, ensure that you copy the image to your Kubernetes registry and that the test application will have access to it. If you are using Minikube, the built image is now available in your Kubernetes environment.

- Create a namespace for the application:

  ```shell-script
  $ kubectl create ns test-app
  ```

- Copy the Conjur public certificate from the conjur-cli pod and create a ConfigMap that will contain it:

  ```shell-script
  $ kubectl cp -n conjur-cli conjur-cli:/root/conjur-default.pem /tmp/ssl-certificate.pem
  $ kubectl create -n test-app configmap conjur-certificate --from-file /tmp/ssl-certificate.pem
  ```

- Create the Deployment of the application:

  ```shell-script
  $ kubectl -n test-app create -f test-app.yaml
  ```

- Check that the application is successfully fetching its secret:

  ```shell-script
  $ kubectl -n test-app logs <pod-name> -c test-app
  ```