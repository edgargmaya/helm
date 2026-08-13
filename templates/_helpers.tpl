{{- define "ora-microservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ora-microservice.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ora-microservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ora-microservice.labels" -}}
helm.sh/chart: {{ include "ora-microservice.chart" . }}
{{ include "ora-microservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "ora-microservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ora-microservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "ora-microservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "ora-microservice.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "ora-microservice.image" -}}
{{- if .Values.image.digest -}}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) -}}
{{- end -}}
{{- end -}}

{{- define "ora-microservice.validate" -}}
{{- if not .Values.image.repository -}}
{{- fail "image.repository is required" -}}
{{- end -}}
{{- if and (not .Values.image.tag) (not .Values.image.digest) -}}
{{- fail "image.tag or image.digest is required" -}}
{{- end -}}
{{- if not (((.Values.probes).liveness).httpGet).path -}}
{{- fail "probes.liveness.httpGet.path is required" -}}
{{- end -}}
{{- if not (((.Values.probes).readiness).httpGet).path -}}
{{- fail "probes.readiness.httpGet.path is required" -}}
{{- end -}}
{{- if and .Values.autoscaling.enabled (lt (int .Values.autoscaling.maxReplicas) (int .Values.autoscaling.minReplicas)) -}}
{{- fail "autoscaling.maxReplicas must be greater than or equal to autoscaling.minReplicas" -}}
{{- end -}}
{{- if and .Values.autoscaling.enabled (not .Values.autoscaling.metrics) (not .Values.autoscaling.targetCPUUtilizationPercentage) (not .Values.autoscaling.targetMemoryUtilizationPercentage) -}}
{{- fail "autoscaling requires metrics, targetCPUUtilizationPercentage, or targetMemoryUtilizationPercentage when enabled" -}}
{{- end -}}
{{- if and .Values.externalSecrets.enabled (not .Values.externalSecrets.secrets) -}}
{{- fail "externalSecrets.secrets must contain at least one item when externalSecrets.enabled is true" -}}
{{- end -}}
{{- end -}}
