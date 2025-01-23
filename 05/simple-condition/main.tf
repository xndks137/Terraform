variable "name" {
  description = "A name to render"
  type = string
}

output "if_else_directive" {
  value = <<-EOF
  "Hello, %{if var.name != ""}
  ${var.name}
  %{else}
  (unnamed)
  %{endif}"
  EOF
}

output "output2" {
  value = (var.name != "" ? var.name : "(unnamed)")
}