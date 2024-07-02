{{- if .Values.exporter.enabled -}}
exporter:
  duration: {{ .Values.exporter.duration }}
  prometheusPort: {{ .Values.exporter.prometheusPort }}
  period: {{ .Values.exporter.period }}
  multicloudEndpoint: {{ .Values.config.multiCloud.endpoint }}
  multicloudUsername: {{ .Values.config.multiCloud.username }}
  awsRegion: {{ .Values.config.allowedServices.email }}
  awsAccess: {{ .Values.config.awsAccess }}
  keystoneRegion: {{ .Values.config.keystone.region }}
  receivingDelay: {{ .Values.exporter.receivingDelay }}
  sendingDelay: {{ .Values.exporter.sendingDelay }}
  suppressionDelay: {{ .Values.exporter.suppressionDelay }}
  accountsDelay: {{ .Values.exporter.accountsDelay }}
  identityDelay: {{ .Values.exporter.identityDelay }}
  quotaDelay: {{ .Values.exporter.quotaDelay }}
  clientErrorDelay: {{ .Values.exporter.clientErrorDelay }}
  maxAllowedSuppression: {{ .Values.exporter.maxAllowedSuppression }}
  getAccountsDelayHour: {{ .Values.exporter.getAccountsDelayHour }}
  applicationCredentialsProject: {{ .Values.updater.applicationCredentialsProject }}
  applicationCredentialsDomain: {{ .Values.updater.applicationCredentialsDomain }}
  applicationCredentialsName: {{ .Values.updater.applicationCredentialsName }}
{{- end }}
