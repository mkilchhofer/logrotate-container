# Overview
We need a solution for legacy apps running in a kubernetes cluster writing logs to a file without rotating them (in a traditional way).

# Example Setup
I assume that a legacy app inside Kubernetes write logs to a PV resp. PVC called `app-logs-pv`.

## Kubernetes Prereqs
The example PVC `app-logs-pv` has to be present and the legacy app writes its logfile to this. `accessMode` of this PVC must be **RWX** (ReadWriteMany) as we want to rotate them from a different Pod (seperate to the application).
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-logs-pv
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Mi
```

## Cronjob example setup
### Define Logrotate Config
```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: logrotate-config
data:
  my_logs.conf: |
    /var/log/app/*.log {
        daily
        missingok
        rotate 7
        compress
        delaycompress
        dateformat -%Y%m%d_%H%M%S
        notifempty
        copytruncate
        su
    }
  my_txt_logs.conf: |
    /var/log/app/*.txt {
        daily
        missingok
        rotate 3
        compress
        delaycompress
        dateformat -%Y%m%d_%H%M%S
        notifempty
        copytruncate
        su
    }
```
### Define Cronjob
```yaml
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: app-logrotate
spec:
  schedule: "*/1 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: logrotate
            image: docker.io/kicm/logrotate
            volumeMounts:
            - name: logrotate-conf
              mountPath: /etc/logrotate.d
            - name: app-logs
              mountPath: /var/log/app
          volumes:
          - name: logrotate-conf
            configMap:
              name: logrotate-config
          - name: app-logs
            persistentVolumeClaim:
              claimName: app-logs-pv
          restartPolicy: OnFailure
```
