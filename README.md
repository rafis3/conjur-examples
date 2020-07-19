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