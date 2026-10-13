# Cloud-Native Platform — GitOps and Kubernetes

> **Project status: Concluded at the current implementation stage (13 October 2026).**  
> This repository records the Kubernetes delivery and observability work completed. Some originally planned platform capabilities remain incomplete.

## Overview

This repository contains the GitOps-managed Kubernetes deployment for the `cloud-native-platform-app`. Argo CD watches this repository's `master` branch and reconciles the Helm chart into the EKS cluster.

## Technology used

- Amazon EKS (Kubernetes `v1.36.4-eks-3b4a6ca` as observed during project checks)
- Helm
- Argo CD
- Kubernetes Deployments, Services and HorizontalPodAutoscaler
- Amazon ECR
- Prometheus
- Grafana
- Alertmanager
- `kube-prometheus-stack` Helm chart (chart version `92.3.0`, app version `v0.94.1` as recorded)

AWS infrastructure provisioning and state management are maintained separately in the Terraform project files. The application source and CI pipeline are maintained in [cloud-native-platform-app](https://github.com/trivediayush/cloud-native-platform-app).

## Repository layout

```text
.
├── kubernetes/
│   └── helm/
│       └── cloud-native-platform-app/
├── docs/
│   └── reliability-test-evidence.txt
└── README.md
```

This is a representative layout of the documented project artifacts; check the repository tree for the exact current files.

## Application deployment

The Helm chart deploys the Flask application with the following recorded settings:
- Image repository: `902061578854.dkr.ecr.eu-west-2.amazonaws.com/cloud-native-platform-app`
- Container port: `8080`
- Kubernetes Service: `ClusterIP`, service port `80`, target port `8080`
- Replica count in values: `3` (the live HPA-managed deployment was observed at two replicas during final verification)
- Resource requests: CPU `100m`, memory `128Mi`
- Resource limits: CPU `500m`, memory `256Mi`
- HPA enabled: minimum `2`, maximum `5`, target CPU utilization `70%`

The image tag was promoted through GitOps to:

`3a45fea620449548ecedfa960f7aecffbe1f1766`

Argo CD reconciled the change, and the application was observed returning version `1.0.1`.

## GitOps workflow verified

The following workflow was exercised:
1. The application change was built and pushed to Amazon ECR by GitHub Actions.
2. The image was promoted by updating the image tag in the Helm values file in this repository.
3. The change was committed and pushed to `master`.
4. Argo CD refreshed the repository revision and reconciled the Helm release.
5. The Deployment rolled out the new image and the application was checked.

Recorded promotion commit: `5174f466f1dcd2021998552c0f32834ce1551382`.

A previous image rollback was also exercised by reverting the Helm image tag and allowing Argo CD to reconcile the change.

## Reliability evidence

The test evidence in [`docs/reliability-test-evidence.txt`](docs/reliability-test-evidence.txt) records:
- Manual deletion of an application pod and successful controller-driven replacement.
- Two available application replicas after recovery.
- Application endpoint reporting version `1.0.1`.
- Health endpoint reporting `healthy`.
- 60/60 sequential HTTP health requests returning HTTP 200.
- HPA remaining at two replicas during that sequential test; autoscaling was **not** demonstrated by this test.

These results demonstrate basic Kubernetes self-healing and application availability under the specific test performed. They do not establish high-load performance or production-level resilience.

## Observability installed and verified

The `kube-prometheus-stack` was installed in namespace `observability`. The recorded setup includes:
- Prometheus metrics collection.
- A Grafana dashboard with panels for node CPU, node memory, application pod CPU, application pod memory, and available application replicas.
- An active Grafana alert rule named `Cloud Native App - Replica Availability`, configured to alert when available replicas fall below two.
- Alertmanager deployment.

Email delivery was not verified because SMTP was not configured. The alert rule was saved and observed in the Normal state; no forced alert test was performed.

## Known gaps and incomplete scope

The following components were not found in the cluster checks performed at project close:
- OpenTelemetry
- Loki
- Tempo

Their deployment and integration were not completed or verified. Consequently, this repository should not claim a complete logs-and-traces pipeline.

Other limits of the recorded validation:
- The sequential health-request test did not trigger HPA scale-out.
- Alert email delivery was not tested successfully.
- Container vulnerability findings remained in the application image at the recorded scan; see the application repository README.
- No claim is made that every originally planned Kubernetes security control was fully implemented or tested.

## Project conclusion

Work on this project was concluded at its current implementation stage on 13 October 2026. The completed artifacts demonstrate GitOps delivery, an EKS-hosted application, basic self-healing, and Prometheus/Grafana monitoring with an availability alert. The remaining scope is explicitly documented above rather than represented as completed.
