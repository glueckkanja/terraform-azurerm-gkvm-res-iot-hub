# Merged on top of https://raw.githubusercontent.com/Azure/tfmod-scaffold/main/avm.tflint_example.hcl
# by avm_scripts/run-tflint.sh (hclmerge). Attributes here replace the upstream ones.

# Examples reference helper modules (Azure/avm-utl-regions, Azure/naming) with
# pessimistic constraints (~> x.y) so they pick up patch releases. Allow ranges
# instead of requiring an exact version.
rule "terraform_module_version" {
  enabled = true
  exact   = false
}
