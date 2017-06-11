#!/bin/sh
set -u
set -e

generate_concourse_keys() {
    mkdir -p data/concourse/web data/concourse/worker

    ssh-keygen -t rsa -f ./data/concourse/web/tsa_host_key -N ''
    ssh-keygen -t rsa -f ./data/concourse/web/session_signing_key -N ''
    ssh-keygen -t rsa -f ./data/concourse/worker/worker_key -N ''

    cp ./data/concourse/worker/worker_key.pub ./data/concourse/web/authorized_worker_keys
    cp ./data/concourse/web/tsa_host_key.pub ./data/concourse/worker
}

generate_gitlab_secrets() {
    GITLAB_SECRETS_DB_KEY_BASE=$(docker run --rm kciepluc/pwgen-docker -B -s 128)
    GITLAB_SECRETS_SECRET_KEY_BASE=$(docker run --rm kciepluc/pwgen-docker -B -s 128)
    GITLAB_SECRETS_SECRET_KEY_BASE=$(docker run --rm kciepluc/pwgen-docker -B -s 128)
    touch ./data/gitlab_secrets.sh && chmod u+x ./data/gitlab_secrets.sh
    cat > ./data/gitlab_secrets.sh <<EOL
#!/bin/sh
set -u
set -e
export GITLAB_SECRETS_DB_KEY_BASE=${GITLAB_SECRETS_DB_KEY_BASE}
export GITLAB_SECRETS_SECRET_KEY_BASE=${GITLAB_SECRETS_SECRET_KEY_BASE}
export GITLAB_SECRETS_SECRET_KEY_BASE=${GITLAB_SECRETS_SECRET_KEY_BASE}
EOL
}

set_concourse_external_url() {
    export CONCOURSE_EXTERNAL_URL=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
}

if [ ! -f ./data/concourse/worker/worker_key.pub ]
then
    echo "Generating keys for Concourse for the first time..."
    generate_concourse_keys
else 
    echo "Found existing Concourse keys. Skipping key generation"
fi

if [ ! -f ./data/gitlab_secrets.sh ]
then
    echo "Generating GitLab secrets for the first time..."
    generate_gitlab_secrets
else 
    echo "Found existing GitLab keys. Skipping key generation" && ./data/gitlab_secrets.sh
fi

set_concourse_external_url && echo "Setting CONCOURSE_EXTERNAL_URL to ${CONCOURSE_EXTERNAL_URL}"

# docker-compose up
# docker-compose start
