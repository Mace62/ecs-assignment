# ClickOps Deployment Flow

ECS deployment of the Threat Composer app via the AWS Console.

## 1. ECR

```text
ECR
└── Create ECR repository
    └── Tag Docker image
        └── Push image to ECR
```

![ECR repository](./images/ECR.png)

## 2. ECS

```text
ECS
└── Create ECS Cluster
    └── Create Task Definition
        ├── Add ECR image URI
        ├── Set CPU/memory
        ├── Set container port
        └── Add execution role
```

![ECS cluster](./images/ECS%20Cluster.png)

![Task definition](./images/Task%20Definition.png)

![ECS task running](./images/ECS%20Task.png)

## 3. Load Balancing

```text
Load Balancing
└── Create ECS Service
    └── Create/attach ALB
        └── Create Target Group
            └── Configure /health check
                └── Confirm target is healthy
```

![Application Load Balancer](./images/ALB.png)

![Target group health check](./images/Target%20Group.png)

## 4. Networking & Security

```text
Networking/Security
├── ALB Security Group
│   └── Allow HTTP 80 and HTTPS 443 from internet
│
└── ECS Task Security Group
    └── Allow traffic only from ALB security group
```

![Security groups](./images/Security%20Groups.png)

## 5. Domain & HTTPS

```text
Domain & HTTPS
└── Create Cloudflare CNAME
    └── Request ACM certificate
        └── Add ACM validation CNAME in Cloudflare
            └── Attach cert to ALB HTTPS listener
```

![ACM certificate](./images/ACM%20Certificate.png)

![ALB HTTPS listener](./images/ALB%20Listeners.png)

## 6. Validation

```text
Validation
└── Visit/curl final URL
    └── https://tm.samehrashid.com/health
        └── {"status":"ok"}
```

```bash
curl https://tm.samehrashid.com/health
# {"status":"ok"}
```

![Application running on ECS](./images/Application%20Running.png)

![Health endpoint](./images/Health%20Endpoint.png)
