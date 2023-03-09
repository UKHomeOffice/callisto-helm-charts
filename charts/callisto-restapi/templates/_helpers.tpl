{{/*
Expand the name of the chart.
*/}}
{{- define "callisto-restapi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "callisto-restapi.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "callisto-restapi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "callisto-restapi.labels" -}}
helm.sh/chart: {{ include "callisto-restapi.chart" . }}
{{ include "callisto-restapi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "callisto-restapi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "callisto-restapi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create a default name for keystore password secret name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "callisto-restapi.keystore-password-secret-name" -}}
{{- if .Values.keystorePasswordSecretNameOverride }}
{{- .Values.keystorePasswordSecretNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "keystore-%s" (include "callisto-restapi.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a name for scripts config map.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "callisto-restapi.scripts-configmap-name" -}}
{{- printf "scripts-%s" (include "callisto-restapi.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Database environment variables
*/}}
{{- define "callisto-restapi.databaseEnvironmentVariables" -}}
{{- $databaseSecretKeyRefName := required ".Values.databaseSecretKeyRefName is required." .Values.databaseSecretKeyRefName -}}
- name: DATABASE_NAME
  valueFrom:
    secretKeyRef:
      key: db_name
      name: {{ $databaseSecretKeyRefName }}
- name: DATABASE_USERNAME
  valueFrom:
    secretKeyRef:
      key: username
      name: {{ $databaseSecretKeyRefName }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      key: password
      name: {{ $databaseSecretKeyRefName }}
- name: DATABASE_ENDPOINT
  valueFrom:
    secretKeyRef:
      key: endpoint
      name: {{ $databaseSecretKeyRefName }}
- name: DATABASE_PORT
  valueFrom:
    secretKeyRef:
      key: port
      name: {{ $databaseSecretKeyRefName }}
{{- end }}

{{/*
MSK environment variables
*/}}
{{- define "callisto-restapi.mskEnvironmentVariables" -}}
{{- $mskSecretKeyRefName := required ".Values.kafka.mskSecretKeyRefName is required." .Values.kafka.mskSecretKeyRefName -}}
- name: AWS_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      key: certificate_authority_access_keys
      name: {{ $mskSecretKeyRefName }}
- name: AWS_SECRET_KEY
  valueFrom:
    secretKeyRef:
      key: certificate_authority_secret_keys
      name: {{ $mskSecretKeyRefName }}
- name: AWS_CERTIFICATE_AUTHORITY_ARN
  valueFrom:
    secretKeyRef:
      key: certificate_authority_arn
      name: {{ $mskSecretKeyRefName }}
{{- end }}

{{/*
Kafka environment variables
*/}}
{{- define "callisto-restapi.kafkaEnvironmentVariables" -}}
{{- $bootstrapSecretKeyRefName := required ".Values.kafka.bootstrapSecretKeyRefName is required." .Values.kafka.bootstrapSecretKeyRefName -}}
{{- $defaultTopic := required ".Values.kafka.defaultTopic is required." .Values.kafka.defaultTopic -}}
- name: BOOTSTRAP_SERVER1
  valueFrom:
    secretKeyRef:
      key: bootstrap_server1
      name: {{ $bootstrapSecretKeyRefName }}
- name: BOOTSTRAP_SERVER2
  valueFrom:
    secretKeyRef:
      key: bootstrap_server2
      name: {{ $bootstrapSecretKeyRefName }}
- name: BOOTSTRAP_SERVER3
  valueFrom:
    secretKeyRef:
      key: bootstrap_server3
      name: {{ $bootstrapSecretKeyRefName }}
- name: BOOTSTRAP_SERVER
  value: "$(BOOTSTRAP_SERVER1),$(BOOTSTRAP_SERVER2),$(BOOTSTRAP_SERVER3)"
- name: KEYSTORE_PASSWORD
  valueFrom:
    secretKeyRef:
      key: password
      name: {{ include "callisto-restapi.keystore-password-secret-name" .}}
- name: KAFKA_TOPIC
  value: {{ $defaultTopic }}
{{- end }}

{{/*
Determine the cors origin.
If a cors is enabled it will return the configured ingress.cors.origin value.
If not present it will use the host value if only a single host is configured.
If multiple hosts exist the ingress.cors.origin value will be required. 
*/}}
{{- define "callisto-restapi.cors-origin" -}}
{{- if and .Values.ingress.cors .Values.ingress.cors.origin }}
{{- .Values.ingress.cors.origin }}
{{- else }}
{{- required ".Values.ingress.host is required" .Values.ingress.host }}
{{- end }}
{{- end }}

{{/*
Keystore password.
Returns the value of the existing secret or generates a new value
*/}}
{{- define "callisto-restapi.keystore-password" -}}
{{- if not .Values.kafka.keystorePassword }}
{{- $secretObj := (lookup "v1" "Secret" (include "callisto-restapi.keystore-password-secret-name" .) "password") | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $passwordSecret := (get $secretData "password" | b64dec) | default (randAlphaNum 32) }}
{{- $_ := set .Values.kafka "keystorePassword" $passwordSecret }}
{{- end }}
{{- .Values.kafka.keystorePassword }}
{{- end }}

