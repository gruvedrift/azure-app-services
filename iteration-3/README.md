## Project Iteration 3: Advanced Deployment Strategies

#### Syllabus Objectives Covered:

* Deploy code and containerized solutions
* Configure deployment slots

**Learning Goals:** Master sophisticated deployment patterns that enable safe, continuous delivery to production
environments.

**Project Description:** Implement a complete CI/CD pipeline using deployment slots. Create staging and production
environments that allow safe testing of changes
before they affect real users.

### Implementation Steps:

1. Create staging and production deployment slots
2. Configure slot-specific settings versus shared settings
3. Implement automated deployment from Git repository to staging
4. Create a manual promotion process from staging to production
5. Test slot swap operations and understand their implications
6. Implement rollback procedures for failed deployments

### 1 + 2. Create staging and production deployment slots + Configure slot-specific settings versus shared settings

Azure App Service deployment slots are live environments within the same App Service instance, which means we don't pay for additional 
deployment slots. Each slot has its own hostname and configuration. This allows us to:

- Deploy new versions safely ( while having the old versions running simultaneously )
- Test the new version in a staging environment before going live.
- Swap slots to promote a version to production with zero downtime.
- Easy rollback if a deployment fails.

Slots can be created through the Azure Portal, with the Azure CLI, or with Terraform. For this project iteration, we will mostly look at the use of Terraform for
creating the necessary resources, and use scripting with Azure CLI for promoting and SWÆP slots.


❗ Deployment Slots are only available for  **Standard** or **Premium** Service plans. ❗
#### Key characteristics:

| **Feature**                  | **Description**                                                 |
|------------------------------|-----------------------------------------------------------------|
| **Slot-specific settings**   | Some settings ( like connection strings) can be unique per.slot |
| **Shared resources**         | Slots share the same App Service plan ( CPU, memory)            |
| **Swap capability**          | You can swap staging and production seamlessly                  |
| **Zero downtime deployment** | Users experience minimal interruption during slot swaps         |

#### When to use Deployment slots? 
- When you need **staging environments** for testing.
- When you want **gradual rollouts** for versions.
- When your application requires **zero downtime** deployments.

### 1. Create staging and production deployment slots
For this sub-iteration I have chosen the following approach. Create two slots, one for `staging` and one for `production`. 
With App Service Slots, the main web app we create **is** the production slot. This means we only need to configure one additional slot for this example.
It is important to note that all app settings are swapped when slots are swapped.
```terraform
app_settings = {
    # Slot specific environment variables
    APPLICATION_VERSION = "v1.0"
    ENVIRONMENT         = "STAGING"
  }
```
That means that if we swap the `STAGING` slot with the `PRODUCTION` slot, production would suddenly have `ENVIRONMENT="STAGING". 

For this example I have chosen to use "sticky" setting to mark the `ENVIRONMENT`  and `DATABASE_CONNECTION` variables as "locked to the slot". 
Those two variables will be `SLOT SPECIFIC` and will never change, even though we swap slots. This is typically critical configuration, such 
as, database connection strings, authentication details or other environment specific parameters.


#### How this works step by step: 
1) Create infrastructure with an extra deployment slot for **staging**.
2) Build application and push to registry. This is the v1.0 version which will run on both slots.
3) Enter the Azure Portal and check out the two deployments and see that the slot specific variables `ENVIRONMENT` and `DATABASE_CONNECTION` is correct.
4) Run the `delploy_v2_staging.sh` to create second application, now with a v2.0 tag and deploy it to registry. The environment variable should be updated now: 
![image](./img/staging-v2.png)
5) Run the `swap_slots.sh` script for swapping the slots. You should now be able to observe the production slot, running `v2.0`: 
![image](./img/production-v2.png)

What we can observe is that the environment variables marked as `sticky`, are slot specific, while the version is mutable 
and can be changed with `Azure CLI`. This is the key behavior that makes deployment slots safe and powerful.

### Relevant Azure CLI commands for SLOTS

```bash
# Create staging slot
az webapp deployment slot create \
    --name <your-webapp-name> \
    --resource-group <your-rg> \
    --slot <slot-name>

# Update container image for slot
az webapp config container set \
    --name  <app-name> \
    --resource-group <resource-group> \
    --slot <slot-name> \
    --container-image-name <new-container-image>

# Update non-sticky environment variables 
az webapp config appsettings set \
    --name <app-name> \
    --resource-group <resource-group> \
    --slot <slot-name> \
    --settings APPLICATION_VERSION=<new-version-tag>
    
# Swap slots
az webapp deployment slot swap \
    --name <app-name> \
    --resource-group <resource-group> \
    --slot <slot-name> \
    --target <target-slot>
```


