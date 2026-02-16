resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.16.1"
  namespace  = "kube-system"

  set {
    name  = "eni.enabled"
    value = "true"
  }

  set {
    name  = "ipam.mode"
    value = "eni"
  }

  set {
    name  = "egressGateway.enabled"
    value = "true"
  }

  set {
    name  = "routingMode"
    value = "native"
  }

  set {
    name  = "ipv4.enabled"
    value = "true"
  }

  set {
    name  = "ipv6.enabled"
    value = "true"
  }
}
