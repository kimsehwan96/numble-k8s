# How to use this?

이 terraform 코드는 10.0.0.0/16 CIDR block의 VPC를 생성하고

2개의 Private Subnet(Loadbalencer용 1개, 범용 1개), 1개의 Public Subnet를 생성합니다. 

1개의 nks 클러스터를 생성하며, 1개의 워커노드를 생성합니다. (vCPU 4, mem 16GiB)

Bastion Host(vCPU 2, mem 4GiB) 를 Public Host에 생성하고 공인 IP 할당 및 NKS의 acg를 nic에 연결합니다.
## Terraform 설치

### MACOS

```sh
$ brew install terraform
```

## How to deploy this?

네이버클라우드 -> 마이페이지 -> 계정관리 -> 인증키관리에서 인증키를 생성합니다. 

현재 디렉터리(`nks/`) 내부에 `variables.tf` 를 생성합니다. 

```
.
├── README.md
├── terraform.tf
└── variables.tf
```

variables.tf 의 내용은 아래와 같이 채웁니다.

```tf
variable access_key {
  default = "access_key"
}
variable secret_key {
  default = "secret_key"
}

variable region {
    default = "KR"
}
```

위에서 access_key.default , secret_key.default를 여러분이 발급받은 API 인증키로 대체합니다.


이후에 `terraform init ` 입력하여 terraform IaC 코드를 사용할 준비를 합니다. 

`terraform plan` 을 입력하면 어떤 리소스들이 생성/삭제/변경되는지 확인 가능합니다. (일종의 dry-run 기능)

`terraform apply`를 하면 실제 리소스 배포가 완료됩니다. 