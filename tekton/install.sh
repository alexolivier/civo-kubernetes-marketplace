#!/bin/bash

# There is an issue with single kubectl apply command, so we need to split it into two commands:
# Create CRD first (this file) and then create CR (app.yaml).
# https://github.com/kubernetes/kubectl/issues/1179

cat <<EOF | kubectl apply -f -
---
# Copyright 2021 The Tekton Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: clusterinterceptors.triggers.tekton.dev
  labels:
    app.kubernetes.io/instance: default
    app.kubernetes.io/part-of: tekton-triggers
    triggers.tekton.dev/release: "v0.25.3"
    version: "v0.25.3"
spec:
  group: triggers.tekton.dev
  scope: Cluster
  names:
    kind: ClusterInterceptor
    plural: clusterinterceptors
    singular: clusterinterceptor
    shortNames:
      - ci
    categories:
      - tekton
      - tekton-triggers
  versions:
    - name: v1alpha1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          # One can use x-kubernetes-preserve-unknown-fields: true
          # at the root of the schema (and inside any properties, additionalProperties)
          # to get the traditional CRD behaviour that nothing is pruned, despite
          # setting spec.preserveUnknownProperties: false.
          #
          # See https://kubernetes.io/blog/2019/06/20/crd-structural-schema/
          # See issue: https://github.com/knative/serving/issues/912
          x-kubernetes-preserve-unknown-fields: true
      # Opt into the status subresource so metadata.generation
      # starts to increment
      subresources:
        status: {}
EOF

kubectl apply -f tekton.yaml
