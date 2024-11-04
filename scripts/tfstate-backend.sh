# Este é um script que faz o uso de CLI da AWS para criar um bucket,
# habilitar o versionamento do mesmo e criar uma tabela no dynamodb
# para realizar o lock e o unlock desse tfstate.

BUCKET="${1}"

# Cria o bucket na região de us-east-1
aws s3api create-bucket --bucket "${BUCKET}" --region us-east-1

# Habilita o versionamento do Bucket do S3
aws s3api put-bucket-versioning --bucket "${BUCKET}" --versioning-configuration Status=Enabled

# Cria a tabela no DynamoDB com o mesmo nome do Bucket, para seguir o padrão.
aws dynamodb create-table \
  --table-name "${BUCKET}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

