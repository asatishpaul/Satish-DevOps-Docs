### Detailed Documentation for CI/CD Pipeline, AWS Secrets Management, and Deployment

This documentation covers a detailed explanation of the CI/CD pipeline setup, Kubernetes deployment, AWS Secrets Manager integration, CSI driver usage, and common issues/errors you may encounter while working with the setup. 

### 1. **CI/CD Pipeline Overview**
The provided **CI/CD pipeline** automates the process of building and deploying a Node.js application to Kubernetes using AWS EKS. The pipeline performs several tasks including:

- **Code Checkout** from GitHub
- **Dependency Installation** with Yarn
- **Linting and Testing** the codebase
- **Docker Build & Push** to JFrog Artifactory
- **AWS Configuration** for credentials
- **Kubernetes Deployment** using `kubectl`
- **Secrets Management** with AWS Secrets Manager

#### Pipeline Breakdown:

- **Checkout Code**: Retrieves the latest code changes from the GitHub repository.
  
- **Check for `[skip ci]`**: The pipeline checks the last commit message for `[skip ci]` or `[ci skip]` to conditionally skip the pipeline execution.

- **Install Dependencies**: Installs necessary dependencies using Yarn.

- **Lint and Test Code**: Runs linting and tests using Yarn.

- **Build Project**: Builds the application if there are no errors.

- **Docker Login to JFrog Artifactory**: Authenticates the CI pipeline with JFrog Artifactory using stored API keys and username.

- **Docker Image Build & Push**: Builds the Docker image for the Node.js app and pushes it to JFrog Artifactory.

- **AWS Configuration**: Configures AWS CLI with credentials stored in GitHub secrets to interact with AWS services.

- **Deploy SecretProviderClass**: Deploys the `SecretProviderClass` resource which connects the Kubernetes cluster to AWS Secrets Manager for pulling secrets.

- **Kubernetes Deployment**: Applies the Kubernetes deployment and service configuration for the app.

- **Verify Pod Status**: Verifies the pod's deployment status in Kubernetes.

### 2. **Kubernetes Deployment Configuration**
The Kubernetes deployment configuration defines the deployment, service, and secrets management to retrieve sensitive information (such as JFrog credentials) securely from AWS Secrets Manager using the **Secrets Store CSI Driver**.

#### **deployment.yaml** (Deployment Configuration)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: express-typescript-app
  labels:
    app: express-typescript
spec:
  replicas: 3
  selector:
    matchLabels:
      app: express-typescript
  template:
    metadata:
      labels:
        app: express-typescript
    spec:
      serviceAccountName: secrets-store-csi-driver  # Service Account for Secrets Store CSI Driver
      containers:
        - name: express-typescript
          image: trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: "production"
          volumeMounts:
            - name: secrets-store
              mountPath: "/mnt/secrets-store"
              readOnly: true
      imagePullSecrets:
        - name: jfrog-registry-secret  # The secret to authenticate with JFrog Artifactory
      volumes:
        - name: secrets-store
          csi:
            driver: secrets-store.csi.k8s.io  # Secrets Store CSI Driver for secret management
            readOnly: true
            volumeAttributes:
              secretProviderClass: "aws-secrets"  # Link to the SecretProviderClass
---
apiVersion: v1
kind: Service
metadata:
  name: express-typescript-service
spec:
  type: LoadBalancer
  selector:
    app: express-typescript
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```

#### Key Points:
- The **serviceAccountName** refers to the service account used to interact with AWS Secrets Manager through the **Secrets Store CSI Driver**.
- **imagePullSecrets** contains the credentials to pull the Docker image from JFrog Artifactory.
- The **Secrets Store CSI** driver is used to securely fetch secrets from AWS Secrets Manager and inject them into the container.

#### **secret-provider-class.yaml** (Secrets Store Configuration)

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: aws-secrets
spec:
  provider: aws  # Specify AWS as the provider
  parameters:
    objects: |
      - objectName: "my-docker-secret"  # The name of the secret stored in AWS Secrets Manager
        objectType: "secretsmanager"  # Type is secretsmanager
        objectKeys: ["JFROG_USERNAME", "JFROG_PASSWORD"]  # Keys to fetch from Secrets Manager
    secretsManagerSecretId: my-docker-secret  # ID of the secret in AWS
    region: ap-south-1  # AWS region
```

This configuration tells the Secrets Store CSI Driver where to fetch the secrets from AWS Secrets Manager. It specifies the secret name (`my-docker-secret`) and the keys (`JFROG_USERNAME` and `JFROG_PASSWORD`) to retrieve.

### 3. **Dockerfile Explanation**
The `Dockerfile` defines the steps to build the Docker image for the Express TypeScript application. It uses a Node.js Alpine image and installs the necessary dependencies, builds the app, and prepares the container to interact with AWS Secrets Manager.

```dockerfile
# Use the official Node.js Alpine base image
FROM node:lts-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application code to the container
COPY . .

# Expose the application port
EXPOSE 3000

# Install the AWS SDK to retrieve secrets from AWS Secrets Manager
RUN npm install aws-sdk

# Build the application (if applicable)
RUN npm run build

# Set environment variables to enable AWS SDK to access Secrets Manager
# The app will fetch the secrets dynamically at runtime
ENV AWS_REGION=ap-south-1
ENV SECRET_NAME=my-docker-secret

# The entry point for the application (it will retrieve secrets from AWS Secrets Manager)
CMD [ "node", "dist/index.js" ]
```

- The **AWS SDK** is installed to fetch secrets from AWS Secrets Manager dynamically at runtime.
- Environment variables like `AWS_REGION` and `SECRET_NAME` are set to configure the application to fetch the correct secret.
  
### 4. **Issues and Errors**
#### 1. **ImagePullBackOff Error**
This error occurs when the container image cannot be pulled due to authentication or permission issues. Common causes:
- Incorrect image pull secret.
- Incorrect repository credentials.

**Solution**:
- Ensure the correct image pull secret is configured in the deployment YAML (`imagePullSecrets`).
- Verify credentials (username, password, API key) used for the image pull are valid.

#### 2. **Secrets Not Retrieved**
When using the Secrets Store CSI driver, secrets may not be retrieved if:
- The `SecretProviderClass` is incorrectly configured.
- The service account used does not have the required IAM permissions to access AWS Secrets Manager.

**Solution**:
- Ensure the correct IAM role and policies are attached to the service account.
- Check that the `SecretProviderClass` is correctly configured with the secret name and keys in AWS Secrets Manager.

### 5. **CSI Driver Overview**
The **Container Storage Interface (CSI) Driver** in Kubernetes enables the retrieval of secrets from external stores (like AWS Secrets Manager). When you use the **secrets-store.csi.k8s.io** driver, Kubernetes can mount secrets into containers as volumes. The secrets are dynamically pulled from external providers, and they are not stored in Kubernetes itself, offering enhanced security.

**How to Pull Secrets from AWS Secrets Manager**:
- Configure the `SecretProviderClass` in Kubernetes to specify the AWS Secrets Manager as the provider.
- The Secrets Store CSI driver will pull secrets and mount them in the container as volumes, making them available to the application at runtime.

### Conclusion
This documentation provides a comprehensive guide to setting up a CI/CD pipeline, deploying an application with Kubernetes, and using AWS Secrets Manager to securely manage and pull secrets. The steps include configuration for Docker, Kubernetes deployment, AWS secrets retrieval, and troubleshooting common issues.



### Explanation of the `kubectl describe pod` Output:

This command provides detailed information about a specific pod running in a Kubernetes cluster. Below is a detailed explanation of each section in the output for the pod `express-typescript-app-7c957b46fb-gjgjq`.

---

**1. Pod Metadata:**

- **Name:** `express-typescript-app-7c957b46fb-gjgjq`  
  This is the unique name of the pod in the Kubernetes cluster.

- **Namespace:** `default`  
  The pod is running in the `default` namespace, which is the default namespace in Kubernetes.

- **Priority:** `0`  
  The pod has a priority of 0, meaning it's scheduled with the default priority.

- **Service Account:** `secrets-store-csi-driver`  
  The service account associated with the pod, which allows it to interact with various Kubernetes services. In this case, it's used by the Secrets Store CSI Driver for handling secrets.

- **Node:** `ip-192-168-62-243.ap-south-1.compute.internal/192.168.62.243`  
  The pod is running on the specified node in the Kubernetes cluster.

- **Start Time:** `Mon, 30 Dec 2024 22:48:15 +0530`  
  The timestamp when the pod started.

- **Labels:**  
  - `app=express-typescript`
  - `pod-template-hash=7c957b46fb`  
  These are key-value pairs used to identify and group the pod with other similar resources.

- **Annotations:** `<none>`  
  There are no additional annotations added to the pod.

- **Status:** `Running`  
  The pod is currently in the `Running` state, indicating it's operational.

- **IP:** `192.168.32.143`  
  The internal IP address assigned to the pod within the Kubernetes network.

- **Controlled By:** `ReplicaSet/express-typescript-app-7c957b46fb`  
  This pod is managed by a ReplicaSet, which ensures that a specified number of pod replicas are running at any time.

---

**2. Container Details:**

- **Container Name:** `express-typescript`  
  The name of the container running inside the pod.

- **Container ID:** `containerd://4d761a416c28ac8503066aa9c84d3ae7d5fe8aa271cab51d2ca702fdcbe29f34`  
  The unique identifier of the container inside the pod.

- **Image:** `trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker:latest`  
  The Docker image used by the container. This image is hosted in a JFrog repository.

- **Image ID:** `trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker@sha256:d1a0632a25eefd77e4673ee14e15304d1aa3091b0884058c7544e73d4db63a36`  
  The unique identifier for the image, based on its SHA256 hash.

- **Port:** `3000/TCP`  
  The container exposes port 3000, which the application running inside the container listens to.

- **Host Port:** `0/TCP`  
  No specific host port is mapped, as the container port (3000) is used internally.

- **State:** `Running`  
  The container is currently running and healthy.

- **Started:** `Mon, 30 Dec 2024 22:48:34 +0530`  
  The timestamp when the container started.

- **Ready:** `True`  
  The container is ready to serve requests.

- **Restart Count:** `0`  
  The container has not been restarted since it started.

- **Environment Variables:**  
  These are key-value pairs passed to the container:
  - `NODE_ENV: production`
  - `AWS_STS_REGIONAL_ENDPOINTS: regional`
  - `AWS_DEFAULT_REGION: ap-south-1`
  - `AWS_REGION: ap-south-1`
  - `AWS_ROLE_ARN: arn:aws:iam::221082206597:role/secrets-store-role`
  - `AWS_WEB_IDENTITY_TOKEN_FILE: /var/run/secrets/eks.amazonaws.com/serviceaccount/token`
  
  These environment variables are used for the configuration of the application and integration with AWS services (like IAM role and region settings).

- **Mounts:**  
  - `/mnt/secrets-store` from `secrets-store` (read-only)  
  - `/var/run/secrets/eks.amazonaws.com/serviceaccount` from `aws-iam-token` (read-only)  
  - `/var/run/secrets/kubernetes.io/serviceaccount` from `kube-api-access-45t6r` (read-only)  

  These are volumes mounted into the container for handling secrets and IAM tokens for AWS.

---

**3. Pod Conditions:**

These indicate the various conditions the pod is in:

- **PodReadyToStartContainers:** `True`  
  The pod is ready to start containers.

- **Initialized:** `True`  
  The pod has been initialized.

- **Ready:** `True`  
  The pod is ready to serve traffic.

- **ContainersReady:** `True`  
  The containers inside the pod are ready to handle requests.

- **PodScheduled:** `True`  
  The pod has been scheduled to run on a node.

---

**4. Volumes:**

- **aws-iam-token:**  
  Type: Projected (contains injected data from multiple sources like service accounts and tokens)  
  Token Expiration: 86400 seconds (24 hours)

- **secrets-store:**  
  Type: CSI (Container Storage Interface) volume  
  Driver: `secrets-store.csi.k8s.io`  
  This volume is used for accessing secrets from an external secrets store (like AWS Secrets Manager).

- **kube-api-access-45t6r:**  
  Type: Projected (contains information like the Kubernetes root CA certificate and other API access credentials)  
  Token Expiration: 3607 seconds (about 1 hour).

---

**5. Quality of Service (QoS) Class:**

- **BestEffort:**  
  This QoS class indicates that the pod has not been assigned any resource requests or limits, meaning it is the lowest priority in terms of resource allocation. Kubernetes will evict the pod under resource pressure.

---

**6. Node Selectors and Tolerations:**

- **Node Selectors:** `<none>`  
  The pod does not have specific node selector constraints.

- **Tolerations:**  
  - `node.kubernetes.io/not-ready:NoExecute op=Exists for 300s`  
  - `node.kubernetes.io/unreachable:NoExecute op=Exists for 300s`  
  
  These tolerations allow the pod to be scheduled on nodes that may be in a `not-ready` or `unreachable` state for up to 300 seconds.

---

**7. Events:**

These represent actions taken on the pod:

- **Scheduled:** Successfully scheduled to a node.
- **Pulling:** The container image is being pulled.
- **Pulled:** The container image was successfully pulled.
- **Created:** The container was created.
- **Started:** The container started successfully.

---

satish@Satishs-MacBook-Air Downloads % kubectl describe pod express-typescript-app-7c957b46fb-gjgjq
Name:             express-typescript-app-7c957b46fb-gjgjq
Namespace:        default
Priority:         0
Service Account:  secrets-store-csi-driver
Node:             ip-192-168-62-243.ap-south-1.compute.internal/192.168.62.243
Start Time:       Mon, 30 Dec 2024 22:48:15 +0530
Labels:           app=express-typescript
                  pod-template-hash=7c957b46fb
Annotations:      <none>
Status:           Running
IP:               192.168.32.143
IPs:
  IP:           192.168.32.143
Controlled By:  ReplicaSet/express-typescript-app-7c957b46fb
Containers:
  express-typescript:
    Container ID:   containerd://4d761a416c28ac8503066aa9c84d3ae7d5fe8aa271cab51d2ca702fdcbe29f34
    Image:          trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker:latest
    Image ID:       trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker@sha256:d1a0632a25eefd77e4673ee14e15304d1aa3091b0884058c7544e73d4db63a36
    Port:           3000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 30 Dec 2024 22:48:34 +0530
    Ready:          True
    Restart Count:  0
    Environment:
      NODE_ENV:                     production
      AWS_STS_REGIONAL_ENDPOINTS:   regional
      AWS_DEFAULT_REGION:           ap-south-1
      AWS_REGION:                   ap-south-1
      AWS_ROLE_ARN:                 arn:aws:iam::221082206597:role/secrets-store-role
      AWS_WEB_IDENTITY_TOKEN_FILE:  /var/run/secrets/eks.amazonaws.com/serviceaccount/token
    Mounts:
      /mnt/secrets-store from secrets-store (ro)
      /var/run/secrets/eks.amazonaws.com/serviceaccount from aws-iam-token (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-45t6r (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  aws-iam-token:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  86400
  secrets-store:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            secrets-store.csi.k8s.io
    FSType:
    ReadOnly:          true
    VolumeAttributes:      secretProviderClass=aws-secrets
  kube-api-access-45t6r:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  33m   default-scheduler  Successfully assigned default/express-typescript-app-7c957b46fb-gjgjq to ip-192-168-62-243.ap-south-1.compute.internal
  Normal  Pulling    33m   kubelet            Pulling image "trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker:latest"
  Normal  Pulled     33m   kubelet            Successfully pulled image "trial1tq967.jfrog.io/my-docker-repo1-docker/express-typescript-docker:latest" in 17.86s (17.86s including waiting). Image size: 145533786 bytes.
  Normal  Created    33m   kubelet            Created container express-typescript
  Normal  Started    33m   kubelet            Started container express-typescript



### Conclusion:

This output provides a comprehensive view of the `express-typescript-app-7c957b46fb-gjgjq` pod's status, configuration, and runtime details. It covers aspects such as its node assignment, container information, environment variables, volume mounts, and event history. This information is crucial for debugging and monitoring the pod's behavior and health in a Kubernetes cluster.
