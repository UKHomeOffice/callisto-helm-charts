# Callisto Helm Charts

## callisto-base-chart

It is the responsibility of the services using this Helm chart to supply certain values.
Some are required for all services. Others will be required only in certain configurations.

For example, Docker repository for the main container image will always have to be specified.
However, database configuration is only required if the service uses data storage (e.g. REST API).

### Main container image (mandatory)

The service using this Helm chart has to specify the image of its main container.
The latter could be, for instance, a REST API service or a Kafka consumer.

Below is an example of Helm values for Accruals REST API:
```yaml
mainContainerImage:
  repositoryName: callisto-accruals-restapi
  tag: latest
```

### Container port (mandatory)
This is the internal port which has to match the port exposed in the main container Docker image.
```yaml
service:
  containerPort: 9090
```

### Database access
Some Callisto services require access to a datastore.

Below is an example of Helm values to set up access to the database for Accruals REST API:
```yaml
db:
  secretKeyRefName: "callistodev-rds"
  schemaName: "accruals"
```

### Database migration init container image
If a service requires a data storage, it will also require database migration.

Below is an example of Helm values for Accruals database migration:
```yaml
databaseMigrationImage:
  repositoryName: callisto-accruals-database
  tag: latest
```
Database migration will also require [Database access details](#database-access)

### Kafka topic setup
Some Callisto services may own one or more Kafka topics on MSK.

Below is an example of Helm values to create Kafka topics, if they don't exist already and set up 
their ACLs:
```yaml
kafka:
  createTopics:
    topicNames: |-
      callisto-topic-1
      callisto-topic-2
    permissions: |-
      --topic topic-1 --resource-pattern-type prefixed
      User:service-1     Write       Allow
      User:service-1     Describe    Allow
      --topic topic-2 --resource-pattern-type prefixed
      User:service-2     Read        Allow
      User:service-2     Describe    Allow
```

### Access to Kafka
Some Callisto services require access to one Kafka topic (or more) on MSK.

Below is an example of Helm values to set up access to Kafka for Accruals REST API:
```yaml
kafka:
  identity: accruals-restapi
  mskSecretKeyRefName: "callisto-dev-msk"
  bootstrapSecretKeyRefName: "callisto-dev-bootstrap"
  defaultTopic: "callisto-timecard-timeentries"
```

### Ingress
Some Callisto services are exposed on the network. For dev, test and prod this is managed through
a separate repository `callisto-ingress-nginx`. For branch deployment, hostname, TLS secret name 
and CORS origin should be specified as Helm values. 

The branch name should be passed from the branch deploy CI/CD step (value should be named `branch`).

Below is an example of Helm values to set up Ingress for Accruals REST API branch deployment:
```yaml
ingress:
  branch: main # overwritten by branch deploy
  host: accruals.dev.callisto-notprod.homeoffice.gov.uk
  tlsSecretName: callisto-accruals-tls
  corsOrigin: "https://*.dev.callisto-notprod.homeoffice.gov.uk"
```

## Example of full Values file:
```yaml
mainContainerImage:
  repositoryName: callisto-accruals-restapi
  tag: latest
  
databaseMigrationImage:
  repositoryName: callisto-accruals-database
  tag: latest

kafka:
  identity: accruals-restapi
  mskSecretKeyRefName: "callisto-dev-msk"
  bootstrapSecretKeyRefName: "callisto-dev-bootstrap"
  defaultTopic: "callisto-timecard-timeentries"

db:
  secretKeyRefName: "callistodev-rds"
  schemaName: "accruals"

service:
  containerPort: 9090

ingress:
  branch: main # overwritten by branch deploy
  host: accruals.dev.callisto-notprod.homeoffice.gov.uk
  tlsSecretName: callisto-accruals-tls
  corsOrigin: "https://*.dev.callisto-notprod.homeoffice.gov.uk"
```

## Known issue
[Kafka SSL Certificate Rotation](https://github.com/UKHomeOffice/callisto-helm-charts/issues/10)
[Add network policy rules](https://github.com/UKHomeOffice/callisto-helm-charts/issues/11)