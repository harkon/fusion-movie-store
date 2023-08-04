# Movie Data API

## Description

The Movie Data API is designed to provide a robust and efficient interface for querying movie data sourced from multiple providers. As updates occur, data providers send their data via AWS S3. Each update is for a single movie and must be stored perpetually since it cannot be retrieved again from the provider.

## Requirements

- **API Availability**: The API must be hosted in a Kubernetes cluster and be available 24/7 with zero downtime.
- **Latency**: API must return response times within 5ms.
- **Data Storage**: A suitable data storage solution must be selected to efficiently handle the data.
- **Query Capabilities**: Data can be queried by year, movie name, cast member, or genre.

## Architecture

Please refer to the [solution overview](./docs/SOLUTION.md) for a detailed view of the chosen architecture.

## Implementation

- **Programming Language**: The system is implemented using Java and Python
- **Data Storage**: MySql RDS Cluster Multi-AZ
- **Caching**: Caching is implemented using Redis to reduce latency.
- **Load Balancing**: [Details about how load balancing is handled, if applicable]
- **Kubernetes**: The API is containerized and deployed within a Kubernetes cluster to ensure high availability and scalability.
- **Routing**: We use AWS API gateway that is the single entry point for all clients. The API gateway handles requests in a simple way. All requests are proxied/routed to the appropriate service.

## Setup & Configuration

### Prerequisites

- AWS Account
- AWS CLI (configured)

### Local Development

Local development is supported through Docker Compose and bash scripts.

1. **Build Docker Images**:

   ```bash
   ./utils/build-image.sh
   ```

2. **Test Lambda Function**:

   ```bash
   ./utils/test-lambda.sh
   ```

3. **Trigger Lambda Function**:
   ```bash
   ./utils/trigger-lambda.sh
   ```
4. **Build everything and run in docker-compose**:
   ```bash
   docker-compose up --build
   ```

### Deployment

The build and push of images are performed manually, while Terraform handles the deployment of lambdas and Kubernetes workloads.
Terraform is using sha256 digest to deploy the images.

1. **Initialize Terraform**:

   ```bash
   terraform init
   ```

2. **Plan Terraform Configuration**:

   ```bash
   terraform plan
   ```

3. **Apply Terraform Configuration**:
   ```bash
   terraform apply
   ```

### Default Configuration Values

You can set the following default values in your configuration:

- **Region**: `eu-central-1`
- **Bucket Name**: `incoming-movie-data`
- **Public Subnets**: `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`
- **Private Subnets**: `["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]`
- **Availability Zones**: `["eu-central-1a", "eu-central-1b", "eu-central-1c"]`
- **EKS Cluster Name**: `dev_eks_cluster`
- **Tags**: `{"Environment" = "Dev"}`
- **Lambda Repo**: `["fusion-movie-store/process_movie_data"]`
- **Service Repo**: `["fusion-movie-store/movie-store-api"]`
- **Image Mutability**: `MUTABLE`
- **S3 Lambda Function Name**: `process_movie_data`

#### Using `variables.auto.tfvars` file

Create a `variables.auto.tfvars` file with the above values, and Terraform will load them automatically during initialization.

Example:

```hcl
region = "eu-central-1"
bucket_name = "incoming-movie-data"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
eks_cluster_name = "dev_eks_cluster"
tags = {
  "Environment" = "Dev"
}
lambda_repo = ["fusion-movie-store/process_movie_data"]
service_repo = ["fusion-movie-store/movie-store-api"]
image_mutability = "MUTABLE"
s3_lambda_function_name = "process_movie_data"
```

## Endpoints

[Describe the available API endpoints for querying data by year, movie name, cast member, or genre.]

## Testing

[Describe how the API can be tested, including any available test scripts or tools.]

## TODO
- VPN
- 

## Contributing

Contributions are welcome. Please see the [CONTRIBUTING.md](CONTRIBUTING.md) for more details on how to contribute to this project.

## License

This project is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for details.
