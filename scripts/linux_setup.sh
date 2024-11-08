sudo apt-get install -y git curl make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev  libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl uidmap;

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-478.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-478.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
rm -rf .venv

pip install virtualenv
python -m virtualenv .venv

source .venv/bin/activate
pip install -r requirements.txt;

dbt deps