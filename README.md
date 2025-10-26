# Azure App Service

This project was created as a **hands-on-practice** for preparing for the az-204 exam. It demonstrates how to use,
configure and deploy Azure
App Services. Examples are based on real-world applicable scenarios, and can be used as a "baseline" reference.
The project is split into four iterations where each iteration are standalone projects with different scopes and
learning outcomes.

Additional exam relevant questions are included in
the [QA.md](https://github.com/gruvedrift/azure-app-services/blob/main/Extra-Resources/QA.md) file.

### Requirements:

- Azure subscription
- Terraform
- Docker technology ( [Docker Desktop](https://www.docker.com/products/docker-desktop) ,
  [Podman](https://www.docker.com/products/docker-desktop) or [Colima](https://github.com/abiosoft/colima) )
- .NET and .NET SDK
- Python

### Each Iteration contains:

* Terraform configuration for provisioning the necessary resources.
* A Python or .NET application with necessary code and functionality for testing.
* Various scripts for provision, build and testing automatization.
* A comprehensive README file with sections for:
    * Learning Goals
    * Project description
    * Implementation steps
    * General theoretical overview of the topics covered, anchored in the az-204 syllabus
    * Relevant Azure CLI commands
    * General findings and heads-ups

## Conceptual introduction

Azure App Service represents the platform-as-a-service (PaaS) approach to web application hosting.
With App Service, Microsoft handles the underlying infrastructure, OS updates, security patches, and scaling mechanisms,
allowing developers to focus on application code.

## Business Value Proposition

Organizations choose App Service to accelerate development velocity and reduce operational overhead. Traditional server
management requires dedicated IT staff to
handle patching, monitoring, and scaling. App Service eliminates these responsibilities while providing enterprise-grade
features like automatic backups, SSL
certificate management, and integrated monitoring.

Furthermore, the service particularly excels for organizations with fluctuating traffic patterns. Instead of
over-provisioning servers to handle peak loads, App Service can
automatically scale resources up or down based on actual demand. This elasticity can result in significant cost savings
compared to maintaining dedicated infrastructure.

---

### 1. Iteration - Basic Web App Creation and Configuration:

* **Create Azure App Service Web Apps** - Provision App Service Plans and Web Apps using Terraform.
* **Configure TLS/SSL** - Implement HTTPS, custom domains, and certificate management.
* **Application Settings Management** - Configure environment variables, connection strings, and API settings.
* **Deploy containerized solutions** - Package and deploy applications using Docker containers to Azure Container Registry.
* **Basic monitoring setup** - Enable diagnostic logging and understand App Service logs.

---

### 2. Iteration - Monitoring and Diagnostics Implementation:

* **Application Insights integration** - Enable comprehensive application performance monitoring and telemetry.
* **Configure diagnostic logging** - Set up application logs, web server logs, and detailed error messages.
* **Custom metrics and alerts** - Implement custom telemetry, tracking and automated alerting for production issues.
* **Performance monitoring** - Create dashboards and use metrics to enable identification of bottlenecks.
* **Troubleshooting workflows** - Practice using logs, metrics, and Application Insights to diagnose production issues.

---

### 3. Iteration - Advanced Deployment Strategies

* **Configure deployment slots** - Create `STAGING` and `PRODUCTION` environments for safe, zero-downtime deployments.
* **Slot-specific vs. Shared settings** - Understand and configure "sticky settings" for environment specific configuration.
* **Automated CI/CD pipelines** - Implement GitHub Actions workflows for automated deployments to staging on pull requests.
* **Slot swap operations** - Master manual promotion from staging to production.
* **Rollback procedures** - Implement emergency rollback workflows for "failed" production deployments.
* **Blue-green deployment patterns** - Understand how slot swaps enable instant rollback and A/B testing scenarios.

---

### 4. Iteration - Scaling And Performance Optimization

* **Implement autoscaling** - Configure automated scaling based on metrics and schedules.
* **CPU-based autoscaling** - Set up reactive scaling rules based on compute resource utilization.
* **HTTP Queue Length scaling** - Implement proactive scaling based on request queue depth for better responsiveness.
* **Schedule-based scaling** - Configure predictive scaling for known traffic patterns (business hours, seasonal loads, etc.).
* **Platform limitations discovery** - Documentation of real-world challenges with containerized workloads and metric collection.
* **Cost optimization strategies** - Reflection on balancing performance requirements with cost constraints through scaling.

---