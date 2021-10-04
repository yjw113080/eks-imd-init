# Amazon EKS 실습 환경 구성
아래 가이드는 AWS 직원의 가이드에 따라 이벤트엔진을 통해 실습하는 경우를 기준으로 설명합니다. 자체적으로 진행하는 경우, [이 가이드](https://aws-eks-web-application.workshop.aws/ko/30-setting/100-aws-cloud9.html)에 따라 Cloud9과 IAM Role 생성을 사전에 진행하십시오.

## 사전에 생성된 Cloud9에 IAM Role 설정
1. [여기](https://console.aws.amazon.com/ec2/v2/home?#Instances:sort=desc:launchTime)를 클릭하여 EC2 인스턴스 페이지에 접속합니다.
2. cloud9 인스턴스를 선택한 후 **Actions > Security > Modify IAM Role** 을 클릭합니다.
  ![](https://aws-eks-web-application.workshop.aws/images/30-setting/aws_cloud9_03.png)
3. IAM Role 에서 `mod-XXXXXXXX-Cloud9InstanceProfile`을 선택한 후, **Save** 버튼을 클릭합니다.

## IDE에서 IAM 설정 업데이트
AWS Cloud9의 경우, IAM credentials를 동적으로 관리합니다. 해당 credentials는 EKS IAM authentication과 호환되지 않기에 이를 비활성화하고 IAM Role을 붙입니다.

1. [AWS Cloud9 콘솔창](https://console.aws.amazon.com/cloud9) 에서 생성되어 있는 IDE로 접속한 후, 우측 상단에 기어 아이콘을 클릭한 후, 사이드 바에서 **AWS SETTINGS** 를 클릭합니다.
2. **Credentials** 항목에서 **AWS managed temporary credentials** 설정을 비활성화합니다.
3. Preference tab을 종료합니다.
![](https://aws-eks-web-application.workshop.aws/images/30-setting/aws_cloud9_05.png)

4. **GetCallerIdentity** CLI 명령어를 통해, Cloud9 IDE가 올바른 IAM Role을 사용하고 있는지 확인하세요. 결과 값이 나오면 올바르게 설정된 것입니다.
```
aws sts get-caller-identity --query Arn | grep Cloud9InstanceRole
```
