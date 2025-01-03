{{/*
Expand the name of the chart.
*/}}
{{- define "sample-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "sample-chart.shortname" -}}
sample
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sample-chart.fullname" -}}
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
{{- define "sample-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sample-chart.labels" -}}
helm.sh/chart: {{ include "sample-chart.chart" . }}
{{ include "sample-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sample-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sample-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sample-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sample-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "sample-chart.config" -}}
{{- $configData := dict -}}
{{- $_ := set $configData "application.yml" (.Values.applicationProperties |  toYaml | nindent 2) }}
{{- if .Values.config }}
{{- range $k, $v := .Values.config }}
{{- $_ := set $configData $k ($v | toPrettyJson | nindent 2) }}
{{- end }}
{{- else }}
{{- range $path, $_ := .Files.Glob "config/*"}}
{{- $_ := set $configData ($path | replace "config/"  "") ($.Files.Get $path | fromJson | toPrettyJson | nindent 2) }}
{{- end }}
{{- end }}
data: {{ $configData | toJson}}
{{- end }}