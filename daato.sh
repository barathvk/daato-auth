#! /usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DAATO_REPO="git@github.com:daatotech/core.git"
# @describe daato developer tools
# @option -h --help show help

# --------------------------------------------------------------------------------------------------------------------------------------- INFRA
# @cmd work with daato infrastructure
# @alias i
infra() { :; }

# @cmd generate terraform files from templates
# @alias g
infra::generate() {
  terramate generate
}
# @cmd generate execution graph
# @arg stack=local stack to update
infra::graph() {
	pushd ${SCRIPT_DIR}/infrastructure/stacks/${argc_stack} > /dev/null
  terramate experimental run-graph
  popd > /dev/null
}
# @cmd initialize terraform
# @alias i
# @arg stack=local stack to update
infra::init() {
  infra::generate
  pushd ${SCRIPT_DIR}/infrastructure/stacks/${argc_stack} > /dev/null
  terramate run terraform init
  popd > /dev/null
}

# @cmd create or update infrastructure
# @alias u
# @flag -i --init also initialize the infrastructure
# @arg stack=local stack to update
infra::up() {
  if [ "${argc_init}" ]; then
    infra::init
  fi
  pushd ${SCRIPT_DIR}/infrastructure/stacks/${argc_stack} > /dev/null
  terramate run terraform apply -auto-approve
  popd > /dev/null
}

# @cmd create or update infrastructure
# @alias d
# @arg stack=local stack to destroy
infra::down() {
  pushd ${SCRIPT_DIR}/infrastructure/stacks/${argc_stack} > /dev/null
  terramate run terraform destroy -auto-approve
  popd > /dev/null
}

# --------------------------------------------------------------------------------------------------------------------------------------- DEV
# @cmd start daato applications
# @alias d
dev() { :; }

# @cmd start services
# @alias s
# @option -s --service=* service to start
# @option -g --group=* service group to use
dev::start() {
	yarn turbo run start --parallel --filter=@${argc_group}/${argc_service}  --filter=!@packages/* --filter=!@modules/*
}

# --------------------------------------------------------------------------------------------------------------------------------------- DB
# @cmd work with the database
db() { :; }

# @cmd run database migrations
# @alias m
# @arg service! service to generate
# @arg namespace! namespace to use
# @flag -m --migrate also run the migration
db::generate() {
  pushd ${SCRIPT_DIR}/services/${argc_service}/model > /dev/null
	export DATABASE_URL="postgres://root@db.${argc_namespace}:26257/postgres?sslmode=disable"
	rm -rf ./src/model
	yarn prisma generate
	yarn eslint --fix ./src/model/dto/**
	if [ "${argc_migrate}" ]; then
		echo "running migration..."
		yarn prisma migrate dev --name init
	fi
  popd > /dev/null
}

# --------------------------------------------------------------------------------------------------------------------------------------- AUTH
# @cmd authentication tools
# @alias a
auth() { :; }

# @cmd generate a token
# @alias t
# @arg realm! realm to generate a token for
auth::token() {
	keycloak_credentials=$(kubectl get secret keycloak-credentials -n auth -o json | jq '.data | map_values(@base64d)')
	username=$(echo ${keycloak_credentials} | jq -r '.username')
	password=$(echo ${keycloak_credentials} | jq -r '.password')
	curl -s -d "client_id=admin-cli" -d "username=${username}" -d "password=${password}" -d "grant_type=password" "http://keycloak-http.auth/realms/${argc_realm}/protocol/openid-connect/token" | jq -r '.access_token'
}

# --------------------------------------------------------------------------------------------------------------------------------------- CLUSTER
# @cmd interact with the cluster
# @alias c
cluster() { :; }

# @cmd connect to the cluster
# @alias c
cluster::connect() {
	telepresence connect
}

# @cmd disconnect from the cluster
# @alias d
cluster::disconnect() {
	telepresence quit
}

eval "$(argc --argc-eval "$0" "$@")"