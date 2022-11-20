locals {
  base_tags = {
    Component: var.component,
  }

  resolved_tags = merge(var.tags, local.base_tags)
}
