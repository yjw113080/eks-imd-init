# kubectl
# echo '============================================'
# echo 'Installing kubectl'
# echo '============================================'

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc


# AWS tools
# echo '============================================'
# echo 'Installing other tools'
# echo '============================================'
sudo pip install --upgrade awscli && hash -r
sudo yum -y install jq gettext bash-completion moreutils
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc

# env configuration
# echo '============================================'
# echo 'Configuring the environment'
# echo '============================================'
rm -vf ${HOME}/.aws/credentials

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))

echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
echo "export AZS=(${AZS[@]})" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region

# eksctl prereqs
# echo '============================================'
# echo 'Configuring prerequisites for EKS cluster'
# echo '============================================'
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub
aws kms create-alias --alias-name alias/eksworkshop --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop --query KeyMetadata.Arn --output text)
echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile

# eksctl
# echo '============================================'
# echo 'Install eksctl'
# echo '============================================'
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin

# echo '============================================'
# echo 'Validate'
# echo '============================================'
test -n "$ACCOUNT_ID" && echo ACCOUNT_ID is "$ACCOUNT_ID" || echo ACCOUNT_ID is not set
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
test -n "$AZS" && echo AZS is "$AZS" || echo AZS is not set
test -n "$MASTER_ARN" && echo MASTER_ARN is "$MASTER_ARN" || echo MASTER_ARN is not set

aws sts get-caller-identity --query Arn | grep -q EksImdStack-admin && echo "IAM role valid" || echo "IAM role NOT valid"