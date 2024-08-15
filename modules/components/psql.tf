resource "helm_release" "psql_operator" {
  namespace        = "psql-operator"
  create_namespace = true
  name             = "psql-operator"
  chart            = "./charts/postgres-operator-1.12.2.tgz"
  wait             = false
}

resource "helm_release" "psql_operator_ui" {
  namespace        = "psql-operator"
  create_namespace = true
  name             = "psql-operator-ui"
  chart            = "./charts/postgres-operator-ui-1.12.2.tgz"
  wait             = false
}