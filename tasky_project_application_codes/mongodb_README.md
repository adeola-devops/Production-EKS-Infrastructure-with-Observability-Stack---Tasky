# MongoDB Backup (Manual Process) – Tasky Project

## Overview

This document outlines the manual backup process for the MongoDB database used in the Tasky application. The backup is performed using mongodump from within the MongoDB instance and stored securely in an S3 bucket.

## Architecture Summary

The infrastructure is deployed in a single VPC with two subnets:

- **Public Subnet**
    - NAT Gateway
    - Monitoring EC2 instance (monitors MongoDB health)

- **Private Subnet**
    - Amazon EKS (Kubernetes cluster)
    - Application deployed with autoscaling nodes
    - MongoDB instance (database layer)

### Security Design

- MongoDB is not publicly accessible
- Access is strictly via AWS SSM Session Manager
- Database credentials are securely stored in AWS Secrets Manager

### Prerequisites

The following are in place before proceeding:

- AWS CLI installed and configured
- IAM permissions for:
    - SSM
    - S3
    - Secrets Manager
- Access to:
    - MongoDB EC2 instance (via SSM)
    - S3 bucket for backups

#### Step 1: Configure AWS CLI
```
aws configure
```

#### Step 2: Validate AWS Configuration
These commands confirm that AWS CLI is properly configured and authenticated.
```
aws s3 ls
aws iam list-roles
```
![Diagram Description](mongodb_diagrams/161835.png)

#### Step 3: Retrieve MongoDB Credentials
```
aws secretsmanager get-secret-value \
  --secret-id <SECRET> \
  --region <REGION>
```

Extract:
- USERNAME
- PASSWORD

![Diagram Description](mongodb_diagrams/162102.png)

#### Step 4: Connect to MongoDB Instance via SSM
```
aws ssm start-session --target <INSTANCE_ID>
```
![Diagram Description](mongodb_diagrams/162808.png)

#### Step 5: Connect to MongoDB
```
mongosh "mongodb://${USERNAME}:${PASSWORD}@localhost:27017/?authSource=admin
```
![Diagram Description](mongodb_diagrams/163828.png)

#### Step 6: Exploring the Database (Optional Validation)

- List all databases:
    - show dbs

![Diagram Description](mongodb_diagrams/193034.png)

- Select the application database:
    - use go-mongodb

![Diagram Description](mongodb_diagrams/185438.png)

- List collections:
    - show collections

- Inspect data:
    - db.user.find()
    - db.todos.find()

#### Step 7: Create Backup Directory
```
mkdir -p /tmp/db-backup
```

#### Step 8: Run MongoDB Backup (mongodump)
```
mongodump --db <database_name> --uri="mongodb://${USERNAME}:${PASSWORD}@${MONGODB_PRIVATE_IP}:27017/<database_name>?authSource=admin" --out /tmp/db-backup
```
![Diagram Description](mongodb_diagrams/192315.png)

#### Step 9: Upload Backup to S3
```
aws s3 sync /tmp/db-backup s3://${DB_S3_BUCKET}
```
![Diagram Description](mongodb_diagrams/192501.png)

#### Quick Validation (Post-Backup)

- Verify backup files exist in S3:
    ```
    aws s3 ls s3://${DB_S3_BUCKET}
    ```
![Diagram Description](mongodb_diagrams/192603.png)

## Outcome

- Database successfully backup to S3
---

# MongoDB Restore (Manual Process) – Tasky Project

## Overview

This document describes the manual restore process for the MongoDB database in the Tasky project.

In the event of:

- MongoDB instance failure
- Data loss or corruption
- Instance rebuild or replacement

The database can be restored from backups stored in S3, ensuring service recovery and data continuity.

**Note: follow steps 1 to 4 above first**

#### Step 5: Create Restore Directory
```
mkdir -p /tmp/db-restore
```

#### Step 6: Backup from S3
This pulls the latest backup files from S3 into the instance.

```
aws s3 sync s3://${DB_S3_BUCKET} /tmp/db-restore
```
![Diagram Description](mongodb_diagrams/184925.png)

#### Step 7: Restore MongoDB Database
```
mongorestore --uri="mongodb://${USERNAME}:${PASSWORD}@${MONGODB_PRIVATE_IP}:27017/?authSource=admin" /tmp/db-restore
```
![Diagram Description](mongodb_diagrams/185111.png)

#### Step 8: Validate Restore (Optional)

**Note: follow step 5 above in mongodb-backup**

## Outcome

- Database successfully restored from S3 backup
-  Application data recovered
-  System ready for normal operation

## Automation Implementation

The backup and restore operations are now handled automatically to improve reliability, consistency, and reduce manual intervention.

### 🔹 Backup Automation
- Database backups are automated using **Bitbucket Pipelines**.
- A scheduled pipeline has been configured to run **every hour**.
- Each execution:
  - Connects to the database
  - Creates a backup
  - Stores the backup securely (e.g., in S3)

### 🔹 Restore Process
- The restore process is also automated and can be triggered when needed.
- In the event of:
  - Database failure
  - Data loss
  - Infrastructure recreation  
- The system can quickly restore the latest backup to ensure minimal downtime.

---

## Pipeline Evidence

Screenshots of the Bitbucket pipeline configurations and successful runs have been attached below for reference:

- Backup pipeline schedule configuration  
- Successful pipeline execution logs  
- Restore process execution  

> _Refer to the attached images for visual confirmation of the automation setup and execution._

![Diagram Description](mongodb_diagrams/200007.png)

![Diagram Description](mongodb_diagrams/195439.png)

![Diagram Description](mongodb_diagrams/195512.png)

![Diagram Description](mongodb_diagrams/200147.png)

![Diagram Description](mongodb_diagrams/200257.png)

![Diagram Description](mongodb_diagrams/200311.png)

---

## Conclusion

The transition from a manual to an automated backup and restore process ensures that the system is more resilient, scalable, and production-ready. Regular hourly backups via Bitbucket Pipelines provide confidence that data can always be recovered when needed.