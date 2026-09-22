#!/usr/bin/env bash
#
# Local replacement for Azure/tfmod-scaffold avm_scripts/conftest.sh.
#
# Upstream fetches the policies with `conftest test --update git::https://github.com/Azure/policy-library-avm.git//policy/...`.
# conftest >= v0.70.0 ships go-getter v1.8.9, whose git getter disables symlink copies, and
# policy-library-avm contains symlinked `common.utils.rego` files, so every run fails with
# "client get: copying of symlinks has been disabled". tfmod-scaffold is no longer maintained,
# so we clone the policy library ourselves, dereference the symlinks and point conftest at the
# local copies. Everything else mirrors the upstream script.

set -e

POLICY_REPO="${AVM_POLICY_LIBRARY_REPO:-https://github.com/Azure/policy-library-avm.git}"
POLICY_REF="${AVM_POLICY_LIBRARY_REF:-main}"

has_error=false

if [ ! -d "examples" ]; then
  echo "No \`examples\` folder found."
  exit 0
fi

echo "==> Fetching AVM policy library ($POLICY_REPO@$POLICY_REF)..."
policy_src=$(mktemp -d)
trap 'rm -rf "$policy_src"' EXIT
git clone --quiet --depth 1 --branch "$POLICY_REF" "$POLICY_REPO" "$policy_src"

cd examples

for d in $(find . -maxdepth 1 -mindepth 1 -type d); do
  if ls "$d"/*.tf > /dev/null 2>&1; then
    cd "$d"
    echo "==> Checking $d"

    if [ -f ".e2eignore" ]; then
      echo "==> Skipping $d due to .e2eignore file"
      cd - >/dev/null 2>&1
      continue
    fi

    # run pre.sh if it exists
    if [ -f "./pre.sh" ]; then
      echo "==> Running pre.sh"
      chmod +x ./pre.sh
      ./pre.sh
    fi

    echo "==> Initializing Terraform..."
    terraform init -input=false
    echo "==> Running Terraform plan..."
    terraform plan -input=false -out=tfplan.binary
    echo "==> Converting Terraform plan to JSON..."
    terraform show -json tfplan.binary > tfplan.json

    # Stage policies locally, dereferencing symlinks (cp -L) so conftest sees plain files.
    rm -rf ./policy
    mkdir -p ./policy/default_exceptions
    cp -RL "$policy_src/policy/Azure-Proactive-Resiliency-Library-v2" ./policy/aprl
    cp -RL "$policy_src/policy/avmsec" ./policy/avmsec
    cp "$policy_src/policy/avmsec/avm_exceptions.rego.bak" ./policy/default_exceptions/avmsec_exceptions.rego

    if [ -d "exceptions" ]; then
      conftest test --all-namespaces -p policy/aprl -p policy/default_exceptions -p exceptions tfplan.json || has_error=true
      conftest test --all-namespaces -p policy/avmsec -p policy/default_exceptions -p exceptions tfplan.json || has_error=true
    else
      conftest test --all-namespaces -p policy/aprl -p policy/default_exceptions tfplan.json || has_error=true
      conftest test --all-namespaces -p policy/avmsec -p policy/default_exceptions tfplan.json || has_error=true
    fi

    # run post.sh if it exists
    if [ -f "./post.sh" ]; then
      echo "==> Running post.sh"
      chmod +x ./post.sh
      ./post.sh
    fi

    cd - >/dev/null 2>&1
  fi
done

cd ..

if [ "$has_error" = true ]; then
  echo "At least one \`examples\` folder failed."
  exit 1
fi

echo "All \`examples\` folders passed."
exit 0
