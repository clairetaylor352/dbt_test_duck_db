wget https://github.com/duckdb/duckdb/releases/download/v1.1.3/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-linux-amd64.zip
rm -rf .venv

pip install virtualenv
python -m virtualenv .venv

source .venv/bin/activate
pip install -r requirements.txt;

