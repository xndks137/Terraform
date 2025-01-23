# ##################################
# #
# # list type variable
# #

# # "neo", "trinity", "morhpeus"
# variable "names" {
#   default = ["neo", "trinity", "morhpeus"]
#   type = list(string)
#   description = "List test"
# }

# output "names" {
#   value = var.names
# }

# # 1) "NEO", "TRINITY", "MORHPEUS"
# output "upper_names" {
#   value = [for name in var.names: upper(name)]
# }

# output "short_upper_names" {
#   value = [for name in var.names: upper(name) if length(name) < 5]
# }

################################################
#
# map type variable
#

# {"neo": "hero", "trinity": "love interest", "morhpeus":"mentor"}
variable "hero_thousand_faces" {
  default = {
    neo = "hero"
    trinity = "love interest"
    morhpeus = "mentor"
  }
  description = "Map test"
  type = map(string)
}

output "name_role" {
  value = var.hero_thousand_faces
}

# ["neo is the hero","trinity is the love interest","morhpeus is the mentor"]
output "bios" {
  value = [for name, role in var.hero_thousand_faces: "${name} is the ${role}"]
}

# ["NEO is the HERO","TRINITY is the LOVE INTEREST","MORHPEUS is the MENTOR"]
output "upper_bios" {
  value = [for name, role in var.hero_thousand_faces: "${upper(name)} is the ${upper(role)}"]
}

output "bios2" {
  value = {for name, role in var.hero_thousand_faces: upper(name) => upper(role)}
}
