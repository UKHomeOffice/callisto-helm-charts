# Callisto Helm Charts

## callisto-base-chart

It is the responsibility of the services using this Helm chart to supply certain values.
Some are required for all services. Others will be required only in certain configurations.

For example, Docker repository for the main container image will always have to be specified.
However, database configuration is only required if the service uses data storage (e.g. REST API)

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
databaseImage:
  repositoryName: callisto-accruals-database
  tag: latest
```
Database migration will also require [Database access details](#database-access)

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
Some Callisto services are exposed on the network.

Below is an example of Helm values to set up Ingress for Accruals REST API:
```yaml
ingress:
  host: accruals.dev.callisto-notprod.homeoffice.gov.uk
  tls_secret_name: accruals-restapi-tls
  cors_origin: "https://*.dev.callisto-notprod.homeoffice.gov.uk"
```
