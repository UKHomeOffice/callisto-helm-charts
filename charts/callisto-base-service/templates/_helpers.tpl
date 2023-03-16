{{/*
Expand the name of the chart.
*/}}
{{- define "callisto-base-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "callisto-base-service.fullname" -}}
{{/*{{ default .Release.Name }}*/}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default .Release.Name }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "callisto-base-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "callisto-base-service.labels" -}}
helm.sh/chart: {{ include "callisto-base-service.chart" . }}
{{ include "callisto-base-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "callisto-base-service.selectorLabels" -}}
app: {{ include "callisto-base-service.fullname" . }}
app.kubernetes.io/name: {{ include "callisto-base-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "callisto-base-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "callisto-base-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image name and tag for the Callisto component being deployed
*/}}
{{- define "callisto-base-service.deploymentImageName" -}}
{{- required ".Values.image.repository is required" .Values.image.repository }}:{{ required ".Values.image.tag is required" .Values.image.tag }}
{{- end }}

{{/*
MSK environment variables
*/}}
{{- define "callisto-base-service.mskEnvironmentVariables" -}}
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
{{- define "callisto-base-service.kafkaEnvironmentVariables" -}}
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
      name: {{ include "callisto-base-service.keystore-password-secret-name" .}}
- name: KAFKA_TOPIC
  value: {{ $defaultTopic }}
{{- end }}

{{/*
Create a default name for keystore password secret name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "callisto-base-service.keystore-password-secret-name" -}}
{{- if .Values.keystorePasswordSecretNameOverride }}
{{- .Values.keystorePasswordSecretNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "keystore-%s" (include "callisto-base-service.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Keystore password.
Returns the value of the existing secret or generates a new value
*/}}
{{- define "callisto-base-service.keystore-password" -}}
{{- if not .Values.kafka.keystorePassword }}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "callisto-base-service.keystore-password-secret-name" .) ) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $passwordSecret := (get $secretData "password" | b64dec) | default (randAlphaNum 32) }}
{{- $_ := set .Values.kafka "keystorePassword" $passwordSecret }}
{{- end }}
{{- .Values.kafka.keystorePassword }}
{{- end }}

{{/*
Create a name for scripts config map.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "callisto-base-service.scripts-configmap-name" -}}
{{- printf "scripts-%s" (include "callisto-base-service.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
