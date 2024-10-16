# Deploying a Flask Application Using Docker, ACR, and Kubernetes

## Project Overview

This project demonstrates how to deploy a Flask web application using multiple methods: Docker, Azure Container Registry (ACR), and Kubernetes. The application is packaged into a Docker container, pushed to an Azure Container Registry, and deployed on either an Azure Virtual Machine (VM), Azure Container Instance (ACI), or Kubernetes. The infrastructure is managed using Terraform, ensuring a consistent and automated deployment process.

## Key Technologies

- **Flask**: A lightweight WSGI web application framework in Python.
- **Docker**: Used to containerize the Flask application.
- **Azure**: Provides the cloud infrastructure (Azure Virtual Machines, Azure Container Registry, Azure Kubernetes Service).
- **Terraform**: Infrastructure as Code (IaC) to automate the provisioning of cloud resources.
- **Kubernetes**: For container orchestration and deployment.
- **CI/CD Pipeline**: Automated using Azure Pipelines to build, push, and deploy the Docker image.

## Project Architecture

1. **Docker Image Creation**:

   - Flask app is packaged into a Docker image using a `Dockerfile`.
   - The Docker image is tagged and pushed to an Azure Container Registry (ACR).

2. **Terraform for Infrastructure**:

   - Terraform provisions the necessary cloud resources:
     - Virtual network (VNet)
     - Network security groups (NSG)
     - Virtual machine (VM) or Azure Kubernetes Service (AKS)
     - Public IP address

3. **Deployment Methods**:

   - **Local Docker Deployment**: Running the application locally with Docker.
   - **Azure VM Deployment**: Using Terraform to deploy the Flask app on an Azure Virtual Machine.
   - **Azure Container Instance (ACI)**: Running the Flask container in an ACI instance.
   - **Kubernetes Deployment**: Deploying the Flask container on Azure Kubernetes Service (AKS).

4. **Testing**:
   - The Flask application exposes a `/liveness` endpoint that is tested using `curl` after each deployment.

## Prerequisites

To run this project, ensure you have the following:

- **Azure Account**: Set up a free Azure account if you don’t have one.
- **Terraform**: Installed on your local machine.
- **Docker**: Installed and running on your machine.
- **Azure CLI**: For Azure authentication and container management.
- **Kubernetes CLI (kubectl)**: For managing Kubernetes clusters.
- **Azure DevOps**: For managing the CI/CD pipeline.

## How to Run Locally

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/project-name.git
   cd project-name
   ```

2. **Build and Run Docker Locally**:

   ```bash
   docker build -t flask_app .
   docker run -p 5000:5000 flask_app
   ```

3. **Access the Application**:
   Visit `http://localhost:5000/liveness` in your browser to verify the app is running.

## Deployment Using ACR and Azure

### Deployment with ACR and ACI (Azure Container Instance)

1. **Set Up Terraform**:
   Initialize Terraform and plan the deployment:

   ```bash
   terraform init
   terraform apply -auto-approve
   ```

2. **Outputs**:
   After deployment, Terraform will output the public IP of the VM or Container Instance.

3. **Test the Deployment**:
   Once the deployment is complete, use the following to test the Flask app:
   ```bash
   curl http://<public_ip>:5000/liveness
   ```

### Kubernetes Deployment on Azure AKS

1. **Create Kubernetes Cluster**:
   Provision an AKS cluster using Terraform.

2. **Deploy to Kubernetes**:

   - Use the `kubectl` command to deploy the Docker image to the Kubernetes cluster:

   ```bash
   kubectl apply -f deployment.yaml
   ```

3. **Check Pod Status**:

   ```bash
   kubectl get pods
   ```

4. **Test Kubernetes Deployment**:
   Use `kubectl` to expose the service and test the application on the Kubernetes cluster:
   ```bash
   curl http://<kubernetes_service_ip>:5000/liveness
   ```

## CI/CD Pipeline

The project uses an Azure DevOps pipeline to automate the following steps:

1. **Build Docker Image**: Build the Flask Docker image.
2. **Push to ACR**: Push the image to Azure Container Registry.
3. **Deploy Infrastructure**: Provision resources using Terraform.
4. **Deploy to Kubernetes**: Deploy the Flask app on Azure Kubernetes Service.
5. **Test Endpoint**: After deployment, the endpoint is tested with a `curl` command.

## Challenges & Solutions

Some of the key challenges faced during this project include:

- **Terraform Configuration**: Ensuring proper configuration for NSGs and VMs.
- **Docker Authentication**: Handling Azure Container Registry authentication during automated deployments.
- **Kubernetes Orchestration**: Ensuring that services are correctly deployed and configured on Kubernetes.

Solutions include thorough error handling in the Terraform script and proper configuration of NSGs for secure access.

## Future Enhancements

- **Logging and Monitoring**: Set up centralized logging and monitoring using Azure Monitor or another service.
- **Scalability**: Explore autoscaling options for Kubernetes and ACI deployments.
- **Advanced Orchestration**: Improve deployment strategies with Helm charts and advanced Kubernetes configurations.

## Conclusion

This project provides a comprehensive approach to deploying a Python Flask application using Docker, ACR, Kubernetes, and Azure. By leveraging CI/CD practices and modern cloud infrastructure, we can ensure a smooth, automated deployment process that minimizes manual intervention and is scalable.

---

## Author

**Guler Vlad-Stefan**

_This project was created as part of a final project for {Dev}School - DevOps Edition from ING Hubs Romania, demonstrating Flask application deployment using Docker, Terraform, Kubernetes, and Azure services._
